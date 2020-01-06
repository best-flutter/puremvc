import 'package:fpuremvc/fpuremvc.dart';

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
