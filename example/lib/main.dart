import 'package:example/models.dart';
import 'package:example/pages/home.dart';
import 'package:example/pages/statfuldmo.dart';
import 'package:example/routers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
      routes: routers,
    );
  }
}
