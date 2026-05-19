import 'package:flutter/material.dart';

class BaseGestureCapture extends StatelessWidget {
  final Widget child;
  final PointerCancelEventListener? onPointerCancel;
  final PointerDownEventListener? onPointerDown;
  final PointerMoveEventListener? onPointerMove;
  final PointerUpEventListener? onPointerUp;

  const BaseGestureCapture(
      {required this.child,
      this.onPointerDown,
      this.onPointerUp,
      this.onPointerMove,
      this.onPointerCancel,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        onPointerDown?.call(event);
      },
      onPointerCancel: (event) {
        onPointerCancel?.call(event);
      },
      onPointerMove: (event) {
        onPointerMove?.call(event);
      },
      onPointerUp: (event) {
        onPointerUp?.call(event);
      },
      child: child,
    );
  }
}
