import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/bill_result.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

/// Displays the calculated bill breakdown: one row per slab used, followed
/// by a bold, larger total.
class ResultCard extends StatelessWidget {
  final BillResult result;
  final String breakdownLabel;
  final String totalLabel;

  const ResultCard({
    super.key,
    required this.result,
    required this.breakdownLabel,
    required this.totalLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(breakdownLabel,
                      style: theme.textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final item in result.items) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.label, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          item.quantity != null && item.rate != null
                              ? '${item.quantity}${item.unit != null ? ' ${item.unit}' : ''} × ${CurrencyFormatter.format(item.rate!)}'
                              : l10n.fixedChargeDetail,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(item.amount),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
            ],
            _TotalAmountBand(label: totalLabel, amount: result.totalAmount),
          ],
        ),
      ),
    );
  }
}

/// The total-amount row, with a subtle rising-water wave animating behind
/// the figure whenever it changes — a "tank filling up" cue that ties the
/// final number back to the app's water theme.
class _TotalAmountBand extends StatefulWidget {
  const _TotalAmountBand({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  State<_TotalAmountBand> createState() => _TotalAmountBandState();
}

class _TotalAmountBandState extends State<_TotalAmountBand>
    with TickerProviderStateMixin {
  late final AnimationController _waveController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();
  late final AnimationController _fillController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final Animation<double> _fillAnimation = CurvedAnimation(
    parent: _fillController,
    curve: Curves.easeOutCubic,
  );

  @override
  void didUpdateWidget(covariant _TotalAmountBand oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _fillController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: AppColors.green.withValues(alpha: 0.06),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_waveController, _fillAnimation]),
                builder: (context, _) => CustomPaint(
                  painter: _RisingWavePainter(
                    phase: _waveController.value * 2 * math.pi,
                    fillLevel: _fillAnimation.value * 0.6,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.label, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(widget.amount),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RisingWavePainter extends CustomPainter {
  _RisingWavePainter({required this.phase, required this.fillLevel});

  final double phase;
  final double fillLevel;

  static const _waveBack = Color(0x1A2F855A);
  static const _waveFront = Color(0x332F855A);

  @override
  void paint(Canvas canvas, Size size) {
    _drawWave(canvas, size, phase, _waveBack, size.height * 0.05);
    _drawWave(canvas, size, phase + math.pi / 2, _waveFront, size.height * 0.07);
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    double wavePhase,
    Color color,
    double amplitude,
  ) {
    final baseline = size.height * (1 - fillLevel);
    final path = Path()..moveTo(0, baseline);
    const step = 6.0;
    for (double x = 0; x <= size.width; x += step) {
      final y = baseline +
          amplitude * math.sin((x / size.width * 2 * math.pi) + wavePhase);
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _RisingWavePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.fillLevel != fillLevel;
}
