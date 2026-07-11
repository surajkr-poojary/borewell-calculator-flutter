import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/default_rates.dart';
import '../models/drilling_rate_band.dart';
import '../models/fixed_charges.dart';
import '../providers/bill_provider.dart';
import '../widgets/large_button.dart';
import '../widgets/rate_picker_field.dart';
import '../widgets/responsive_center.dart';

/// Lets the user edit the default base/casing rates (pre-selected on every
/// new bill) and the per-unit rates for COLLAR/WELDING/CUTTING/CAP. Saving
/// persists everything via SharedPreferences so it's used the next time
/// the app opens.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _selectedBaseRate;
  late double _selectedCasingRate;
  late final TextEditingController _collarController;
  late final TextEditingController _weldingController;
  late final TextEditingController _cuttingController;
  late final TextEditingController _capController;
  String? _error;

  @override
  void initState() {
    super.initState();
    final provider = context.read<BillProvider>();
    final rates = provider.savedDefaultRates;
    _selectedBaseRate = rates.baseRate;
    _selectedCasingRate = rates.casingRate;

    final charges = provider.savedFixedCharges;
    _collarController = TextEditingController(
      text: charges.collar.toStringAsFixed(0),
    );
    _weldingController = TextEditingController(
      text: charges.welding.toStringAsFixed(0),
    );
    _cuttingController = TextEditingController(
      text: charges.cutting.toStringAsFixed(0),
    );
    _capController = TextEditingController(
      text: charges.cap.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _collarController.dispose();
    _weldingController.dispose();
    _cuttingController.dispose();
    _capController.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (_selectedBaseRate <= 0 || _selectedCasingRate <= 0) {
      setState(() => _error = l10n.invalidDefaultRates);
      return;
    }

    final values = <double>[];
    for (final controller in [
      _collarController,
      _weldingController,
      _cuttingController,
      _capController,
    ]) {
      final rate = double.tryParse(controller.text.trim());
      if (controller.text.trim().isEmpty || rate == null || rate < 0) {
        setState(() => _error = l10n.invalidFixedCharges);
        return;
      }
      values.add(rate);
    }

    setState(() => _error = null);
    final provider = context.read<BillProvider>();
    await provider.saveDefaultRates(
      DefaultRates(
        baseRate: _selectedBaseRate,
        casingRate: _selectedCasingRate,
      ),
    );
    await provider.saveFixedCharges(
      FixedCharges(
        collar: values[0],
        welding: values[1],
        cutting: values[2],
        cap: values[3],
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.fixedChargesSaved)));
    Navigator.of(context).pop();
  }

  Widget _chargeField(String label, TextEditingController controller) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          prefixText: '₹ ',
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.6,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editFixedCharges)),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.defaultRatesHeading, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.sell_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.defaultRatesHint,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RatePickerField(
              label: l10n.defaultBaseRateLabel,
              icon: Icons.speed_outlined,
              options: baseDrillingRateOptions,
              value: _selectedBaseRate,
              placeholder: l10n.selectRateHint,
              customOptionLabel: l10n.customOption,
              customRateLabel: l10n.customRateLabel,
              onSelected: (rate) => setState(() => _selectedBaseRate = rate),
            ),
            const SizedBox(height: 16),
            RatePickerField(
              label: l10n.defaultCasingRateLabel,
              icon: Icons.plumbing_outlined,
              options: casingRateOptions,
              value: _selectedCasingRate,
              placeholder: l10n.selectCasingRateHint,
              customOptionLabel: l10n.customOption,
              customRateLabel: l10n.customRateLabel,
              onSelected: (rate) => setState(() => _selectedCasingRate = rate),
            ),
            const SizedBox(height: 28),
            Text(l10n.itemRatesHeading, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.fixedChargesHint,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _chargeField(l10n.collarLabel, _collarController),
            _chargeField(l10n.weldingLabel, _weldingController),
            _chargeField(l10n.cuttingLabel, _cuttingController),
            _chargeField(l10n.capLabel, _capController),
            if (_error != null) ...[
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
            ],
            LargeButton(
              label: l10n.save,
              icon: Icons.save_outlined,
              onPressed: () => _save(l10n),
            ),
          ],
        ),
      ),
    );
  }
}
