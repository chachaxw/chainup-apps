

class NetEvent {
  NetEventState state;

  NetEvent(this.state);
}
enum NetEventState {
  connect,
  noConnect,
}

class WsNetEvent {
  WsNetEventState state;

  WsNetEvent(this.state);
}
enum WsNetEventState {
  connect,
  noConnect,
}


