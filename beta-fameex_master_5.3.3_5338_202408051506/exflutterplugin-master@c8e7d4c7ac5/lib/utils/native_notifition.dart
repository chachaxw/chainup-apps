
import 'package:chainup_flutter_ex/event/event.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/services.dart';

class NativeNotifition {
  NativeNotifition._();

  static final NativeNotifition _instance = NativeNotifition._();

  factory NativeNotifition.getInstance() {
    return _instance;
  }

  final MethodChannel _methodChannel = const MethodChannel("ex.chainup.app/NV");

  // 其他方法和属性
  void init() {
    _methodChannel.setMethodCallHandler((call) async {
      print("_methodChannel>>>setMethodCallHandler"+call.toString());
      Event.eventBus.fire(
          MessageEvent(
              MessageEvent.nativeNotifitionEvent,msg_content: {
                "method":call.method,
                "arguments":call.arguments
              }
          )
      );
    });
  }
}