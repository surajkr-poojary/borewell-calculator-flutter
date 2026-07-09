import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/bill_result.dart';
import '../models/rate_slab.dart';
import '../utils/currency_formatter.dart';

/// Reasons [BillProvider.calculate] can fail. The UI maps each to a
/// localized message, since this provider has no [BuildContext] of its own.
enum DepthError { empty, invalid, missingCustomRate }

/// Central state holder for the calculator: current slab rates, the
/// persisted default rates, and the last calculated bill.
class BillProvider extends ChangeNotifier {
  static const _prefsKey = 'default_rate_slabs_v1';

  List<RateSlab> _slabs = defaultRateSlabs();
  List<RateSlab> _savedDefaults = defaultRateSlabs();
  bool _isLoaded = false;

  /// Bumped whenever slab rates are replaced wholesale (load/save/reset) so
  /// the UI can key its rate-input widgets fresh instead of trying to sync
  /// stale local text-field state.
  int version = 0;

  DepthError? depthError;
  BillResult? result;

  List<RateSlab> get slabs => List.unmodifiable(_slabs);
  List<RateSlab> get savedDefaults => List.unmodifiable(_savedDefaults);
  bool get isLoaded => _isLoaded;

  /// Loads previously saved default rates (if any) from SharedPreferences.
  Future<void> loadDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      try {
        final decoded = jsonDecode(jsonStr) as List<dynamic>;
        final loaded = decoded
            .map((e) => RateSlab.fromJson(e as Map<String, dynamic>))
            .toList();
        if (loaded.length == defaultRateSlabs().length) {
          _savedDefaults = loaded;
        }
      } catch (_) {
        // Corrupt or unexpected data: keep the factory defaults.
      }
    }
    _slabs = _savedDefaults.map((s) => s.copyWith()).toList();
    _isLoaded = true;
    version++;
    notifyListeners();
  }

  /// Persists [newDefaults] as the default rates for future app launches
  /// and applies them to the current session immediately.
  Future<void> saveDefaults(List<RateSlab> newDefaults) async {
    _savedDefaults = newDefaults.map((s) => s.copyWith()).toList();
    _slabs = newDefaults.map((s) => s.copyWith()).toList();
    final prefs = await SharedPreferences.getInstance();
    final jsonStr =
        jsonEncode(_savedDefaults.map((s) => s.toJson()).toList());
    await prefs.setString(_prefsKey, jsonStr);
    version++;
    notifyListeners();
  }

  void selectPresetRate(int index, double rate) {
    _slabs[index] = _slabs[index].copyWith(rate: rate);
    notifyListeners();
  }

  /// Switches a slab into "Custom" mode. A rate of 0 marks the field as
  /// empty until the user types a value.
  void switchToCustomRate(int index) {
    _slabs[index] = _slabs[index].copyWith(rate: 0);
    notifyListeners();
  }

  /// Updates a slab's custom rate as the user types. A value of 0 marks
  /// the field as effectively empty for validation purposes.
  void updateCustomRate(int index, double rate) {
    _slabs[index] = _slabs[index].copyWith(rate: rate);
    notifyListeners();
  }

  /// Validates the given depth text and current slab rates, then computes
  /// the bill breakdown. Errors are exposed via [depthError].
  void calculate(String depthInput) {
    depthError = null;
    result = null;

    final trimmed = depthInput.trim();
    if (trimmed.isEmpty) {
      depthError = DepthError.empty;
      notifyListeners();
      return;
    }

    final depth = int.tryParse(trimmed);
    if (depth == null || depth <= 0) {
      depthError = DepthError.invalid;
      notifyListeners();
      return;
    }

    for (final slab in _slabs) {
      if (slab.isCustom && slab.rate <= 0) {
        depthError = DepthError.missingCustomRate;
        notifyListeners();
        return;
      }
    }

    final items = <BillBreakdownItem>[];
    double total = 0;
    for (final slab in _slabs) {
      final upper = slab.maxDepth == null
          ? depth
          : (depth < slab.maxDepth! ? depth : slab.maxDepth!);
      final units = upper - slab.minDepth;
      if (units <= 0) continue;

      final amount = units * slab.rate;
      total += amount;
      final rangeStart = slab.minDepth == 0 ? 0 : slab.minDepth + 1;
      items.add(BillBreakdownItem(
        rangeLabel: '$rangeStart - $upper ft',
        units: units,
        rate: slab.rate,
        amount: amount,
      ));
    }

    result = BillResult(totalDepth: depth, items: items, totalAmount: total);
    notifyListeners();
  }

  /// Clears the current depth, result, and error, and reverts working
  /// rates back to the saved defaults.
  void reset() {
    depthError = null;
    result = null;
    _slabs = _savedDefaults.map((s) => s.copyWith()).toList();
    version++;
    notifyListeners();
  }

  /// Builds a plain-text bill summary suitable for copying or sharing.
  String? buildSummaryText(AppLocalizations l10n) {
    final r = result;
    if (r == null) return null;

    final buffer = StringBuffer()
      ..writeln(l10n.appTitle)
      ..writeln(l10n.pdfTotalDepth(r.totalDepth))
      ..writeln();

    for (final item in r.items) {
      buffer
        ..writeln(item.rangeLabel)
        ..writeln(
            '${item.units} x ${CurrencyFormatter.format(item.rate)} = ${CurrencyFormatter.format(item.amount)}')
        ..writeln('-------------------');
    }

    buffer.writeln();
    buffer.write('${l10n.totalAmount}: ${CurrencyFormatter.format(r.totalAmount)}');
    return buffer.toString();
  }
}
