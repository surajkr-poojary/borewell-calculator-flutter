import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/rate_slab.dart';
import '../providers/bill_provider.dart';
import '../widgets/large_button.dart';

/// Lets the user edit the default rate for each slab. Saving persists the
/// values via SharedPreferences so they're used the next time the app opens.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final List<TextEditingController> _controllers;
  String? _error;

  @override
  void initState() {
    super.initState();
    final defaults = context.read<BillProvider>().savedDefaults;
    _controllers = defaults
        .map((s) => TextEditingController(text: s.rate.toStringAsFixed(0)))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save(List<RateSlab> defaults, AppLocalizations l10n) async {
    final newDefaults = <RateSlab>[];
    for (var i = 0; i < defaults.length; i++) {
      final text = _controllers[i].text.trim();
      final rate = double.tryParse(text);
      if (text.isEmpty || rate == null || rate <= 0) {
        setState(() => _error = l10n.invalidRateForEverySlab);
        return;
      }
      newDefaults.add(defaults[i].copyWith(rate: rate));
    }

    setState(() => _error = null);
    await context.read<BillProvider>().saveDefaults(newDefaults);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.defaultRatesSaved)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final defaults = context.read<BillProvider>().savedDefaults;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editDefaultRates),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 18, color: theme.colorScheme.primary),
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
          for (var i = 0; i < defaults.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: _controllers[i],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: defaults[i].rangeLabel,
                  prefixText: '₹ ',
                ),
              ),
            ),
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
            onPressed: () => _save(defaults, l10n),
          ),
        ],
      ),
    );
  }
}
