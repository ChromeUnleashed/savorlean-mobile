import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/meal.dart';
import '../../providers/cart_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/loading_indicator.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  const MealDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final mealAsync = ref.watch(mealBySlugProvider(widget.slug));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: mealAsync.when(
        data: (meal) {
          if (meal == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Meal not found.', style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            );
          }
          return _buildContent(context, meal);
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Could not load meal', style: AppTextStyles.body),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  e.toString(),
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.invalidate(mealBySlugProvider(widget.slug)),
                child: const Text('Tap to retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Meal meal) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: AppColors.bg,
          foregroundColor: AppColors.textPrimary,
          leading: _CircleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
          ),
          actions: [
            // Wishlist heart — filled when the meal is saved, outlined when not.
            Builder(
              builder: (context) {
                final wishlistIds =
                    ref.watch(wishlistProvider).asData?.value ?? {};
                final isWishlisted = wishlistIds.contains(meal.id);
                return _CircleButton(
                  icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? AppColors.cta : AppColors.textPrimary,
                  onTap: () async {
                    final user = ref.read(currentUserProvider);
                    if (user == null) {
                      context.push('/login');
                      return;
                    }
                    try {
                      await ref.read(wishlistProvider.notifier).toggle(meal.id);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Wishlist error: $e')),
                        );
                      }
                    }
                  },
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: meal.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: meal.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const AppSkeletonBox(),
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.surface),
                  )
                : Container(color: AppColors.surface),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category + badges row
                Row(
                  children: [
                    if (meal.categoryName != null)
                      Text(
                        meal.categoryName!.toUpperCase(),
                        style: AppTextStyles.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.olive,
                        ),
                      ),
                    if (meal.isBestseller) ...[
                      const SizedBox(width: 8),
                      _Badge('Bestseller'),
                    ],
                    if (meal.isFeatured && !meal.isBestseller) ...[
                      const SizedBox(width: 8),
                      _Badge('Featured'),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Meal name
                Text(meal.name, style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),
                // Price
                Text(
                  'Rs. ${meal.pricePkr}',
                  style: AppTextStyles.price.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 24),

                // Description
                if (meal.description.isNotEmpty) ...[
                  _SectionHeading('About this meal'),
                  const SizedBox(height: 8),
                  Text(meal.description, style: AppTextStyles.body),
                  const SizedBox(height: 24),
                ],

                // Nutrition facts
                _SectionHeading('Nutrition Facts'),
                const SizedBox(height: 12),
                _NutritionGrid(meal: meal),
                const SizedBox(height: 24),

                // Ingredients
                if (meal.ingredients.isNotEmpty) ...[
                  _SectionHeading('Ingredients'),
                  const SizedBox(height: 8),
                  Text(
                    meal.ingredients.join(', '),
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 24),
                ],

                // Tags
                if (meal.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: meal.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.oliveSoft,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              tag,
                              style: AppTextStyles.inter(
                                fontSize: 12,
                                color: AppColors.olive,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                ],

                // Quantity selector + Add to Cart
                _SectionHeading('Quantity'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '$_quantity',
                        style: AppTextStyles.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: () => setState(() => _quantity++),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Add to Cart — Rs. ${meal.pricePkr * _quantity}',
                  onPressed: () {
                    ref.read(cartProvider.notifier).addMeal(meal, _quantity);
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.clearSnackBars();
                    final entry = messenger.showSnackBar(
                      SnackBar(
                        content: Text('${meal.name} added to cart'),
                        action: SnackBarAction(
                          label: 'Open Cart',
                          onPressed: () => context.go('/cart'),
                        ),
                      ),
                    );
                    Future.delayed(const Duration(seconds: 3), entry.close);
                  },
                  variant: AppButtonVariant.ctaLight,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _CircleButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color ?? AppColors.textPrimary),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.cta,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: AppTextStyles.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String text;

  const _SectionHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _NutritionGrid extends StatelessWidget {
  final Meal meal;

  const _NutritionGrid({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NutrientBox(
          label: 'Calories',
          value: '${meal.caloriesKcal}',
          unit: 'kcal',
        ),
        const SizedBox(width: 10),
        _NutrientBox(label: 'Protein', value: '${meal.proteinG}', unit: 'g'),
        const SizedBox(width: 10),
        _NutrientBox(label: 'Carbs', value: '${meal.carbsG}', unit: 'g'),
        const SizedBox(width: 10),
        _NutrientBox(label: 'Fat', value: '${meal.fatG}', unit: 'g'),
      ],
    );
  }
}

class _NutrientBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _NutrientBox({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.olive,
              ),
            ),
            Text(
              unit,
              style: AppTextStyles.inter(fontSize: 10, color: AppColors.olive),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.inter(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(
            color: onTap != null ? AppColors.border : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}
