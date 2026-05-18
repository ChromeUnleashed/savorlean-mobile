// lib/theme/app_text_styles.dart
// Defines all text styles for the SavorLean app.
// Inter is used for body text, buttons, labels, and prices.
// Cormorant Garamond (italic) is used for the emotional/brand word in headings.
// All widget code must use styles from this file — never hardcode font sizes inline.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// All text styles for the SavorLean design system.
class AppTextStyles {
  AppTextStyles._(); // private constructor — never instantiated

  // ---------------------------------------------------------------------------
  // Base style builders
  // These are helper methods for creating one-off styles with custom parameters.
  // ---------------------------------------------------------------------------

  /// Inter — the sans-serif font for all body, UI, button, and price text.
  /// Pass only the parameters you want to override from the defaults.
  static TextStyle inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) => GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
  );

  /// Cormorant Garamond — the serif font for brand heading words.
  /// Always rendered in italic per the SavorLean design system.
  static TextStyle cormorant({
    double fontSize = 32,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.textPrimary,
  }) => GoogleFonts.cormorantGaramond(
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: FontStyle.italic,
    color: color,
  );

  // ---------------------------------------------------------------------------
  // Pre-defined named styles
  // Use these for consistent styling across screens and widgets.
  // ---------------------------------------------------------------------------

  /// Bold sans heading — the structural word in mixed headings (e.g., "Daily").
  static TextStyle get headingBold =>
      inter(fontSize: 28, fontWeight: FontWeight.w700, height: 1.1);

  /// Italic serif heading — the emotional word in mixed headings (e.g., "Fresh").
  static TextStyle get headingSerif => cormorant(fontSize: 32);

  /// Standard body text — used for descriptions, paragraphs, and general content.
  static TextStyle get body => inter(fontSize: 14, height: 1.5);

  /// Muted body text — secondary info, helper text, placeholders.
  static TextStyle get bodyMuted =>
      inter(fontSize: 14, color: AppColors.textMuted, height: 1.5);

  /// Small label — category chips, tags, status badges, captions.
  static TextStyle get label =>
      inter(fontSize: 12, fontWeight: FontWeight.w500);

  /// Price text — meal and plan prices shown in listings and cart.
  static TextStyle get price =>
      inter(fontSize: 16, fontWeight: FontWeight.w600);

  /// Button label text — uppercase with tracking, used inside AppButton.
  static TextStyle get button =>
      inter(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2);

  /// Section title — used above horizontal scroll sections on the home screen.
  static TextStyle get sectionTitle => inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: AppColors.textMuted,
  );
}
