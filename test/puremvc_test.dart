import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpuremvc/fpuremvc.dart';


class NetworkError extends Error{


}
class TestModel2 extends BaseModel{
  @override
  String get name => "test2";

  @override
  Future setup() {
    throw new NetworkError();
  }

}
class TestModel1 extends BaseModel{
  @override
  String get name => "test1";

  @override
  Future setup() {
    throw new Exception("test1");
  }

}


class TestModel3 extends BaseModel{

  int number=0;

  @override
  String get name => "test3";

  @override
  update(String event, data) {
    if(event == 'add'){
      number= data['a']+data['b'];
      return number;
    }else if(event=='addAsync'){
      return addAsync(data['a'],data['b']);
    }
  }

  addAsync(a, b) async {
    return a+b;
  }





}


class TestModel4 extends BaseModel{

  @override
  String get name => "test4";

  @override
  Future setup() {
    return Future.delayed(new Duration(milliseconds: 200));
  }

  @override
  update(String event, data) {
    if(event == 'add'){
      return data['a']+data['b'];
    }
  }
}

void main() {
  test('Test setup error', () async {

    PureMvc.setGlobalErrorHandler((e){

     // expect( (e is Exception ) && e.toString()=='Exception: test1'  , true);

      return false;
    });

    Completer comparator = new Completer();

    PureMvc.bind("test1/setup@fail",  (e){
      print(e);
      comparator.complete(e);
    });

    TestModel1 testModel1 = new TestModel1();
    return comparator.future.whenComplete((){
      PureMvc.remove(testModel1);
    });

  });




  test('Test setup custom error', () async {

    PureMvc.setGlobalErrorHandler((e){

      print("global error handler");
      expect( (e is NetworkError )  , true);

      return true;
    });

    Completer comparator = new Completer();

    PureMvc.bind("test2/setup@fail",  (e){
      print(e);
      comparator.complete(e);
    });

    TestModel2 testModel2 = new TestModel2();
    return comparator.future.whenComplete((){
      PureMvc.remove(testModel2);
    });

  });


  test('Test sync', () {
    PureMvc.setGlobalErrorHandler((e){


      return false;
    });

    Completer comparator = new Completer();

    PureMvc.bind("test3/add@ok",  (e){
      print(e);
      comparator.complete(e);
    });

    TestModel3 testModel3 = new TestModel3();
    dispatch("test3/add",{"a":1,"b":2});
    return comparator.future.whenComplete((){
      PureMvc.remove(testModel3);
      PureMvc.unbind(event:"test3/add@ok" );
      expect(PureMvc.hasListener("test3/add@ok"), false);
    });
  });


  test('Test async', () {

    PureMvc.setGlobalErrorHandler((e){


      return false;
    });
    Completer comparator = new Completer();

    PureMvc.bind("test3/addAsync@ok",  (e){
      print(e);
      comparator.complete(e);
    });

    TestModel3 testModel3 = new TestModel3();
    dispatch("test3/addAsync",{"a":1,"b":2});
    return comparator.future.whenComplete((){
      PureMvc.remove(testModel3);
      PureMvc.unbind(event:"test3/addAsync@ok" );
    });

  });


  test('Test async setup', () {

    PureMvc.setGlobalErrorHandler((e){


      return false;
    });
    Completer comparator = new Completer();

    PureMvc.bind("test4/add@ok",  (e){
      print(e);
      comparator.complete(e);
    });

    TestModel4 testModel4 = new TestModel4();
    dispatch("test4/add",{"a":1,"b":2});
    return comparator.future.whenComplete((){
      PureMvc.remove(testModel4);
    });
  });


  testWidgets('Test bind event in widget', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    PureMvc.setGlobalErrorHandler((e){


      return false;
    });
    TestModel3 testModel3 = new TestModel3();
    await tester.pumpWidget(MaterialApp(
        home: TestWidget4(
            )));

    expect(find.text("3", skipOffstage: true), findsOneWidget);

    PureMvc.remove(testModel3);
  });


}

class TestWidget4 extends StatefulWidget {
  @override
  _TestWidget4State createState() => _TestWidget4State();
}

class _TestWidget4State extends ObserverState<TestWidget4> {

  int value = 0;

  @override
  void initState() {
    bind("test3/add@ok", (int value){
      this.value = value;
    });
   dispatch("test3/add",{"a":1,"b":2});
   //dispatch("test3/add",{"a":1,"b":2});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("$value"),
    );
  }
}
