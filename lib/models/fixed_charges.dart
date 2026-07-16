/// Fixed one-time charges added to every bill (COLLAR, WELDING, CUTTING,
/// CAP). Defaults match the standard shop rates but are editable in
/// Settings and persisted for future bills.
class FixedCharges {
  final double collar;
  final double welding;
  final double cutting;
  final double cap;

  const FixedCharges({
    required this.collar,
    required this.welding,
    required this.cutting,
    required this.cap,
  });

  double get total => collar + welding + cutting + cap;

  factory FixedCharges.defaults() =>
      const FixedCharges(collar: 500, welding: 300, cutting: 300, cap: 300);

  FixedCharges copyWith({
    double? collar,
    double? welding,
    double? cutting,
    double? cap,
  }) {
    return FixedCharges(
      collar: collar ?? this.collar,
      welding: welding ?? this.welding,
      cutting: cutting ?? this.cutting,
      cap: cap ?? this.cap,
    );
  }

  Map<String, dynamic> toJson() => {
    'collar': collar,
    'welding': welding,
    'cutting': cutting,
    'cap': cap,
  };

  factory FixedCharges.fromJson(Map<String, dynamic> json) => FixedCharges(
    collar: (json['collar'] as num).toDouble(),
    welding: (json['welding'] as num).toDouble(),
    cutting: (json['cutting'] as num).toDouble(),
    cap: (json['cap'] as num).toDouble(),
  );
}
