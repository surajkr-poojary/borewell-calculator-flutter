import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../utils/currency_formatter.dart';

/// A tappable field that opens a bottom sheet listing [options] (₹ per ft)
/// and reports the chosen value. Used for both the base drilling rate and
/// the casing (GI) rate pickers.
class RatePickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<double> options;
  final double? value;
  final String placeholder;
  final ValueChanged<double> onSelected;

  const RatePickerField({
    super.key,
    required this.label,
    required this.icon,
    required this.options,
    required this.value,
    required this.placeholder,
    required this.onSelected,
  });

  Future<void> _openPicker(BuildContext context) {
    final theme = Theme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(label, style: theme.textTheme.titleMedium),
                ),
              ),
              for (final option in options)
                ListTile(
                  leading: const Icon(Icons.sell_outlined),
                  title: Text('${CurrencyFormatter.format(option)} / ft'),
                  trailing: value == option
                      ? Icon(
                          Icons.check_rounded,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onSelected(option);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// On web, an anchored dropdown menu reads far more naturally than a
  /// mobile-style bottom sheet sliding up over the page.
  Widget _buildWebDropdown(BuildContext context) {
    return DropdownButtonFormField<double>(
      initialValue: value,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      hint: Text(placeholder),
      icon: const Icon(Icons.expand_more_rounded),
      items: [
        for (final option in options)
          DropdownMenuItem(
            value: option,
            child: Text('${CurrencyFormatter.format(option)} / ft'),
          ),
      ],
      onChanged: (selected) {
        if (selected != null) onSelected(selected);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return _buildWebDropdown(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openPicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        child: Text(
          value != null
              ? '${CurrencyFormatter.format(value!)} / ft'
              : placeholder,
        ),
      ),
    );
  }
}
