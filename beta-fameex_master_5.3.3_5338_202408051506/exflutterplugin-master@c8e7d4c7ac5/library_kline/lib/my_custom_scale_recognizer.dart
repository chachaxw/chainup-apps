import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MyCustomScaleRecognizer extends ScaleGestureRecognizer {
  var _pointers = [];


  @override
  void acceptGesture(int pointer) {

    if(_pointers.length<2){
      super.rejectGesture(pointer);
    }else{
      super.acceptGesture(pointer);
    }
  }

  @override
  void rejectGesture(int pointer) {
    //强制宣布成功
    print("MyCustomScaleRecognizer rejectGesture>>>$_pointers");
    if(_pointers.length>1){
      super.acceptGesture(pointer);
    }else{
      super.rejectGesture(pointer);
      clearPointers();
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    super.handleEvent(event);
    print("handleEvent>>>_pointers=$_pointers");
    if (event is PointerDownEvent) {
      addNewPointer(event.pointer);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      clearPointers();
    }
  }

  void addNewPointer(int pointer){
    print("addNewPointer>>>加入手指$pointer");
    _pointers.add(pointer);
  }

  void clearPointers(){
    print("clearPointers>>>清除手指");
    _pointers.clear();
  }

  int getPointers(){
    return _pointers.length;
  }

}