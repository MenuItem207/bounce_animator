library bounce_animator;

import 'dart:async';

import 'package:flutter/material.dart';

class BounceAnimator extends StatefulWidget {
  final Widget child;
  final Function onPressed;
  final Function onLongPress;

  // TODO: refactor / rephrase label since this is currently called onTapUp even if just tapped
  final Function onLongPressTapUp;

  final Duration duration;
  final double scale;
  const BounceAnimator(
      {Key? key,
      required this.child,
      this.onPressed = _dummyFunction,
      this.onLongPress = _dummyFunction,
      this.onLongPressTapUp = _dummyFunction,
      this.duration = const Duration(milliseconds: 225),
      this.scale = 0.8})
      : super(key: key);

  @override
  State<BounceAnimator> createState() => _BounceAnimatorState();

  /// used as a placeholder for optional function parameters
  static void _dummyFunction() {}
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
        onComplete();
        widget.onLongPressTapUp();
      },
      onTapCancel: () {
        onComplete();
        widget.onLongPressTapUp();
      },
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }

  /// starts the timeout for the long press
  Timer startTimeout() {
    var duration = const Duration(milliseconds: 500);
    return Timer(duration, handleTimeout);
  }

  /// callback function
  void handleTimeout() {
    if (pressed) {
      // if still pressed after 2 seconds
      widget.onLongPress();
      pressed = false;
    }
  }

  /// on longPress complete
  void onComplete() {
    setState(() {
      if (pressed) {
        widget.onPressed();
      }
      pressed = false;
      _controller.reverse();
    });
  }
}
