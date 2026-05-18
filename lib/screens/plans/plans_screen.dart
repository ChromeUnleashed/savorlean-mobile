import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/plan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/loading_indicator.dart';
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
          return RefreshIndicator(
            color: AppColors.cta,
            onRefresh: () async => ref.invalidate(plansProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => PlanCard(
                plan: plans[i],
                onTap: () => context.push('/plans/${plans[i].slug}'),
              ),
            ),
          );
        },
        loading: () => const Center(child: AppLoadingIndicator()),
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
