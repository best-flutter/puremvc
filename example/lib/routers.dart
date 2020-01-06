import 'package:example/models.dart';
import 'package:example/pages/statfuldmo.dart';
import 'package:example/pages/statlessdemo.dart';
import 'package:flutter/material.dart';
import 'package:fpuremvc/fpuremvc.dart';

Map<String, WidgetBuilder> routers = {
  /// 定义个WidgetBuild,在监听到通知number/*@ok的时候重建， * 为通配符
  "stateless": PureMvc.eventBuilder(["number/*@ok"], (c) {
    return StatelessDemo(
      counter: numberModel.counter,
    );
  }),

  "stateful": (c) {
    return StatefulDemo(
      counter: numberModel.counter,
    );
  }
};
