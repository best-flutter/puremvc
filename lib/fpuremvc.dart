library fpuremvc;

import 'dart:async';

import 'package:flutter/widgets.dart';

class _ListenerInfo {
  State target;
  String event;
  Function callback;

  _ListenerInfo(this.target, this.event, this.callback);

  void call(String event, Object data) {
    target.setState(() {
      //callback有一个参数或者没有参数
      try {
        Function.apply(this.callback, [data]);
      } catch (e) {
        try {
          Function.apply(this.callback, []);
        } catch (e) {
          print("Cannot call callback ${e}");
        }
      }
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

class _Event {
  String event;
  Object data;

  _Event(this.event, this.data);
}

class _ModelHolder {
  final BaseModel model;
  bool _init = false;
  _ModelHolder(this.model);
  void setup() async {
    var ret = model.setup();
    if (ret == null) {
      _init = true;
      return;
    }

    ret.whenComplete(() {
      _init = true;
      while (queue.length > 0) {
        _Event event = queue.removeAt(0);
        updateModel(event.event, event.data);
      }
    });
  }

  void dispose() {
    model.dispose();
  }

  void updateModel(String event, Object data) {
    notify("${model.name}/$event@start", null);
    var update = model.update(event, data);
    if (update == null) {
      notify("$event@end", null);
      return;
    }

    if (update is Future) {
      update.then((data) {
        notify("${model.name}/$event@ok", data);
      }).catchError((e) {
        if (!notify("${model.name}/$event@fail", e)) {
          if (!_listener.handleUnhandledError(e)) {
            print("Error has happened, and no handle is found $e");
            return Future.error(e);
          }
        }
        return null;
      }).whenComplete(() {
        notify("${model.name}/$event@end", null);
      });
    }
  }

  List<_Event> queue = [];
  void update(String event, Object data) {
    if (!_init) {
      //添加到队列
      print("Still seting up, add event to the queue");
      queue.add(new _Event(event, data));
    } else {
      updateModel(event, data);
    }
  }
}

class _EventListener {
  List<_ModelHolder> models = [];

  Map<String, List<_ListenerInfo>> listeners = {};
  Map<String, _ModelHolder> modelMap = {};

  OnError globalErrorHandler;

  bool handleUnhandledError(e) {
    if (globalErrorHandler == null) {
      return false;
    }
    return globalErrorHandler(e);
  }

  void dispatch(String event, Object data) {
    List<String> part = event.split("/");
    if (part.length == 1) {
      for (_ModelHolder model in models) {
        model.update(event, data);
      }
    } else {
      _ModelHolder model = modelMap[part[0]];
      if (model == null) {
        print("Model is not exists!");
        return;
      }
      model.update(part[1], data);
    }
  }

  bool init = false;

  void add(BaseModel model) {
    _ModelHolder holder = new _ModelHolder(model);
    models.add(holder);
    modelMap[model.name] = holder;
    if (!init) {
      init = true;
      scheduleMicrotask(() {
        for (_ModelHolder model in models) {
          model.setup();
        }
      });
    }
  }

  void remove(BaseModel model) {
    _ModelHolder holder = models.firstWhere(
        (_ModelHolder holder) => holder.model == model,
        orElse: () => null);
    if (holder == null) {
      print("Cannot find model to remove ");
      return;
    }
    models.remove(holder);
    modelMap.remove(model.name);
    holder.dispose();
  }

  void bind(Object target, String event, Function listener) {
    var old = listeners[event];
    _ListenerInfo info = new _ListenerInfo(target, event, listener);
    if (old == null) {
      listeners[event] = [info];
    } else {
      old.add(info);
    }
  }

  bool notifyListeners(String event, Object data) {
    var old = listeners[event];
    if (old == null) {
      // print("Cannot find listeners with event $event");
      return false;
    }

    for (_ListenerInfo call in old) {
      call.call(event, data);
    }
    return true;
  }

  void unbiind(Object target) {
    for (String key in []..addAll(listeners.keys)) {
      List<_ListenerInfo> eventInfos = listeners[key];
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
    return models
        .firstWhere((_ModelHolder model) => model.model.runtimeType == type)
        .model;
  }
}


_EventListener _listener = new _EventListener();

/// error handler,if the error is handled ,return true
typedef bool OnError(e);

class PureMvc {
  static WidgetBuilder eventBuilder(
      var eventOrEventList, WidgetBuilder builder) {
    return (BuildContext context) {
      return new _WidgetBuilderEventListener(builder, eventOrEventList);
    };
  }

  static void add(BaseModel model) {
    _listener.add(model);
  }

  static void remove(BaseModel model) {
    _listener.remove(model);
  }

  static BaseModel getModel(Type type) {
    return _listener.getModel(type);
  }

  void setGlobalErrorHandler(OnError errorHandler) {
    _listener.globalErrorHandler = errorHandler;
  }
}

void dispatch(String event, [Object data]) {
  _listener.dispatch(event, data);
}

bool notify(String event, Object data) {
  return _listener.notifyListeners(event, data);
}

abstract class BaseModel {
  BaseModel() {
    PureMvc.add(this);
  }

  String get name;

  Future setup() {}

  Future dispose() {}

  update(String event, var data) {}
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
