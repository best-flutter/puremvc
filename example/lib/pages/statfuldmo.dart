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
            onPressed: () => dispatch("number/add"),
            child: new Text("Sync increment"),
          ),
          new RaisedButton(
            onPressed: () => dispatch("number/asyncAdd"),
            child: new Text("Async increment"),
          ),
        ],
      ),
    );
  }
}
