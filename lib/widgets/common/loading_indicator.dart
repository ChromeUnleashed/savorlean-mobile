// lib/widgets/common/loading_indicator.dart
// Provides branded loading states for the SavorLean app.
//
// AppLoadingIndicator — a centered CTA-red spinner for full-screen loading.
// AppSkeletonBox      — an animated grey placeholder box for skeleton layouts.
//
// Use these instead of raw CircularProgressIndicator or plain grey containers
// so all loading states look consistent across every screen.

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A centered circular spinner using the SavorLean CTA color.
///
/// [size] — the diameter of the spinner in logical pixels (default 24).
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          // Use the CTA red so the spinner matches brand buttons.
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cta),
        ),
      ),
    );
  }
}

/// A shimmering grey rectangle used as a placeholder while content loads.
///
/// Place this wherever real content will appear — it pulses gently so the
/// user can tell something is loading rather than broken.
///
/// [width]  — optional fixed width (defaults to filling parent width).
/// [height] — height of the placeholder box (default 16).
/// [borderRadius] — corner rounding (default 4).
class AppSkeletonBox extends StatefulWidget {
  const AppSkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<AppSkeletonBox> createState() => _AppSkeletonBoxState();
}

class _AppSkeletonBoxState extends State<AppSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    // Fade the box between 40% and 85% opacity to create a soft pulse effect.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween<double>(
      begin: 0.4,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    // Always dispose animation controllers to prevent memory leaks.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) => Opacity(
        opacity: _opacity.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
    );
  }
}
