import 'package:example/models.dart';
import 'package:example/pages/statfuldmo.dart';
import 'package:example/pages/statlessdemo.dart';
import 'package:flutter/material.dart';
import 'package:fpuremvc/fpuremvc.dart';

Map<String, WidgetBuilder> routers = {
  /// 定义个WidgetBuild,在监听到通知number/*@ok的时候重建， * 为通配符
  "stateless": (c) {
    return new EventListener(
        event: ["number/*"],
        builder: (c) {
          return StatelessDemo(
            counter: numberModel.counter,
          );
        });
  },

  "stateful": (c) {
    return StatefulDemo(
      counter: numberModel.counter,
    );
  }
};
