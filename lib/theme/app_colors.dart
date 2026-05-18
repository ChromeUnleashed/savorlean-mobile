// lib/theme/app_colors.dart
// Defines every color used in the SavorLean app.
// All widget code must reference constants from this class — never use
// raw hex values inline. This mirrors the web app's CSS custom properties.

import 'package:flutter/material.dart';

/// All color constants for the SavorLean design system.
class AppColors {
  AppColors._(); // private constructor — this class is never instantiated

  // Brand olive green — accents, category chips, tags, announcement bar
  static const Color olive = Color(0xFF6E7B44);
  static const Color oliveHover = Color(0xFF566030);
  static const Color oliveSoft = Color(
    0xFFEEF1E0,
  ); // light tint used as chip background

  // Call-to-action red — all primary filled buttons and key interactive elements
  static const Color cta = Color(0xFF9B4E38);
  static const Color ctaHover = Color(0xFF7D3C2A);

  // Page and surface backgrounds
  static const Color bg = Color(0xFFFFFFFF); // main white page background
  static const Color surface = Color(0xFFF0EDE8); // card image background
  static const Color cream = Color(0xFFF0E8DC); // cart totals and summary zones

  // Text
  static const Color textPrimary = Color(0xFF1A1A18); // all main readable text
  static const Color textMuted = Color(0xFF6B6B6B); // secondary / helper text

  // Dividers and input borders
  static const Color border = Color(0xFFE0DDD8);

  // Status colors — success confirmations and error messages
  static const Color success = Color(0xFF2D7A3A);
  static const Color error = Color(0xFFC13B2A);
}
