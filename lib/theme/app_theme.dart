// lib/theme/app_theme.dart
// Builds the global ThemeData for the SavorLean app.
// Wires app_colors.dart and app_text_styles.dart into Flutter's Material
// theme system so that standard widgets (AppBar, TextField, Chip, etc.)
// automatically follow the SavorLean design without extra styling in each file.

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Provides the SavorLean ThemeData. Pass [AppTheme.light] to MaterialApp.theme.
class AppTheme {
  AppTheme._(); // private constructor — never instantiated

  /// The light theme — the only theme used by SavorLean (no dark mode).
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,

    // Maps SavorLean brand colors to Material 3 color roles.
    colorScheme: const ColorScheme.light(
      primary: AppColors.cta,
      secondary: AppColors.olive,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),

    // Maps named text styles to Material 3 text theme roles.
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headingBold,
      headlineMedium: AppTextStyles.headingBold,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.bodyMuted,
      labelLarge: AppTextStyles.button,
      labelSmall: AppTextStyles.label,
    ),

    // Primary filled button (CTA red).
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cta,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.cta.withValues(alpha: 0.6),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: AppTextStyles.button,
      ),
    ),

    // Secondary outlined button (CTA-bordered).
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cta,
        side: const BorderSide(color: AppColors.cta),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: AppTextStyles.button,
      ),
    ),

    // AppBar — white background, no elevation, dark text.
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: AppTextStyles.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Text inputs — filled with surface color, near-square corners.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        borderSide: BorderSide(color: AppColors.cta, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: AppTextStyles.bodyMuted,
      labelStyle: AppTextStyles.body,
      errorStyle: AppTextStyles.inter(fontSize: 12, color: AppColors.error),
    ),

    // Category filter chips — olive soft background, near-square.
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.oliveSoft,
      selectedColor: AppColors.olive,
      labelStyle: AppTextStyles.label,
      secondaryLabelStyle: AppTextStyles.label.copyWith(color: Colors.white),
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // Dividers between sections.
    dividerColor: AppColors.border,
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    // Snackbars — dark background, floating style.
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTextStyles.inter(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    ),
  );
}
