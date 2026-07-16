import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A circular indicator that fills up with an animated, looping water wave —
/// used on the splash screen while app data loads.
class WaterWaveLoader extends StatefulWidget {
  const WaterWaveLoader({super.key, this.size = 120, this.targetFill = 0.78});

  final double size;
  final double targetFill;

  @override
  State<WaterWaveLoader> createState() => _WaterWaveLoaderState();
}

class _WaterWaveLoaderState extends State<WaterWaveLoader>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _fillController;
  late final Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
    _fillAnimation = CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipOval(
        child: AnimatedBuilder(
          animation: Listenable.merge([_waveController, _fillAnimation]),
          builder: (context, _) {
            return CustomPaint(
              size: Size.square(widget.size),
              painter: _WaterWavePainter(
                phase: _waveController.value * 2 * math.pi,
                fillLevel: _fillAnimation.value * widget.targetFill,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WaterWavePainter extends CustomPainter {
  _WaterWavePainter({required this.phase, required this.fillLevel});

  final double phase;
  final double fillLevel;

  static const _basin = Color(0xFFDDF2EF);
  static const _waveBack = Color(0xFF35B5A6);
  static const _waveFront = Color(0xFF0B6E64);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _basin);
    _drawWave(canvas, size, phase, _waveBack, 0.55, size.height * 0.06);
    _drawWave(
      canvas,
      size,
      phase + math.pi / 2,
      _waveFront,
      0.9,
      size.height * 0.08,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    double wavePhase,
    Color color,
    double opacity,
    double amplitude,
  ) {
    final baseline = size.height * (1 - fillLevel);
    final path = Path()..moveTo(0, baseline);
    const step = 4.0;
    for (double x = 0; x <= size.width; x += step) {
      final y =
          baseline +
          amplitude * math.sin((x / size.width * 2 * math.pi) + wavePhase);
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = color.withValues(alpha: opacity));
  }

  @override
  bool shouldRepaint(covariant _WaterWavePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.fillLevel != fillLevel;
}
