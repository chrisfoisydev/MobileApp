import 'package:flutter/material.dart';

/// Fades and slides its child up into place, delayed by [index] so that a
/// list of children cascades in one after another.
class CascadeIn extends StatefulWidget {
  const CascadeIn({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<CascadeIn> createState() => _CascadeInState();
}

class _CascadeInState extends State<CascadeIn>
    with SingleTickerProviderStateMixin {
  static const _stepMs = 90;
  static const _animMs = 380;

  late final int _delayMs = widget.index * _stepMs;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _delayMs + _animMs),
  )..forward();
  late final Animation<double> _t = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      _delayMs / (_delayMs + _animMs),
      1,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _t,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.25), end: Offset.zero)
            .animate(_t),
        child: widget.child,
      ),
    );
  }
}
