import 'dart:math';
import 'package:flutter/material.dart';

class FloatingWidget extends StatefulWidget {
  final Widget child;
  final double amplitude; // Vertical distance
  final Duration duration;
  final Duration delay;
  final bool isHorizontal;

  const FloatingWidget({
    super.key,
    required this.child,
    this.amplitude = 10.0,
    this.duration = const Duration(seconds: 3),
    this.delay = Duration.zero,
    this.isHorizontal = false,
  });

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Randomize initial phase slightly to avoid robotic uniformity if delay is same
    final randomOffset = Random().nextDouble();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward(from: randomOffset); // Start at random phase
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final offset = _animation.value * widget.amplitude;
        return Transform.translate(
          offset: widget.isHorizontal ? Offset(offset, 0) : Offset(0, offset),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
