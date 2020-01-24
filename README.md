<p align="center">
    <a href="https://travis-ci.org/best-flutter/puremvc">
        <img src="https://travis-ci.org/best-flutter/puremvc.svg?branch=master" alt="Build Status" />
    </a>
    <a href="https://coveralls.io/github/best-flutter/puremvc?branch=master">
        <img src="https://coveralls.io/repos/github/best-flutter/puremvc/badge.svg?branch=master" alt="Coverage Status" />
    </a>
    <a href="https://github.com/jzoom/puremvc/pulls">
        <img src="https://img.shields.io/badge/PRs-Welcome-brightgreen.svg" alt="PRs Welcome" />
    </a>
    <a href="https://pub.dartlang.org/packages/fpuremvc">
        <img src="https://img.shields.io/pub/v/fpuremvc.svg" alt="pub package" />
    </a>
    <a target="_blank" href="https://shang.qq.com/wpa/qunwpa?idkey=a71a2504cda4cc9ace3320f2dc588bdae928abc671e903463caeb71ec9302c2c"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="best-flutter" title="best-flutter"></a>
</p>


# puremvc

puremvc for flutter

页面与逻辑完全分离，页面可以不知道模型，模型可以不知道页面。


为什么要有这个库？

目前的状态管理库要么使用过于复杂，要么并不能做到模型和页面完全隔离，所以有这个库。




## Getting Started


#### 导入

```
import 'package:fpuremvc/fpuremvc.dart';
```

因为这里puremvc已经被占用了，所以只能这样


#### 流程

定义一个模型，模型用于存储数据和接收dispatch的消息并处理，完成之后notify通知已经完成

```

class NumberModel extends BaseModel {
  @override
  String get name => "number";

  int counter = 0;

  @override
  Future setup() async {
    await Future.delayed(new Duration(seconds: 2));
  }

  @override
  update(String event, data) {
    if (event == "add") {
      return add();
    }
  }

  int add() {
    ++counter;
    return counter;
  }
}


```

创建模型，一般保存为App的实例
```


NumberModel numberModel = new NumberModel();
```



页面使用:


第一种：StatefulWidget

```
import 'package:flutter/material.dart';
import 'package:fpuremvc/fpuremvc.dart';



class StatefulDemo extends StatefulWidget {
  final int counter;

  StatefulDemo({Key key, this.counter}) : super(key: key);

  @override
  _StatefulDemoState createState() => _StatefulDemoState();
}

class _StatefulDemoState extends ObserverState<StatefulDemo> {
  int _counter;

  @override
  void initState() {
    _counter = widget.counter;
    bind("number/add@ok", onCounter);
    bind("number/asyncAdd@ok", onCounter);
    /// the the lines can be replaced by  bind("number/*@ok", onCounter); or just bind("number/*", onCounter)


    super.initState();
  }

  void onCounter(int counter) {
    this._counter = counter;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("StatefulDemo"),
      ),
      body: Column(
          children: <Widget>[
            Text(
              'Model is setting up,so if you click button quickly,it looks like not working',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            new RaisedButton(
              onPressed: () {
                Navigator.pushNamed(context, "stateless");
              },
              child: new Text("Stateless"),
            ),


            new RaisedButton(
              onPressed: ()=>dispatch("number/add"),
              child: new Text("Sync increment"),
            ),

            new RaisedButton(
              onPressed: ()=>dispatch("number/asyncAdd"),
              child: new Text("Async increment"),
            ),


          ],
        ),


    );
  }
}

```


第二种:通过build来创建StateLess页面



```
import 'package:flutter/material.dart';
import 'package:fpuremvc/fpuremvc.dart';

@immutable
class StatelessDemo extends StatelessWidget {
  final int counter;

  StatelessDemo({this.counter});

  void _incrementCounter() {
    dispatch("number/add");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("StatelessDemo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.display1,
            ),
            new RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: new Text("Back"),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}


```


使用一些路由组件使得页面和模型隔离,或者全局保存这些WidgetBuilder
```
WidgetBuilder statelessBuilder= PureMvc.eventBuilder(["counter"], (c){
    return StatelessDemo(title: 'Flutter Demo Home Page',counter: numberModel.counter,);
});
```

```
Navigator.push(context, new MaterialPageRoute(builder: statelessBuilder));
```

直接使用routers


```


Map<String, WidgetBuilder> routers = {

  /// 定义个WidgetBuild,在监听到通知number/*@ok的时候重建， * 为通配符
  "stateless": PureMvc.eventBuilder(["number/*@ok"], (c) {
    return StatelessDemo(
      counter: numberModel.counter,
    );
  }),

    .....
  "stateful": (c) {
    return StatefulDemo(
      counter: numberModel.counter,
    );
  }
};


```
Navigator.pushNamed(context, "stateful")



## 异步



```

class NumberModel extends BaseModel {
  @override
  String get name => "number";

  int counter = 0;

  @override
  Future setup() async {
    await Future.delayed(new Duration(seconds: 2));
  }

  @override
  update(String event, data) {
    if (event == "add") {
      return add();
    } else if (event == 'asyncAdd') {
      return asynAdd();
    }
  }

  int add() {
    ++counter;
    return counter;
  }

  asynAdd() async {
    await Future.delayed(new Duration(milliseconds: 500));
    ++counter;
    return counter;
  }
}
`
```


模型中的asynAdd方法为异步方法，此时可以使用 `dispatch('number/asynAdd')` 调用,

注意这里的判断

```
else if (event == 'asyncAdd') {
      return asynAdd();
    }
```


* 当异步方法返回成功时候，将会通知事件   number/asynAdd@ok
* 当异步方法返回失败时候，将会通知事件   number/asynAdd@fail
* 当异步方法结束时候，将会通知事件 number/asynAdd@end







