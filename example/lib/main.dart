import 'package:flutter/material.dart';
import 'package:fpuremvc/fpuremvc.dart';

NumberModel numberModel = new NumberModel();
WidgetBuilder statelessBuilder;
void main() {
  Models.add(numberModel);
  statelessBuilder = PureMvc.eventBuilder(["counter"], (c) {
    return StatelessDemo(
      title: 'Flutter Demo Home Page',
      counter: numberModel.counter,
    );
  });
  runApp(MyApp());
}

class NumberModel extends BaseModel {
  @override
  String get name => "number";

  int counter = 0;

  @override
  Future setup() async {
    await Future.delayed(new Duration(seconds: 2));
  }

  @override
  void update(String event, data) {
    if (event == "add") {
      add();
    }
  }

  void add() {
    ++counter;
    notify("counter", counter);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StatefulDemo(
        title: 'Flutter Demo Home Page',
        counter: numberModel.counter,
      ),
    );
  }
}

class StatefulDemo extends StatefulWidget {
  final int counter;

  StatefulDemo({Key key, this.title, this.counter}) : super(key: key);
  final String title;

  @override
  _StatefulDemoState createState() => _StatefulDemoState();
}

class StatelessDemo extends StatelessWidget {
  int counter;
  String title;

  StatelessDemo({this.counter, this.title});

  void _incrementCounter() {
    dispatch("number/add");
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

class _StatefulDemoState extends ObserverState<StatefulDemo> {
  int _counter;
  @override
  void initState() {
    _counter = widget.counter;
    bind("counter", onCounter);
    super.initState();
  }

  void onCounter(int counter) {
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
              'Model is setting up,so if you click button quickly,it looks like not working',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            new RaisedButton(
              onPressed: () {
                Navigator.push(
                    context, new MaterialPageRoute(builder: statelessBuilder));
              },
              child: new Text("Stateless"),
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
