import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/bill_result.dart';
import '../models/default_rates.dart';
import '../models/drilling_rate_band.dart';
import '../models/fixed_charges.dart';
import '../utils/currency_formatter.dart';

/// Reasons [BillProvider.calculate] can fail. The UI maps each to a
/// localized message, since this provider has no [BuildContext] of its own.
enum DepthError {
  empty,
  invalid,
  invalidBaseRate,
  invalidCasing,
  missingCasingRate,
}

/// Central state holder for the calculator: the selected base drilling
/// rate, casing feet/rate, the persisted default rates and fixed charges
/// (COLLAR/WELDING/CUTTING/CAP), and the last calculated bill.
class BillProvider extends ChangeNotifier {
  static const _fixedChargesPrefsKey = 'fixed_charges_v1';
  static const _defaultRatesPrefsKey = 'default_rates_v1';

  double baseRate = DefaultRates.initial().baseRate;
  double? casingRate;

  DefaultRates _savedDefaultRates = DefaultRates.initial();
  FixedCharges fixedCharges = FixedCharges.defaults();
  FixedCharges _savedFixedCharges = FixedCharges.defaults();
  bool _isLoaded = false;

  /// Bumped whenever session state is reset wholesale so the UI can key its
  /// input widgets fresh instead of trying to sync stale local text state.
  int version = 0;

  DepthError? depthError;
  BillResult? result;

  DefaultRates get savedDefaultRates => _savedDefaultRates;
  FixedCharges get savedFixedCharges => _savedFixedCharges;
  bool get isLoaded => _isLoaded;

  /// Loads previously saved default rates and fixed charges (if any) from
  /// SharedPreferences.
  Future<void> loadDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    final ratesJson = prefs.getString(_defaultRatesPrefsKey);
    if (ratesJson != null) {
      try {
        final decoded = jsonDecode(ratesJson) as Map<String, dynamic>;
        _savedDefaultRates = DefaultRates.fromJson(decoded);
      } catch (_) {
        // Corrupt or unexpected data: keep the factory defaults.
      }
    }
    baseRate = _savedDefaultRates.baseRate;
    casingRate = _savedDefaultRates.casingRate;

    final chargesJson = prefs.getString(_fixedChargesPrefsKey);
    if (chargesJson != null) {
      try {
        final decoded = jsonDecode(chargesJson) as Map<String, dynamic>;
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

  /// Persists [newRates] as the default base/casing rates for future bills
  /// and applies them to the current session immediately.
  Future<void> saveDefaultRates(DefaultRates newRates) async {
    _savedDefaultRates = newRates;
    baseRate = newRates.baseRate;
    casingRate = newRates.casingRate;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _defaultRatesPrefsKey,
      jsonEncode(_savedDefaultRates.toJson()),
    );
    version++;
    notifyListeners();
  }

  /// Persists [newCharges] as the fixed charges for future bills and
  /// applies them to the current session immediately.
  Future<void> saveFixedCharges(FixedCharges newCharges) async {
    _savedFixedCharges = newCharges;
    fixedCharges = newCharges;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _fixedChargesPrefsKey,
      jsonEncode(_savedFixedCharges.toJson()),
    );
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
  /// the bill breakdown. [collarQtyInput]/[weldingQtyInput]/
  /// [cuttingQtyInput]/[capQtyInput] are optional piece counts — each is
  /// billed at its Settings-configured per-unit rate and omitted from the
  /// bill entirely when left blank or zero. Errors are exposed via
  /// [depthError].
  void calculate(
    String depthInput,
    String casingFeetInput, {
    String collarQtyInput = '',
    String weldingQtyInput = '',
    String cuttingQtyInput = '',
    String capQtyInput = '',
  }) {
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
    int? casingFeet;
    if (trimmedCasing.isNotEmpty) {
      casingFeet = int.tryParse(trimmedCasing);
      if (casingFeet == null || casingFeet <= 0) {
        depthError = DepthError.invalidCasing;
        notifyListeners();
        return;
      }

      if (casingRate == null || casingRate! <= 0) {
        depthError = DepthError.missingCasingRate;
        notifyListeners();
        return;
      }
    }

    if (baseRate <= 0) {
      depthError = DepthError.invalidBaseRate;
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
      drillingItems.add(
        BillBreakdownItem(
          label: rangeLabel,
          quantity: units,
          unit: 'ft',
          rate: rate,
          amount: amount,
        ),
      );
    }

    final otherItems = <BillBreakdownItem>[
      if (casingFeet != null)
        BillBreakdownItem(
          label: 'Casing (GI)',
          quantity: casingFeet,
          unit: 'ft',
          rate: casingRate!,
          amount: casingFeet * casingRate!,
        ),
    ];

    void addPieceItem(String label, String qtyInput, double rate) {
      final qty = int.tryParse(qtyInput.trim()) ?? 0;
      if (qty <= 0) return;
      otherItems.add(
        BillBreakdownItem(
          label: label,
          quantity: qty,
          unit: 'Nos',
          rate: rate,
          amount: qty * rate,
        ),
      );
    }

    addPieceItem('COLLAR', collarQtyInput, fixedCharges.collar);
    addPieceItem('WELDING', weldingQtyInput, fixedCharges.welding);
    addPieceItem('CUTTING', cuttingQtyInput, fixedCharges.cutting);
    addPieceItem('CAP', capQtyInput, fixedCharges.cap);

    final total = [
      ...drillingItems,
      ...otherItems,
    ].fold<double>(0, (sum, item) => sum + item.amount);

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
    baseRate = _savedDefaultRates.baseRate;
    casingRate = _savedDefaultRates.casingRate;
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
      final unitSuffix = item.unit != null ? ' ${item.unit}' : '';
      final detail = item.quantity != null && item.rate != null
          ? '${item.quantity}$unitSuffix × ${CurrencyFormatter.format(item.rate!)}'
          : CurrencyFormatter.format(item.amount);
      buffer
        ..writeln(item.label)
        ..writeln('$detail = ${CurrencyFormatter.format(item.amount)}')
        ..writeln('-------------------');
    }

    buffer.writeln();
    buffer.write(
      '${l10n.totalAmount}: ${CurrencyFormatter.format(r.totalAmount)}',
    );
    return buffer.toString();
  }
}
