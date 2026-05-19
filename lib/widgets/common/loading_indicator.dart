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

// ---------------------------------------------------------------------------
// Skeleton composite widgets
// ---------------------------------------------------------------------------

/// Skeleton placeholder matching the MealCard 2-column grid layout.
/// Drop 6 of these into a SliverGrid / GridView to fill a loading state.
class AppMealCardSkeleton extends StatelessWidget {
  const AppMealCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area — matches MealCard's AspectRatio(4/3)
          AspectRatio(
            aspectRatio: 4 / 3,
            child: LayoutBuilder(
              builder: (_, c) =>
                  AppSkeletonBox(height: c.maxHeight, borderRadius: 0),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonBox(width: 56, height: 10),
                SizedBox(height: 4),
                AppSkeletonBox(height: 13),
                SizedBox(height: 4),
                AppSkeletonBox(width: 80, height: 13),
                SizedBox(height: 8),
                AppSkeletonBox(width: 60, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton placeholder matching the PlanCard full-width layout.
class AppPlanCardSkeleton extends StatelessWidget {
  const AppPlanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(2),
        border: const Border(
          left: BorderSide(color: AppColors.border, width: 4),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonBox(width: 52, height: 20, borderRadius: 2),
                SizedBox(height: 8),
                AppSkeletonBox(width: 130, height: 16),
                SizedBox(height: 6),
                AppSkeletonBox(height: 12),
                SizedBox(height: 4),
                AppSkeletonBox(width: 160, height: 12),
                SizedBox(height: 10),
                AppSkeletonBox(width: 80, height: 14),
              ],
            ),
          ),
          SizedBox(width: 12),
          AppSkeletonBox(width: 16, height: 16),
        ],
      ),
    );
  }
}

/// Skeleton placeholder matching the OrderTile card layout.
class AppOrderTileSkeleton extends StatelessWidget {
  const AppOrderTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonBox(width: 80, height: 13),
                SizedBox(height: 6),
                AppSkeletonBox(width: 120, height: 11),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppSkeletonBox(width: 72, height: 22, borderRadius: 20),
              SizedBox(height: 6),
              AppSkeletonBox(width: 60, height: 13),
            ],
          ),
          SizedBox(width: 8),
          AppSkeletonBox(width: 20, height: 20),
        ],
      ),
    );
  }
}
