import 'package:flutter/material.dart';
import '../constants/icon_constant.dart';

class RewardLiveIcon extends StatefulWidget {
  const RewardLiveIcon({super.key});

  @override
  State<RewardLiveIcon> createState() => _RewardLiveIconState();
}

class _RewardLiveIconState extends State<RewardLiveIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value),
            child: ExIcon.timedRewardLight(),
          );
        },
      ),
    );
  }
}
