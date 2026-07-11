import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A thin, looping wave strip placed under the home screen's [AppBar] via
/// its `bottom` slot, so the header edge feels like water instead of a
/// flat line.
class WaveAppBarBottom extends StatefulWidget implements PreferredSizeWidget {
  const WaveAppBarBottom({super.key, this.height = 14});

  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<WaveAppBarBottom> createState() => _WaveAppBarBottomState();
}

class _WaveAppBarBottomState extends State<WaveAppBarBottom>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _WaveStripPainter(phase: _controller.value * 2 * math.pi),
      ),
    );
  }
}

class _WaveStripPainter extends CustomPainter {
  _WaveStripPainter({required this.phase});

  final double phase;

  static const _back = Color(0x40FFFFFF);
  static const _front = Color(0x66FFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    _drawLayer(canvas, size, phase, _back, size.height * 0.22);
    _drawLayer(canvas, size, phase + math.pi / 2, _front, size.height * 0.3);
  }

  void _drawLayer(
    Canvas canvas,
    Size size,
    double wavePhase,
    Color color,
    double amplitude,
  ) {
    final baseline = amplitude;
    final path = Path()..moveTo(0, baseline);
    const step = 6.0;
    for (double x = 0; x <= size.width; x += step) {
      final y = baseline +
          amplitude * math.sin((x / size.width * 4 * math.pi) + wavePhase);
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WaveStripPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
