import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/subscription_plan.dart';
import '../../providers/cart_provider.dart';
import '../../providers/plan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/loading_indicator.dart';

const _dayOrder = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];
const _slotOrder = ['breakfast', 'lunch', 'dinner'];

class PlanDetailScreen extends ConsumerStatefulWidget {
  const PlanDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends ConsumerState<PlanDetailScreen> {
  String? _selectedDuration;
  int? _selectedMealsPerDay;

  void _initSelection(SubscriptionPlan plan) {
    if (_selectedDuration != null || plan.pricing.isEmpty) return;
    final cheapest = plan.pricing.reduce(
      (a, b) => a.pricePkr < b.pricePkr ? a : b,
    );
    _selectedDuration = cheapest.duration;
    _selectedMealsPerDay = cheapest.mealsPerDay;
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planBySlugProvider(widget.slug));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: planAsync.when(
        data: (plan) {
          if (plan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Plan not found.', style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            );
          }
          _initSelection(plan);
          return _buildContent(plan);
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Could not load plan', style: AppTextStyles.body),
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
                    ref.invalidate(planBySlugProvider(widget.slug)),
                child: const Text('Tap to retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(SubscriptionPlan plan) {
    final selectedPricing =
        (_selectedDuration != null && _selectedMealsPerDay != null)
        ? plan.pricingFor(_selectedDuration!, _selectedMealsPerDay!)
        : null;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.bg,
          foregroundColor: AppColors.textPrimary,
          title: Text(
            plan.name,
            style: AppTextStyles.inter(fontWeight: FontWeight.w700),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.oliveSoft,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    plan.type.toUpperCase(),
                    style: AppTextStyles.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.olive,
                    ),
                  ),
                ),
                if (plan.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(plan.description, style: AppTextStyles.body),
                ],
                const SizedBox(height: 32),

                // Pricing selector
                if (plan.pricing.isNotEmpty) ...[
                  _SectionHeading('Choose Duration'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: plan.availableDurations.map((d) {
                      final selected = _selectedDuration == d;
                      return _SelectChip(
                        label: plan.pricing
                            .firstWhere((p) => p.duration == d)
                            .durationLabel,
                        selected: selected,
                        onTap: () => setState(() => _selectedDuration = d),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _SectionHeading('Meals per Day'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: plan.availableMealsPerDay.map((n) {
                      final selected = _selectedMealsPerDay == n;
                      return _SelectChip(
                        label: '$n Meal${n > 1 ? 's' : ''}',
                        selected: selected,
                        onTap: () => setState(() => _selectedMealsPerDay = n),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Price display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: selectedPricing != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rs. ${selectedPricing.pricePkr}',
                                style: AppTextStyles.price.copyWith(
                                  fontSize: 24,
                                ),
                              ),
                              Text(
                                'for ${selectedPricing.durationLabel} · ${selectedPricing.mealsPerDay} meal${selectedPricing.mealsPerDay > 1 ? 's' : ''}/day',
                                style: AppTextStyles.bodyMuted,
                              ),
                            ],
                          )
                        : Text(
                            'Select duration and meals per day',
                            style: AppTextStyles.bodyMuted,
                          ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Schedule section
                _SectionHeading('Schedule'),
                const SizedBox(height: 12),
                if (plan.scheduleMode == 'message')
                  Text(
                    plan.scheduleMessage.isNotEmpty
                        ? plan.scheduleMessage
                        : 'Schedule details will be shared after purchase.',
                    style: AppTextStyles.bodyMuted,
                  )
                else
                  _ScheduleView(slots: plan.slots),
                const SizedBox(height: 32),

                // Add to Cart button
                AppButton(
                  label: selectedPricing != null
                      ? 'Add to Cart — Rs. ${selectedPricing.pricePkr}'
                      : 'Select Options to Continue',
                  onPressed: selectedPricing != null
                      ? () {
                          ref
                              .read(cartProvider.notifier)
                              .addPlan(plan, selectedPricing);
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.clearSnackBars();
                          final entry = messenger.showSnackBar(
                            SnackBar(
                              content: Text('${plan.name} added to cart'),
                              action: SnackBarAction(
                                label: 'Open Cart',
                                onPressed: () => context.go('/cart'),
                              ),
                            ),
                          );
                          Future.delayed(
                            const Duration(seconds: 3),
                            entry.close,
                          );
                        }
                      : null,
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

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.olive : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.olive : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: AppTextStyles.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _ScheduleView extends StatelessWidget {
  final List<PlanMealSlot> slots;
  const _ScheduleView({required this.slots});

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Text('No schedule available.', style: AppTextStyles.bodyMuted);
    }

    final days = _dayOrder.where((d) => slots.any((s) => s.day == d)).toList();

    return Column(
      children: days.map((day) {
        final daySlots = _slotOrder
            .map((slot) {
              final matches = slots.where(
                (s) => s.day == day && s.slot == slot,
              );
              return matches.isEmpty ? null : matches.first;
            })
            .whereType<PlanMealSlot>()
            .toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: AppColors.surface,
                child: Text(
                  day[0].toUpperCase() + day.substring(1),
                  style: AppTextStyles.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...daySlots.map(
                (slot) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          slot.slot[0].toUpperCase() + slot.slot.substring(1),
                          style: AppTextStyles.inter(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          slot.mealName ?? slot.mealId,
                          style: AppTextStyles.inter(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
