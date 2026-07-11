/// Preset base drilling-rate options (₹/ft) shown in the drilling rate
/// dropdown on the home screen.
const List<double> baseDrillingRateOptions = [97, 100, 105, 110, 120];

/// Preset casing (GI) rate options (₹/ft) shown in the casing rate dropdown.
const List<double> casingRateOptions = [500, 520, 600];

/// A fixed depth band that adds a cumulative amount on top of the selected
/// base drilling rate once total depth crosses [minDepth].
///
/// The bands stack: e.g. a borewell of 550 ft picks up the add-ons from
/// every band up to and including 500-600 ft, so the 500-600 ft segment is
/// billed at `baseRate + 40`, not just `baseRate + 20`. [maxDepth] is null
/// for the open-ended final band (700 ft and beyond), which continues at
/// the same rate as the 600-700 ft band.
class DepthRateBand {
  final int minDepth;
  final int? maxDepth;
  final double addOn;

  const DepthRateBand({
    required this.minDepth,
    required this.maxDepth,
    required this.addOn,
  });
}

/// Fixed, non-editable depth-band structure for drilling rate escalation.
const List<DepthRateBand> depthRateBands = [
  DepthRateBand(minDepth: 0, maxDepth: 300, addOn: 0),
  DepthRateBand(minDepth: 300, maxDepth: 350, addOn: 5),
  DepthRateBand(minDepth: 350, maxDepth: 400, addOn: 10),
  DepthRateBand(minDepth: 400, maxDepth: 450, addOn: 15),
  DepthRateBand(minDepth: 450, maxDepth: 500, addOn: 20),
  DepthRateBand(minDepth: 500, maxDepth: 600, addOn: 40),
  DepthRateBand(minDepth: 600, maxDepth: 700, addOn: 60),
  DepthRateBand(minDepth: 700, maxDepth: null, addOn: 60),
];
