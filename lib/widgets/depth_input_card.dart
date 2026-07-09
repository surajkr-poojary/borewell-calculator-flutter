import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The "Total Depth" entry field, styled like a calculator display so it
/// reads as the app's primary input at a glance.
class DepthInputCard extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final String label;
  final String unit;

  const DepthInputCard({
    super.key,
    required this.controller,
    required this.errorText,
    required this.label,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.straighten_rounded,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(label, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 30),
              decoration: InputDecoration(
                hintText: '0',
                suffixText: unit,
                suffixStyle: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 6),
              Text(
                errorText!,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
