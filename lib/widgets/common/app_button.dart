// lib/widgets/common/app_button.dart
// Reusable button widget for the SavorLean app.
// Provides three variants: primary (filled CTA red), secondary (outlined),
// and olive (filled green for brand moments like the announcement bar).
// All buttons in the app must use this widget — never use raw ElevatedButton
// or OutlinedButton directly in screen/widget files.

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// The visual style of the button.
enum AppButtonVariant {
  /// Filled CTA-red button — used for primary actions like "Add to Cart".
  primary,

  /// Transparent button with a CTA-red border — used for secondary actions.
  secondary,

  /// Filled olive-green button — used in the announcement bar and brand moments.
  olive,
}

/// A SavorLean-branded button.
///
/// [label] — the text shown on the button (automatically rendered uppercase).
/// [onPressed] — callback when tapped. Pass null to visually disable the button.
/// [variant] — controls the visual style (primary, secondary, or olive).
/// [isLoading] — shows a spinner and blocks taps while an async action runs.
/// [fullWidth] — stretches the button to fill its parent's width.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    // While loading, block taps by passing null as the press handler.
    final effectiveOnPressed = isLoading ? null : onPressed;

    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cta,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.cta.withValues(alpha: 0.6),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        child: _buildChild(spinnerColor: Colors.white),
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cta,
          side: BorderSide(
            // Dim the border when disabled to signal the inactive state.
            color: effectiveOnPressed == null
                ? AppColors.cta.withValues(alpha: 0.4)
                : AppColors.cta,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        child: _buildChild(spinnerColor: AppColors.cta),
      ),
      AppButtonVariant.olive => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.olive,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.olive.withValues(alpha: 0.6),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        child: _buildChild(spinnerColor: Colors.white),
      ),
    };

    // Wrap in a SizedBox to make the button fill its parent width if requested.
    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  /// Builds the button's child: a spinner when loading, or the label text.
  Widget _buildChild({required Color spinnerColor}) {
    if (isLoading) {
      return SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
        ),
      );
    }
    return Text(label.toUpperCase(), style: AppTextStyles.button);
  }
}
