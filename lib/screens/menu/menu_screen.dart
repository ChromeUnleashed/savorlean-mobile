// lib/screens/menu/menu_screen.dart
// The Menu screen — lets users browse Meals and Plans via a top tab bar.
// Meals tab: search bar, category filter chips, 2-column meal grid.
// Plans tab: vertical list of subscription plan cards.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/category.dart';
import '../../models/meal.dart';
import '../../providers/meal_provider.dart';
import '../../providers/plan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/meal_card/meal_card.dart';
import '../../widgets/plan_card/custom_plan_banner.dart';
import '../../widgets/plan_card/plan_card.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top tab bar ─────────────────────────────────────────────
            TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorColor: AppColors.olive,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2.5,
              labelColor: AppColors.olive,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: AppTextStyles.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTextStyles.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Meals'),
                Tab(text: 'Plans'),
              ],
            ),
            Container(height: 1, color: AppColors.border),

            // ── Tab content ─────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MealsTab(
                    searchController: _searchController,
                    searchQuery: _searchQuery,
                    onSearchChanged: (v) =>
                        setState(() => _searchQuery = v.trim()),
                  ),
                  const _PlansTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Meals tab
// ---------------------------------------------------------------------------

/// The Meals tab — search bar, category chips, and a 2-column grid of meals.
class _MealsTab extends ConsumerWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _MealsTab({
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  List<Meal> _applySearch(List<Meal> meals) {
    if (searchQuery.isEmpty) return meals;
    final q = searchQuery.toLowerCase();
    return meals.where((m) => m.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final mealsAsync = ref.watch(mealsProvider);
    final selectedId = ref.watch(selectedCategoryIdProvider);

    return RefreshIndicator(
      color: AppColors.cta,
      onRefresh: () async {
        ref.invalidate(mealsProvider);
        ref.invalidate(categoriesProvider);
      },
      child: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search meals...',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
            ),
          ),

          // Category filter chips
          SliverToBoxAdapter(
            child: categoriesAsync.when(
              data: (cats) => _CategoryChips(
                categories: cats,
                selectedId: selectedId,
                onSelect: (id) =>
                    ref.read(selectedCategoryIdProvider.notifier).select(id),
              ),
              loading: () => const SizedBox(height: 52),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),

          // Meal grid
          mealsAsync.when(
            data: (meals) {
              final filtered = _applySearch(meals);
              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      searchQuery.isEmpty
                          ? 'No meals in this category.'
                          : 'No meals match "$searchQuery".',
                      style: AppTextStyles.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final meal = filtered[i];
                    return MealCard(
                      meal: meal,
                      onTap: () => context.push('/menu/${meal.slug}'),
                    );
                  }, childCount: filtered.length),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, _) => const AppMealCardSkeleton(),
                  childCount: 6,
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Could not load meals', style: AppTextStyles.body),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        e.toString(),
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(mealsProvider),
                      child: const Text('Tap to retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plans tab
// ---------------------------------------------------------------------------

/// The Plans tab — a scrollable list of subscription plan cards.
class _PlansTab extends ConsumerWidget {
  const _PlansTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plansProvider);

    return plansAsync.when(
      data: (plans) {
        if (plans.isEmpty) {
          return Center(
            child: Text('No plans available.', style: AppTextStyles.bodyMuted),
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
    );
  }
}

// ---------------------------------------------------------------------------
// Category chips (Meals tab only)
// ---------------------------------------------------------------------------

class _CategoryChips extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final void Function(String?) onSelect;

  const _CategoryChips({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == 0) {
            return _Chip(
              label: 'All',
              selected: selectedId == null,
              onTap: () => onSelect(null),
            );
          }
          final cat = categories[i - 1];
          return _Chip(
            label: cat.name,
            selected: selectedId == cat.id,
            onTap: () => onSelect(cat.id),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.cta : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.cta : AppColors.border,
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
