import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/currency_formatter.dart';

/// Sentinel used only to identify "Custom, not yet entered" — quantities
/// are never negative, so this can't collide with a real count (including
/// the valid preset `0`).
const int _customSentinel = -1;

const List<int> _presetQuantities = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

/// A tappable field that opens a bottom sheet (or, on web, an anchored
/// dropdown) listing quantities 0–10 plus a "Custom" entry that reveals an
/// inline text field for typing an arbitrary count. Used for the
/// piece-priced Additional Charges (COLLAR/WELDING/CUTTING/CAP), labelled
/// with the item's current per-unit rate so the user knows the price
/// while picking a count.
class QuantityRateField extends StatefulWidget {
  final int? value;
  final String label;
  final IconData icon;
  final double rate;
  final String perUnitSuffix;
  final String piecesUnit;
  final String customOptionLabel;
  final String customQtyLabel;
  final ValueChanged<int> onChanged;

  const QuantityRateField({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.rate,
    required this.perUnitSuffix,
    required this.piecesUnit,
    required this.customOptionLabel,
    required this.customQtyLabel,
    required this.onChanged,
  });

  @override
  State<QuantityRateField> createState() => _QuantityRateFieldState();
}

class _QuantityRateFieldState extends State<QuantityRateField> {
  late final TextEditingController _customController;

  bool get _isCustom =>
      widget.value != null && !_presetQuantities.contains(widget.value);

  String get _fieldLabel =>
      '${widget.label} (${CurrencyFormatter.format(widget.rate)}${widget.perUnitSuffix})';

  @override
  void initState() {
    super.initState();
    final initialText = _isCustom && widget.value! >= 0
        ? widget.value!.toString()
        : '';
    _customController = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

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
                  child: Text(_fieldLabel, style: theme.textTheme.titleMedium),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final option in _presetQuantities)
                      ListTile(
                        leading: const Icon(Icons.numbers_rounded),
                        title: Text('$option ${widget.piecesUnit}'),
                        trailing: widget.value == option
                            ? Icon(
                                Icons.check_rounded,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          widget.onChanged(option);
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(widget.customOptionLabel),
                      trailing: _isCustom
                          ? Icon(
                              Icons.check_rounded,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        if (!_isCustom) widget.onChanged(_customSentinel);
                      },
                    ),
                  ],
                ),
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
    return DropdownButtonFormField<int>(
      initialValue: _isCustom ? _customSentinel : widget.value,
      decoration: InputDecoration(
        labelText: _fieldLabel,
        prefixIcon: Icon(widget.icon),
      ),
      hint: const Text('0'),
      icon: const Icon(Icons.expand_more_rounded),
      items: [
        for (final option in _presetQuantities)
          DropdownMenuItem(
            value: option,
            child: Text('$option ${widget.piecesUnit}'),
          ),
        DropdownMenuItem(
          value: _customSentinel,
          child: Text(widget.customOptionLabel),
        ),
      ],
      onChanged: (selected) {
        if (selected == null) return;
        if (selected == _customSentinel) {
          if (!_isCustom) widget.onChanged(_customSentinel);
        } else {
          widget.onChanged(selected);
        }
      },
    );
  }

  Widget _buildPickerField(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openPicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: _fieldLabel,
          prefixIcon: Icon(widget.icon),
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        child: Text(
          _isCustom
              ? widget.customOptionLabel
              : '${widget.value ?? 0} ${widget.piecesUnit}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = kIsWeb
        ? _buildWebDropdown(context)
        : _buildPickerField(context);
    if (!_isCustom) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        const SizedBox(height: 12),
        TextField(
          controller: _customController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: widget.customQtyLabel,
            suffixText: widget.piecesUnit,
          ),
          onChanged: (text) {
            final parsed = int.tryParse(text.trim());
            widget.onChanged(parsed ?? _customSentinel);
          },
        ),
      ],
    );
  }
}
