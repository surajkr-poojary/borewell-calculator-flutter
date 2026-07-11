import 'package:flutter/material.dart';

/// Centers [child] and caps its width on large screens (tablet/desktop/web)
/// so text and cards stay readable instead of stretching edge-to-edge,
/// while leaving narrow (phone) screens completely unaffected since the
/// constraint only kicks in once the available width exceeds [maxWidth].
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 640,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
