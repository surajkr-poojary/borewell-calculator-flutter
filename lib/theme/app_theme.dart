import 'package:flutter/material.dart';

/// Brand colors: an earthy soil brown (used solid on the header/buttons),
/// evoking groundwater/drilling, and a deep green used sparingly to draw
/// the eye to the final total amount. `water` is a cool accent reserved for
/// the watery decorative touches (waves, ripples) layered on top of the
/// warm soil palette.
class AppColors {
  AppColors._();

  static const soil = Color(0xFF6B4F3B);
  static const soilDeep = Color(0xFF4A3728);
  static const green = Color(0xFF2F855A);
  static const water = Color(0xFF7DD3FC);
}

const _fontFamily = 'Inter';
const _fontFamilyFallback = ['NotoSansKannada'];

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.soil,
    brightness: brightness,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
  );

  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? AppColors.soilDeep : AppColors.soil,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFamilyFallback,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outline, width: 1.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outline, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 2.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error, width: 1.6),
      ),
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.transparent
            : colorScheme.outline,
      ),
    ),
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
