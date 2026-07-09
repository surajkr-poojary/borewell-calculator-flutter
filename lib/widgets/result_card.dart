import 'package:flutter/material.dart';

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
                Text(breakdownLabel, style: theme.textTheme.titleLarge),
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
                        Text(item.rangeLabel, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          '${item.units} × ${CurrencyFormatter.format(item.rate)}',
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
            Text(totalLabel, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.format(result.totalAmount),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
