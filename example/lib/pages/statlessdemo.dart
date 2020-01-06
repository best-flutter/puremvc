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
