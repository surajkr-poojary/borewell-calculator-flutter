import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/bill_result.dart';
import '../models/drilling_rate_band.dart';
import '../models/fixed_charges.dart';
import '../utils/currency_formatter.dart';

/// Reasons [BillProvider.calculate] can fail. The UI maps each to a
/// localized message, since this provider has no [BuildContext] of its own.
enum DepthError { empty, invalid, casingEmpty, invalidCasing, missingCasingRate }

const double defaultBaseRate = 100;

/// Central state holder for the calculator: the selected base drilling
/// rate, optional casing feet/rate, the persisted fixed charges
/// (COLLAR/WELDING/CUTTING/CAP), and the last calculated bill.
class BillProvider extends ChangeNotifier {
  static const _prefsKey = 'fixed_charges_v1';

  double baseRate = defaultBaseRate;
  double? casingRate;

  FixedCharges fixedCharges = FixedCharges.defaults();
  FixedCharges _savedFixedCharges = FixedCharges.defaults();
  bool _isLoaded = false;

  /// Bumped whenever session state is reset wholesale so the UI can key its
  /// input widgets fresh instead of trying to sync stale local text state.
  int version = 0;

  DepthError? depthError;
  BillResult? result;

  FixedCharges get savedFixedCharges => _savedFixedCharges;
  bool get isLoaded => _isLoaded;

  /// Loads previously saved fixed charges (if any) from SharedPreferences.
  Future<void> loadDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      try {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        _savedFixedCharges = FixedCharges.fromJson(decoded);
      } catch (_) {
        // Corrupt or unexpected data: keep the factory defaults.
      }
    }
    fixedCharges = _savedFixedCharges;
    _isLoaded = true;
    version++;
    notifyListeners();
  }

  /// Persists [newCharges] as the fixed charges for future bills and
  /// applies them to the current session immediately.
  Future<void> saveFixedCharges(FixedCharges newCharges) async {
    _savedFixedCharges = newCharges;
    fixedCharges = newCharges;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_savedFixedCharges.toJson()));
    version++;
    notifyListeners();
  }

  void selectBaseRate(double rate) {
    baseRate = rate;
    notifyListeners();
  }

  void selectCasingRate(double rate) {
    casingRate = rate;
    notifyListeners();
  }

  /// Validates the given depth/casing text and current rates, then computes
  /// the bill breakdown. Errors are exposed via [depthError].
  void calculate(String depthInput, String casingFeetInput) {
    depthError = null;
    result = null;

    final trimmedDepth = depthInput.trim();
    if (trimmedDepth.isEmpty) {
      depthError = DepthError.empty;
      notifyListeners();
      return;
    }

    final depth = int.tryParse(trimmedDepth);
    if (depth == null || depth <= 0) {
      depthError = DepthError.invalid;
      notifyListeners();
      return;
    }

    final trimmedCasing = casingFeetInput.trim();
    if (trimmedCasing.isEmpty) {
      depthError = DepthError.casingEmpty;
      notifyListeners();
      return;
    }

    final casingFeet = int.tryParse(trimmedCasing);
    if (casingFeet == null || casingFeet <= 0) {
      depthError = DepthError.invalidCasing;
      notifyListeners();
      return;
    }

    if (casingRate == null) {
      depthError = DepthError.missingCasingRate;
      notifyListeners();
      return;
    }

    final drillingItems = <BillBreakdownItem>[];
    for (final band in depthRateBands) {
      final upper = band.maxDepth == null
          ? depth
          : (depth < band.maxDepth! ? depth : band.maxDepth!);
      final units = upper - band.minDepth;
      if (units <= 0) continue;

      final rate = baseRate + band.addOn;
      final amount = units * rate;
      final rangeStart = band.minDepth == 0 ? 0 : band.minDepth + 1;
      final rangeLabel = band.maxDepth == null
          ? '$rangeStart ft and above'
          : '$rangeStart - $upper ft';
      drillingItems.add(BillBreakdownItem(
        label: rangeLabel,
        quantity: units,
        rate: rate,
        amount: amount,
      ));
    }

    final otherItems = <BillBreakdownItem>[
      BillBreakdownItem(
        label: 'Casing (GI)',
        quantity: casingFeet,
        rate: casingRate!,
        amount: casingFeet * casingRate!,
      ),
    ];
    otherItems.addAll([
      BillBreakdownItem(label: 'COLLAR', amount: fixedCharges.collar),
      BillBreakdownItem(label: 'WELDING', amount: fixedCharges.welding),
      BillBreakdownItem(label: 'CUTTING', amount: fixedCharges.cutting),
      BillBreakdownItem(label: 'CAP', amount: fixedCharges.cap),
    ]);

    final total = [...drillingItems, ...otherItems]
        .fold<double>(0, (sum, item) => sum + item.amount);

    result = BillResult(
      totalDepth: depth,
      baseRate: baseRate,
      casingFeet: casingFeet,
      casingRate: casingRate,
      drillingItems: drillingItems,
      otherItems: otherItems,
      totalAmount: total,
    );
    notifyListeners();
  }

  /// Clears the current inputs, result, and error, and reverts working
  /// rates back to their defaults.
  void reset() {
    depthError = null;
    result = null;
    baseRate = defaultBaseRate;
    casingRate = null;
    fixedCharges = _savedFixedCharges;
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

    for (final item in [...r.drillingItems, ...r.otherItems]) {
      final detail = item.quantity != null && item.rate != null
          ? '${item.quantity} ft × ${CurrencyFormatter.format(item.rate!)}'
          : CurrencyFormatter.format(item.amount);
      buffer
        ..writeln(item.label)
        ..writeln('$detail = ${CurrencyFormatter.format(item.amount)}')
        ..writeln('-------------------');
    }

    buffer.writeln();
    buffer.write('${l10n.totalAmount}: ${CurrencyFormatter.format(r.totalAmount)}');
    return buffer.toString();
  }
}
