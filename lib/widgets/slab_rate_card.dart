import 'package:flutter/material.dart';

import '../models/rate_slab.dart';
import '../utils/currency_formatter.dart';

/// A card representing one depth slab: its read-only range, a rate
/// dropdown (preset values + "Custom"), and a custom-amount field that
/// appears when "Custom" is selected.
class SlabRateCard extends StatefulWidget {
  final RateSlab slab;
  final String rateLabel;
  final String customOptionLabel;
  final String customRateLabel;
  final ValueChanged<double> onPresetSelected;
  final VoidCallback onCustomSelected;
  final ValueChanged<double> onCustomChanged;

  const SlabRateCard({
    super.key,
    required this.slab,
    required this.rateLabel,
    required this.customOptionLabel,
    required this.customRateLabel,
    required this.onPresetSelected,
    required this.onCustomSelected,
    required this.onCustomChanged,
  });

  @override
  State<SlabRateCard> createState() => _SlabRateCardState();
}

class _SlabRateCardState extends State<SlabRateCard> {
  late final TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    final initialText =
        widget.slab.isCustom && widget.slab.rate > 0
            ? widget.slab.rate.toStringAsFixed(0)
            : '';
    _customController = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slab = widget.slab;
    final isPresetValue = !slab.isCustom && presetRateOptions.contains(slab.rate);
    final dropdownValue = isPresetValue ? slab.rate : null;

    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              slab.rangeLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<double?>(
              key: ValueKey('dropdown_${slab.index}_$dropdownValue'),
              initialValue: dropdownValue,
              decoration: InputDecoration(
                labelText: widget.rateLabel,
                prefixIcon: const Icon(Icons.sell_outlined),
              ),
              items: [
                ...presetRateOptions.map(
                  (r) => DropdownMenuItem(
                    value: r,
                    child: Text(CurrencyFormatter.format(r)),
                  ),
                ),
                DropdownMenuItem(
                    value: null, child: Text(widget.customOptionLabel)),
              ],
              onChanged: (value) {
                if (value == null) {
                  widget.onCustomSelected();
                } else {
                  widget.onPresetSelected(value);
                }
              },
            ),
            if (slab.isCustom) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(
                  labelText: widget.customRateLabel,
                  prefixText: '₹ ',
                ),
                onChanged: (text) {
                  final parsed = double.tryParse(text.trim());
                  widget.onCustomChanged(parsed ?? 0);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
