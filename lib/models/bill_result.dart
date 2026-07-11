/// One line item in the calculated bill breakdown — a drilling depth
/// segment, the casing line, or one of the fixed charges.
///
/// [quantity]/[rate] are kept as raw numbers (rather than a pre-formatted
/// string) so each renderer can format the amount its own way — the UI
/// uses the ₹ glyph, while the PDF's built-in font lacks that glyph and
/// falls back to "Rs." (see [PdfService]). [quantity] and [rate] are null
/// for flat fixed charges that have no per-unit rate.
class BillBreakdownItem {
  final String label;
  final int? quantity;
  final double? rate;
  final double amount;

  const BillBreakdownItem({
    required this.label,
    this.quantity,
    this.rate,
    required this.amount,
  });
}

/// The full result of a bill calculation: drilling (billed per depth band,
/// with the rate auto-escalating at each band), an optional casing line,
/// and the fixed COLLAR/WELDING/CUTTING/CAP charges.
class BillResult {
  final int totalDepth;
  final double baseRate;
  final int casingFeet;
  final double? casingRate;
  final List<BillBreakdownItem> drillingItems;
  final List<BillBreakdownItem> otherItems;
  final double totalAmount;

  const BillResult({
    required this.totalDepth,
    required this.baseRate,
    required this.casingFeet,
    required this.casingRate,
    required this.drillingItems,
    required this.otherItems,
    required this.totalAmount,
  });

  List<BillBreakdownItem> get items => [...drillingItems, ...otherItems];
}
