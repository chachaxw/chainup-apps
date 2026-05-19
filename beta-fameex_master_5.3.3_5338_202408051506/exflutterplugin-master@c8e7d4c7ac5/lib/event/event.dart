import 'package:event_bus/event_bus.dart';

class Event {
  static final EventBus eventBus = new EventBus();
}

class MessageEvent {
  static int klineIndexChange = 1;
  static int klineIndicatorUpdated = 2;
  static int nativeNotifitionEvent = 3;
  static int navigationChange = 4;
  dynamic msg_content = null;
  String? pageName;
  int msg_type = -1;

  MessageEvent(this.msg_type, {this.msg_content, this.pageName = ""});
}
