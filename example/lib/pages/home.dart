import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("puremvc demos"),
      ),
      body: new ListView(children: <Widget>[
        HomeItem(
          title: "Simple stateful",
          route: "stateful",
        ),
        HomeItem(
          title: "Simple stateless",
          route: "stateless",
        ),
      ]),
    );
  }
}

class HomeItem extends StatelessWidget {
  final String title;
  final String route;

  HomeItem({this.title, this.route});

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      child: new Padding(
        padding: new EdgeInsets.all(10),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              title,
              style: new TextStyle(fontSize: 18),
            ),
            new Icon(Icons.keyboard_arrow_right)
          ],
        ),
      ),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
