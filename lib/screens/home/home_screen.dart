// lib/screens/home/home_screen.dart
// The main home screen of the SavorLean app.
// Shows the hero carousel, featured meals, subscription plans, and testimonials.
// Fully implemented in Phase 2-1.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:go_router/go_router.dart';

import '../../models/carousel_slide.dart';
import '../../models/testimonial.dart';
import '../../providers/home_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/plan_provider.dart';
import '../../widgets/plan_card/plan_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/meal_card/meal_card.dart';

/// Home screen.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: homeDataAsync.when(
        data: (data) => _buildContent(context, data),
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Could not load data', style: AppTextStyles.body),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              TextButton(
                onPressed: () => ref.invalidate(homeDataProvider),
                child: const Text('Tap to retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeData data) {
    return CustomScrollView(
      slivers: [
        if (data.announcement != null)
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.olive,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              alignment: Alignment.center,
              child: SafeArea(
                bottom: false,
                child: Text(
                  data.announcement!,
                  style: AppTextStyles.inter(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(child: _CarouselSection(slides: data.slides)),
        const SliverToBoxAdapter(child: _FeaturedMealsSection()),
        const SliverToBoxAdapter(child: _OurPlansSection()),
        SliverToBoxAdapter(
          child: _TestimonialSection(testimonials: data.testimonials),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
    );
  }
}

class _OurPlansSection extends ConsumerWidget {
  const _OurPlansSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(featuredPlansProvider);
    return async.when(
      data: (plans) {
        if (plans.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Our ',
                            style: AppTextStyles.headingBold,
                          ),
                          TextSpan(
                            text: 'Plans',
                            style: AppTextStyles.headingSerif,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/plans'),
                    child: Text(
                      'View All',
                      style: AppTextStyles.inter(
                        fontSize: 13,
                        color: AppColors.cta,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: plans
                    .map(
                      (plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PlanCard(
                          plan: plan,
                          onTap: () => context.push('/plans/${plan.slug}'),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
        child: Column(
          children: [
            const AppPlanCardSkeleton(),
            const SizedBox(height: 12),
            const AppPlanCardSkeleton(),
          ],
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _FeaturedMealsSection extends ConsumerWidget {
  const _FeaturedMealsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(featuredMealsProvider);
    return async.when(
      data: (meals) {
        if (meals.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Featured ',
                      style: AppTextStyles.headingSerif,
                    ),
                    TextSpan(text: 'Meals', style: AppTextStyles.headingBold),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: meals.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final meal = meals[i];
                  return SizedBox(
                    width: 160,
                    child: MealCard(
                      meal: meal,
                      onTap: () => context.push('/menu/${meal.slug}'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => SizedBox(
        height: 260,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) =>
              const SizedBox(width: 160, child: AppMealCardSkeleton()),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _CarouselSection extends StatefulWidget {
  final List<CarouselSlide> slides;

  const _CarouselSection({required this.slides});

  @override
  State<_CarouselSection> createState() => _CarouselSectionState();
}

class _CarouselSectionState extends State<_CarouselSection> {
  late final PageController _controller;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.slides.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted) return;
        final next = (_currentPage + 1) % widget.slides.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final slide = widget.slides[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: slide.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const AppSkeletonBox(),
                    errorWidget: (context, url, error) =>
                        Container(color: AppColors.surface),
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.3)),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slide.headline,
                          style: AppTextStyles.headingSerif.copyWith(
                            color: Colors.white,
                            fontSize: 32,
                          ),
                        ),
                        if (slide.subHeadline != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            slide.subHeadline!,
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == i ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialSection extends StatelessWidget {
  final List<Testimonial> testimonials;

  const _TestimonialSection({required this.testimonials});

  @override
  Widget build(BuildContext context) {
    if (testimonials.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'What they ', style: AppTextStyles.headingBold),
                TextSpan(text: 'Say', style: AppTextStyles.headingSerif),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: testimonials.length,
              itemBuilder: (context, index) {
                final t = testimonials[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < t.rating ? Icons.star : Icons.star_border,
                            color: AppColors.olive,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Text(
                          t.content,
                          style: AppTextStyles.body,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('- ${t.authorName}', style: AppTextStyles.bodyMuted),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
