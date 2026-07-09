import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

/// A header icon button that cycles the app's theme mode
/// (system -> light -> dark -> system).
class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppThemeProvider>().mode;
    final icon = switch (mode) {
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
      ThemeMode.system => Icons.brightness_auto_outlined,
    };
    final tooltip = switch (mode) {
      ThemeMode.light => 'Light theme',
      ThemeMode.dark => 'Dark theme',
      ThemeMode.system => 'System theme',
    };

    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () => context.read<AppThemeProvider>().toggle(),
    );
  }
}
