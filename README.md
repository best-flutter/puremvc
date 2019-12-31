# puremvc

puremvc for flutter

页面与逻辑完全分离，页面可以不知道模型，模型可以不知道页面。



## Getting Started


#### 导入

```
import 'package:fpuremvc/fpuremvc.dart';
```

因为这里puremvc已经被占用了，所以只能这样


#### 流程

定义一个模型，模型用于存储数据和接收dispatch的消息并处理，完成之后notify通知已经完成

```
class NumberModel extends BaseModel{
  @override
  String get name => "number";

  int counter=0;

  @override
  void update(String event, data) {
    if(event == "add"){
      add();
    }
  }

  void add(){
    ++counter;
    notify("counter", counter);
  }
}


```

注册模型
```


NumberModel numberModel = new NumberModel();
Models.add(numberModel);
```



页面使用:


第一种：StatefulWidget

```

class MyHomePage extends StatefulWidget {
  final int counter;

  MyHomePage({Key key, this.title,this.counter}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends ObserverState<MyHomePage> {
  int _counter;
  @override
  void initState() {
    _counter= widget.counter;
    bind("counter", onCounter);
    super.initState();
  }

  void onCounter(int counter){
    this._counter = counter;
  }

  void _incrementCounter() {
    dispatch("number/add", null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            new RaisedButton(onPressed: (){

              Navigator.push(context, new MaterialPageRoute(builder: (c){
                return MyHomePage(title: 'Flutter Demo Home Page',counter: _counter,);
              }));

            },child: new Text("Next"),)
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


第二种:通过build来创建StateLess页面



```

class StatelessDemo extends StatelessWidget{
  int counter;
  String title;

  StatelessDemo({
    this.counter,
    this.title
});


  void _incrementCounter() {
    dispatch("number/add", null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
            new RaisedButton(onPressed: (){

              Navigator.pop(context);

            },child: new Text("Back"),)
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


```
WidgetBuilder statelessBuilder= PureMvc.eventBuilder(["counter"], (c){
    return StatelessDemo(title: 'Flutter Demo Home Page',counter: numberModel.counter,);
  });
```


```
 Navigator.push(context, new MaterialPageRoute(builder: statelessBuilder));
```


这里可以使用一些路由组件使得页面和模型隔离,或者全局保存这些WidgetBuilder

