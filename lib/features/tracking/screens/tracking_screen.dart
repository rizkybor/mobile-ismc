import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../debug/debug_fab.dart';
import '../../home/orders_controller.dart';
import '../../home/widgets/order_card.dart';
import '../order_search.dart';

/// Lacak Order (PRD F-04.1): semua order, pencarian, filter Berjalan/Selesai.
class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  final _query = TextEditingController();
  TrackingFilter _filter = TrackingFilter.active;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final orders = ref.watch(customerOrdersProvider);

    return AppScaffold.brand(
      title: l10n.trackingTitle,
      subtitle: l10n.trackingSubtitle,
      floatingActionButton: const DebugFab(),
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _query,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.trackingSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(_query.clear),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<TrackingFilter>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: TrackingFilter.active,
                        label: Text(l10n.trackingFilterActive),
                        icon: const Icon(Icons.autorenew_rounded),
                      ),
                      ButtonSegment(
                        value: TrackingFilter.done,
                        label: Text(l10n.trackingFilterDone),
                        icon: const Icon(Icons.check_circle_outline_rounded),
                      ),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (s) =>
                        setState(() => _filter = s.first),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.when(
              loading: () => ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: const [
                  SkeletonBox(height: 150),
                  SizedBox(height: AppSpacing.md),
                  SkeletonBox(height: 150),
                  SizedBox(height: AppSpacing.md),
                  SkeletonBox(height: 150),
                ],
              ),
              error: (_, _) => ErrorState(
                message: l10n.homeErrorBody,
                onRetry: () =>
                    ref.read(customerOrdersProvider.notifier).refresh(),
              ),
              data: (all) {
                final list = OrderSearch.apply(
                  all,
                  filter: _filter,
                  query: _query.text,
                );
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(customerOrdersProvider.notifier).refresh(),
                  child: list.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            all.isEmpty
                                ? EmptyState(
                                    icon: Icons.inventory_2_outlined,
                                    title: l10n.trackingEmptyTitle,
                                    message: l10n.homeEmptyBody,
                                  )
                                : EmptyState(
                                    icon: Icons.search_off_rounded,
                                    title: l10n.trackingNoResultsTitle,
                                    message: l10n.trackingNoResultsBody,
                                  ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.sm,
                            AppSpacing.lg,
                            AppSpacing.xl * 4,
                          ),
                          itemCount: list.length + 1,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, i) {
                            if (i == 0) {
                              return Text(
                                l10n.trackingCount(list.length),
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              );
                            }
                            return OrderCard(order: list[i - 1]);
                          },
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
