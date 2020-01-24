
part of '../fpuremvc.dart';

class _ListenerInfoHolder{
  RegExp regExp;
  String key;
  List<_ListenerInfo> infos = [];

  _ListenerInfoHolder(String key){
    if(key.contains("*")){
      regExp = new RegExp(key.replaceAll("*", "[a-zA-Z0-9_\.\/\+\-]*"));
    }
    this.key = key;
  }

  void add(_ListenerInfo info){
    infos.add(info);
  }

  bool match(String event){
    if(regExp!=null){
      return regExp.hasMatch(event);
    }
    return key == event;
  }

  void notify(String event,Object data) {
    // just in case the listener is removed when executing
    var arr = []..addAll(infos);
    for (_ListenerInfo call in arr) {
      call.call(event, data);
    }
  }

  /// unbind event , target or event must be specified at least one
  bool unbind({Object target,String event}) {
    assert(target!=null || event!=null,"target or event must be specified at least one");
    int count = infos.length;
    if(target!=null){
      for (int i = infos.length - 1; i >= 0; --i) {
        if (infos[i].target == target) {
          infos.removeAt(i);
        }
      }
    }

    if(event!=null){
      for (int i = infos.length - 1; i >= 0; --i) {
        if (infos[i].event == event) {
          infos.removeAt(i);
        }
      }
    }

    return infos.length < count;
  }
}

class _ListenerInfo {
  State target;
  String event;
  Function callback;


  _ListenerInfo(this.target, this.event, this.callback);

  void doCall(String event, Object data){
    try {
      var ret = Function.apply(this.callback, [data]);
      if(ret == false){ //do not change state
        return;
      }
      target.setState(() {

      });
    } catch (e) {
      onNotifyError(event,data,e);
    }
  }

  void onNotifyError(String event,Object data,e){
    if (!_listener.handleUnhandledError(e)) {
      print("Unhandled exception when notify [$event] : $e ");
    }
  }

  void call(String event, Object data) {
    if(target==null){
      try{
        Function.apply(this.callback, [data]);
      }catch(e){
        onNotifyError(event,data,e);
      }
      return;
    }
    if (target.mounted) {
      doCall(event, data);
    } else {
      print(
          "Trying to notify event $event but the target is not mounted anymore");
    }
  }
}