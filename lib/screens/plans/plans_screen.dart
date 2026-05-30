import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/plan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/plan_card/custom_plan_banner.dart';
import '../../widgets/plan_card/plan_card.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plansProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Our ',
                style: AppTextStyles.headingBold.copyWith(fontSize: 20),
              ),
              TextSpan(
                text: 'Plans',
                style: AppTextStyles.headingSerif.copyWith(fontSize: 22),
              ),
            ],
          ),
        ),
      ),
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return Center(
              child: Text(
                'No plans available.',
                style: AppTextStyles.bodyMuted,
              ),
            );
          }

          // Separate the single custom plan from the ready-made plans.
          final customPlan = plans.cast<dynamic>().firstWhere(
            (p) => (p.type as String).toLowerCase() == 'custom',
            orElse: () => null,
          );
          final regularPlans = plans
              .where((p) => p.type.toLowerCase() != 'custom')
              .toList();

          // Build the list items: banner → section label → regular cards.
          final items = <Widget>[
            if (customPlan != null)
              CustomPlanBanner(
                plan: customPlan,
                onTap: () => context.push('/plans/${customPlan.slug}'),
              ),
            if (customPlan != null && regularPlans.isNotEmpty) ...[
              const SizedBox(height: 28),
              const PlanSectionLabel(label: 'READY-MADE PLANS'),
              const SizedBox(height: 16),
            ],
            for (int i = 0; i < regularPlans.length; i++) ...[
              if (i > 0) const SizedBox(height: 20),
              PlanCard(
                plan: regularPlans[i],
                onTap: () => context.push('/plans/${regularPlans[i].slug}'),
              ),
            ],
          ];

          return RefreshIndicator(
            color: AppColors.cta,
            onRefresh: () async => ref.invalidate(plansProvider),
            child: ListView(padding: const EdgeInsets.all(16), children: items),
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, _) => const AppPlanCardSkeleton(),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Could not load plans', style: AppTextStyles.body),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  e.toString(),
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              TextButton(
                onPressed: () => ref.invalidate(plansProvider),
                child: const Text('Tap to retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
