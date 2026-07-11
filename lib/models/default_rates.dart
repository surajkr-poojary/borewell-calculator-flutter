/// The default base drilling rate and casing rate applied at the start of
/// every new bill (and after Reset). Editable from Settings and persisted
/// for future app launches.
class DefaultRates {
  final double baseRate;
  final double casingRate;

  const DefaultRates({required this.baseRate, required this.casingRate});

  factory DefaultRates.initial() =>
      const DefaultRates(baseRate: 100, casingRate: 500);

  DefaultRates copyWith({double? baseRate, double? casingRate}) {
    return DefaultRates(
      baseRate: baseRate ?? this.baseRate,
      casingRate: casingRate ?? this.casingRate,
    );
  }

  Map<String, dynamic> toJson() => {
    'baseRate': baseRate,
    'casingRate': casingRate,
  };

  factory DefaultRates.fromJson(Map<String, dynamic> json) => DefaultRates(
    baseRate: (json['baseRate'] as num).toDouble(),
    casingRate: (json['casingRate'] as num).toDouble(),
  );
}
