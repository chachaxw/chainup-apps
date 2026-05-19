import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MyCustomHorizontalRecognizer extends HorizontalDragGestureRecognizer {


  @override
  void acceptGesture(int pointer) {
      print("横向acceptGesture");
      super.acceptGesture(pointer);
  }

  @override
  void rejectGesture(int pointer) {
      print("横向rejectGesture");
      super.rejectGesture(pointer);
  }


}