import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../activation/account_status_provider.dart';
import '../../activation/widgets/account_status_card.dart';
import '../../auth/session_controller.dart';
import '../../debug/debug_fab.dart';

/// Beranda. Status akun ≠ aktif → kartu aktivasi (F-02.3); aktif → ringkasan
/// order (diisi Tahap 4).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(AppLocalizations l10n) {
    // Jam dinding WIB (UTC+7) untuk sapaan.
    final h = DateTime.now().toUtc().add(const Duration(hours: 7)).hour;
    if (h < 11) return l10n.homeGreetingMorning;
    if (h < 15) return l10n.homeGreetingAfternoon;
    if (h < 18) return l10n.homeGreetingEvening;
    return l10n.homeGreetingNight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(sessionProvider).user;
    final account = ref.watch(accountStatusProvider);
    final name = user?.name.split(' ').first ?? '';

    return AppScaffold.brand(
      title: name.isEmpty ? l10n.homeTitle : '${_greeting(l10n)}, $name',
      subtitle: l10n.homeSubtitle,
      floatingActionButton: const DebugFab(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountStatusProvider);
          await ref.read(accountStatusProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            account.when(
              loading: () => const Column(
                children: [
                  SkeletonBox(height: 96),
                  SizedBox(height: AppSpacing.md),
                  SkeletonBox(height: 180),
                ],
              ),
              error: (_, _) => ErrorState(
                onRetry: () => ref.invalidate(accountStatusProvider),
              ),
              data: (state) => state.isActive
                  ? const StagePlaceholder(
                      stage: 4,
                      icon: Icons.dashboard_outlined,
                    )
                  : AccountStatusCard(state: state),
            ),
          ],
        ),
      ),
    );
  }
}
