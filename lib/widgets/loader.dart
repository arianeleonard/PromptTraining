import 'package:flutter/material.dart';

/// Animated loading indicator for streaming responses.
class Loader extends StatefulWidget {
  final double size;
  const Loader({super.key, this.size = 16});

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2.0 * 3.14159,
            child: Icon(
              Icons.autorenew_rounded,
              size: widget.size,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}
