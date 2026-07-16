import 'package:flutter/material.dart';

/// Concentric rings that expand outward and fade, looping — placed behind
/// the splash screen icon to suggest a droplet's ripple spreading outward.
class RippleRings extends StatefulWidget {
  const RippleRings({super.key, this.size = 180, this.color = Colors.white});

  final double size;
  final Color color;

  @override
  State<RippleRings> createState() => _RippleRingsState();
}

class _RippleRingsState extends State<RippleRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _RingsPainter(
              progress: _controller.value,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  static const _ringCount = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    for (var i = 0; i < _ringCount; i++) {
      final t = (progress + i / _ringCount) % 1.0;
      final radius = maxRadius * t;
      final opacity = (1 - t) * 0.5;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
