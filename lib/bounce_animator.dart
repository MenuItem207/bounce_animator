library bounce_animator;

import 'dart:async';

import 'package:flutter/material.dart';

// handles the animation of child when pressed
class BounceAnimator extends StatefulWidget {
  final Widget child;
  final Function onPressed;
  final Function onLongPress;
  final Duration duration;
  final double scale;
  const BounceAnimator(
      {Key? key,
      required this.child,
      required this.onPressed,
      required this.onLongPress,
      this.duration = const Duration(milliseconds: 225),
      this.scale = 0.8})
      : super(key: key);

  @override
  State<BounceAnimator> createState() => _BounceAnimatorState();
}

class _BounceAnimatorState extends State<BounceAnimator>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 15),
    lowerBound: 0.0,
    upperBound: 0.1,
    vsync: this,
  )..addListener(() {
      setState(() {});
    });

  double _scale = 1;

  bool pressed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - (_controller.value * widget.scale);
    return GestureDetector(
      onTap: () async {
        if (mounted) {
          setState(() {
            _controller.forward();
          });
        }
        await Future.delayed(const Duration(milliseconds: 120));
        if (mounted) {
          setState(() {
            _controller.reverse();
          });
        }
      },
      onTapDown: (details) {
        setState(() {
          pressed = true;
          _controller.forward();
          startTimeout();
        });
      },
      onTapUp: (details) {
        setState(() {
          if (pressed) {
            widget.onPressed();
          }
          pressed = false;
          _controller.reverse();
        });
      },
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }

  Timer startTimeout() {
    var duration = const Duration(milliseconds: 500);
    return Timer(duration, handleTimeout);
  }

  void handleTimeout() {
    // callback function
    if (pressed) {
      // if still pressed after 2 seconds
      widget.onLongPress();
      pressed = false;
    }
  }
}