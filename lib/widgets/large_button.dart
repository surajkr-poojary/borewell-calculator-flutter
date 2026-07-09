import 'package:flutter/material.dart';

/// A large, easy-to-tap button used for the primary actions on screen
/// (Calculate, Reset, Share, Download). Thin wrapper around the standard
/// Material buttons so press feedback, ripple, and disabled styling all
/// come from the app theme rather than being reimplemented here.
class LargeButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;

  const LargeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final onPressed = isLoading ? null : this.onPressed;
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: isPrimary
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
            ),
          )
        : Text(label);

    if (isPrimary) {
      return icon == null || isLoading
          ? FilledButton(style: style, onPressed: onPressed, child: child)
          : FilledButton.icon(
              style: style,
              onPressed: onPressed,
              icon: Icon(icon),
              label: child,
            );
    }

    return icon == null || isLoading
        ? OutlinedButton(style: style, onPressed: onPressed, child: child)
        : OutlinedButton.icon(
            style: style,
            onPressed: onPressed,
            icon: Icon(icon),
            label: child,
          );
  }
}
