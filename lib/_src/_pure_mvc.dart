
part of '../fpuremvc.dart';

/// error handler,if the error is handled ,return true
typedef bool OnError(e);

class PureMvc {

  static void unbind({
  Object target,
    String event
}){
    _listener.unbind(target: target,event: event);
  }


  static void add(BaseModel model) {
    _listener.add(model);
  }

  static Future<BaseModel> requestModel(Type type) {
    return _listener.requestModel(type);
  }

  static void remove(BaseModel model) {
    _listener.remove(model);
  }
  static void contains(String modelName) {
    _listener.contains(modelName);
  }
  static BaseModel getModel(Type type) {
    return _listener.getModel(type);
  }

  static void bind(String event,Function listener,{State target}){
    _listener.bind(target, event, listener);
  }

  static void setGlobalErrorHandler(OnError errorHandler) {
    _listener.globalErrorHandler = errorHandler;
  }

  static hasListener(String event) {
    return _listener.hasListener(event);
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

   setup() {
    return null;
  }

   dispose() {
    return null;
  }

  update(String event, var data) {}
}

abstract class ObserverState<T extends StatefulWidget> extends State<T> {
  void bind(String event, Function listener) {
    _listener.bind(this, event, listener);
  }

  @override
  void dispose() {
    _listener.unbind(target: this);
    super.dispose();
  }
}

mixin Observer<T extends StatefulWidget> on State<T> {
  void bind(String event, Function listener) {
    _listener.bind(this, event, listener);
  }

  void unbind() {
    _listener.unbind(target: this);
  }
}
