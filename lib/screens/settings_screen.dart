import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/fixed_charges.dart';
import '../providers/bill_provider.dart';
import '../widgets/large_button.dart';
import '../widgets/responsive_center.dart';

/// Lets the user edit the fixed charges (COLLAR/WELDING/CUTTING/CAP) added
/// to every bill. Saving persists the values via SharedPreferences so
/// they're used the next time the app opens.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _collarController;
  late final TextEditingController _weldingController;
  late final TextEditingController _cuttingController;
  late final TextEditingController _capController;
  String? _error;

  @override
  void initState() {
    super.initState();
    final charges = context.read<BillProvider>().savedFixedCharges;
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
    await context.read<BillProvider>().saveFixedCharges(
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
