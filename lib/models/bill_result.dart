/// One line item in the calculated bill breakdown — a drilling depth
/// segment, the casing line, or one of the quantity-based fittings
/// (COLLAR/WELDING/CUTTING/CAP).
///
/// [quantity]/[rate] are kept as raw numbers (rather than a pre-formatted
/// string) so each renderer can format the amount its own way — the UI
/// uses the ₹ glyph, while the PDF's built-in font lacks that glyph and
/// falls back to "Rs." (see [PdfService]). [unit] labels the quantity
/// ("ft" for depth/casing, null for a plain per-piece count).
class BillBreakdownItem {
  final String label;
  final int? quantity;
  final String? unit;
  final double? rate;
  final double amount;

  const BillBreakdownItem({
    required this.label,
    this.quantity,
    this.unit,
    this.rate,
    required this.amount,
  });
}

/// The full result of a bill calculation: drilling (billed per depth band,
/// with the rate auto-escalating at each band), the casing line, and the
/// quantity-based COLLAR/WELDING/CUTTING/CAP fittings.
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
