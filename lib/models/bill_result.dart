/// One line item in the calculated bill breakdown.
class BillBreakdownItem {
  final String rangeLabel;
  final int units;
  final double rate;
  final double amount;

  const BillBreakdownItem({
    required this.rangeLabel,
    required this.units,
    required this.rate,
    required this.amount,
  });
}

/// The full result of a bill calculation.
class BillResult {
  final int totalDepth;
  final List<BillBreakdownItem> items;
  final double totalAmount;

  const BillResult({
    required this.totalDepth,
    required this.items,
    required this.totalAmount,
  });
}
