library fpuremvc;

import 'dart:async';

import 'package:flutter/widgets.dart';
part '_src/_listener_info.dart';
part '_src/_pure_mvc.dart';


@immutable
class EventListener extends StatefulWidget {
  final WidgetBuilder builder;
  final dynamic event;

  EventListener({@required this.builder, @required this.event});

  @override
  _EventListenerState createState() => _EventListenerState();
}

class _EventListenerState extends ObserverState<EventListener> {
  @override
  void initState() {
    if (widget.event is String) {
      bind(widget.event, onEvent);
    } else {
      widget.event.forEach((e) => bind(e, onEvent));
    }

    super.initState();
  }

  void onEvent(var data) {}

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
  Future setupLock;

  _ModelHolder(this.model);

  void setup() {

    var setupResult ;
    try{
      setupResult=model.setup();
    } catch(e){
      _init = true;
      if (!_listener.handleUnhandledError(e)) {
        print("Unhandled error when model [${model.name}] setup $e");
      }
      notify("${model.name}/setup@fail", e);
      return;
    }
    if(setupResult is Future){
      setupLock = Future.sync(() async{
        try {
          var ret = await setupResult;
          notify("${model.name}/setup@ok", ret);
        } catch (e) {
          if (!_listener.handleUnhandledError(e)) {
            print("Unhandled error when model [${model.name}] setup $e");
          }
          notify("${model.name}/setup@fail", e);
        } finally {
          _init = true;
          notify("${model.name}/setup@end", null);
          while (queue.length > 0) {
            _Event event = queue.removeAt(0);
            updateModel(event.event, event.data);
          }
        }
      });
    }else{
      _init=true;
      notify("${model.name}/setup@ok", null);
    }

  }

  void dispose() {
    model.dispose();
  }

  void updateModel(String event, Object data) {
    notify("${model.name}/$event@start", null);
    var update = model.update(event, data);
    if (update is Future) {
      update.then((data) {
        notify("${model.name}/$event@ok", data);
      }).catchError((e) {
        if (!notify("${model.name}/$event@fail", e)) {
          if (!_listener.handleUnhandledError(e)) {
            print("Error has happened, and no handle is found $e");
          }
        }
      }).whenComplete(() {
        notify("${model.name}/$event@end", null);
      });
    } else {
      //不是future
      notify("${model.name}/$event@ok", update);
    }
  }

  List<_Event> queue = [];

  void update(String event, Object data) {
    if (!_init) {
      //添加到队列
      print(
          "Model ${model
              .name} is still seting up, add event [$event] to the queue");
      queue.add(new _Event(event, data));
    } else {
      updateModel(event, data);
    }
  }
}

class _EventListener {
  List<_ModelHolder> models = [];

  List<_ListenerInfoHolder> listeners = [];
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
        print("Model ${part[0]} is not exists!");
        return;
      }
      model.update(part[1], data);
    }
  }

  bool contains(String name){
    for(_ModelHolder holder in models){
      if(holder.model.name == name){
        return true;
      }
    }
    return false;
  }

  void add(BaseModel model) {
    if(contains(model.name)){
      throw new Exception("Model with name [${model.name}] already added!");
    }
    _ModelHolder holder = new _ModelHolder(model);
    models.add(holder);
    modelMap[model.name] = holder;
    holder.setup();
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

  void bind(State target, String event, Function listener) {
    assert(event != null);
    assert(listener != null);

    _ListenerInfoHolder holder = listeners.firstWhere((_ListenerInfoHolder holder)=>holder.key==event,orElse:()=>null);
    if(holder==null){
      holder = new _ListenerInfoHolder(event);
      listeners.add(holder);
    }
    _ListenerInfo info = new _ListenerInfo(target, event, listener);
    holder.infos.add(info);
  }

  bool notifyRegExp(String event,Object data){

    bool hasFound = false;
    for(_ListenerInfoHolder holder in listeners){
      if(holder.match(event)){
        hasFound = true;
        holder.notify(event,data);
      }
    }
    return hasFound;
  }
  //static const String SIMPLE_PATTEN = r"(\\**)([^\\*]+)(\\**)";

  bool notifyListeners(String event, Object data) {
    assert(event != null);
    return notifyRegExp(event, data);
  }



  void unbind({
    Object target,
    String event
}) {
    for(_ListenerInfoHolder holder in []..addAll(listeners)){
      if(holder.unbind(target:target,event: event) && holder.infos.length==0){
        listeners.remove(holder);
      }
    }
  }

  bool hasListener(String event){
    for(_ListenerInfoHolder holder in listeners){
      if(holder.match(event)){
        return true;
      }
    }
    return false;
  }

  BaseModel getModel(Type type) {
    return models
        .firstWhere((_ModelHolder model) => model.model.runtimeType == type)
        ?.model;
  }

  Future<BaseModel> requestModel(Type type) {
    _ModelHolder holder = models
        .firstWhere((_ModelHolder model) => model.model.runtimeType == type);
    if (holder == null) {
      throw new Exception("Cannot find model by type $type");
    }
    if (holder._init) {
      return Future.value(holder.model);
    }

    if (holder.setupLock == null) {
      throw new Exception("Model $type is not setting up");
    }

    Completer<BaseModel> completer = new Completer<BaseModel>();
    holder.setupLock.whenComplete(() {
      completer.complete(holder.model);
    });

    return completer.future;
  }
}

_EventListener _listener = new _EventListener();
