library puremvc;

import 'dart:async';

import 'package:flutter/widgets.dart';

class _EventInfo {
  State target;
  String name;
  Function callback;

  _EventInfo(this.target, this.name, this.callback);

  void call(String event, Object data) {
    target.setState(() {
      Function.apply(this.callback, [data]);
    });
  }
}

class _WidgetBuilderEventListener extends StatefulWidget {
  WidgetBuilder builder;
  var event;

  _WidgetBuilderEventListener(this.builder, this.event);

  @override
  __WidgetBuilderEventListenerState createState() =>
      __WidgetBuilderEventListenerState();
}

class __WidgetBuilderEventListenerState
    extends ObserverState<_WidgetBuilderEventListener> {
  @override
  void initState() {
    if (widget.event is String) {
      bind(widget.event, onEvent);
    } else {
      widget.event.forEach((e) => bind(e, onEvent));
    }

    super.initState();
  }

  void onEvent(var data) {
    print("event");
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

class _EventListener {
  List<BaseModel> models = [];

  Map<String, List<_EventInfo>> listeners = {};
  Map<String, BaseModel> modelMap = {};

  void dispatch(String event, Object data) {
    List<String> part = event.split("/");
    if (part.length == 1) {
      for (BaseModel model in models) {
        model.update(event, data);
      }
    } else {
      BaseModel model = modelMap[part[0]];
      if (model == null) {
        print("Model is not exists!");
        return;
      }
      model.update(part[1], data);
    }
  }

  void add(BaseModel model) {
    models.add(model);
    modelMap[model.name] = model;
    scheduleMicrotask(() {
      for (BaseModel model in models) {
        model.setup();
      }
    });
  }

  void remove(BaseModel model) {
    models.remove(model);
    modelMap.remove(model.name);
    model.dispose();
  }

  void bind(Object target, String event, Function listener) {
    var old = listeners[event];
    _EventInfo info = new _EventInfo(target, event, listener);
    if (old == null) {
      listeners[event] = [info];
    } else {
      old.add(info);
    }
  }

  void notifyListeners(String event, Object data) {
    var old = listeners[event];
    if (old == null) {
      print("Cannot find listeners with event $event");
      return;
    }

    for (_EventInfo call in old) {
      call.call(event, data);
    }
  }

  void unbiind(Object target) {
    for (String key in []..addAll(listeners.keys)) {
      List<_EventInfo> eventInfos = listeners[key];
      for (int i = eventInfos.length - 1; i >= 0; --i) {
        if (eventInfos[i].target == target) {
          eventInfos.removeAt(i);
        }
      }
      if (eventInfos.length == 0) {
        listeners.remove(key);
      }
    }
  }

  BaseModel getModel(Type type) {
    return models.firstWhere((BaseModel model) => model.runtimeType == type);
  }
}

_EventListener _listener = new _EventListener();

class Models {
  static void add(BaseModel model) {
    _listener.add(model);
  }

  static void remove(BaseModel model) {
    _listener.remove(model);
  }

  static BaseModel getModel(Type type) {
    return _listener.getModel(type);
  }
}

class PureMvc {
  static WidgetBuilder eventBuilder(
      var eventOrEventList, WidgetBuilder builder) {
    return (BuildContext context) {
      return new _WidgetBuilderEventListener(builder, eventOrEventList);
    };
  }
}

void dispatch(String event, Object data) {
  _listener.dispatch(event, data);
}

void notify(String event, Object data) {
  _listener.notifyListeners(event, data);
}

abstract class BaseModel {
  BaseModel() {
    Models.add(this);
  }

  String get name;

  Future setup() {}

  Future dispose() {}

  void update(String event, var data) {}
}

abstract class ObserverState<T extends StatefulWidget> extends State<T> {
  void bind(String event, Function listener) {
    _listener.bind(this, event, listener);
  }

  @override
  void dispose() {
    _listener.unbiind(this);
    super.dispose();
  }
}

mixin Observer<T extends StatefulWidget> on State<T> {
  void bind(String event, Function listener) {
    _listener.bind(this, event, listener);
  }

  void unbind() {
    _listener.unbiind(this);
  }
}
