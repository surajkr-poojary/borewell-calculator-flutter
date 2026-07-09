/// Preset rate options shown in each slab's dropdown, plus "Custom".
const List<double> presetRateOptions = [250, 300, 350, 400, 450, 500];

/// A single depth-based pricing slab, e.g. "0 - 200 ft" priced at ₹300/ft.
///
/// [maxDepth] is null for the final, open-ended slab ("601 ft and above").
class RateSlab {
  final int index;
  final int minDepth;
  final int? maxDepth;
  double rate;

  RateSlab({
    required this.index,
    required this.minDepth,
    required this.maxDepth,
    required this.rate,
  });

  /// Whether [rate] should be shown/edited as a custom amount rather than
  /// one of the preset dropdown options. Derived from the rate itself
  /// (instead of a separately tracked flag) so the dropdown, the custom
  /// field, and the stored value can never drift out of sync.
  bool get isCustom => !presetRateOptions.contains(rate);

  /// Read-only label shown on the home screen for the full slab range.
  /// e.g. "0 - 200 ft", "201 - 400 ft", "601 ft and above".
  String get rangeLabel {
    if (maxDepth == null) {
      return '${minDepth == 0 ? 0 : minDepth + 1} ft and above';
    }
    final start = minDepth == 0 ? 0 : minDepth + 1;
    return '$start - $maxDepth ft';
  }

  RateSlab copyWith({double? rate}) {
    return RateSlab(
      index: index,
      minDepth: minDepth,
      maxDepth: maxDepth,
      rate: rate ?? this.rate,
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'minDepth': minDepth,
        'maxDepth': maxDepth,
        'rate': rate,
      };

  factory RateSlab.fromJson(Map<String, dynamic> json) => RateSlab(
        index: json['index'] as int,
        minDepth: json['minDepth'] as int,
        maxDepth: json['maxDepth'] as int?,
        rate: (json['rate'] as num).toDouble(),
      );
}

/// Default (factory) slab configuration used on first launch.
List<RateSlab> defaultRateSlabs() => [
      RateSlab(index: 0, minDepth: 0, maxDepth: 200, rate: 300),
      RateSlab(index: 1, minDepth: 200, maxDepth: 400, rate: 350),
      RateSlab(index: 2, minDepth: 400, maxDepth: 600, rate: 400),
      RateSlab(index: 3, minDepth: 600, maxDepth: null, rate: 450),
    ];
