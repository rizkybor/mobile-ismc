import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../activation/account_status_provider.dart';
import '../../activation/widgets/account_status_card.dart';
import '../../auth/session_controller.dart';
import '../../debug/debug_fab.dart';
import '../orders_controller.dart';
import '../widgets/home_orders_section.dart';

/// Beranda (PRD F-03). Status akun ≠ aktif → kartu aktivasi (F-02.3);
/// aktif → ringkasan + order terbaru. Muat ulang saat kembali ke
/// foreground setelah > 5 menit (F-03.3).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(customerOrdersProvider.notifier).refreshIfStale();
    }
  }

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().toUtc().add(const Duration(hours: 7)).hour;
    if (h < 11) return l10n.homeGreetingMorning;
    if (h < 15) return l10n.homeGreetingAfternoon;
    if (h < 18) return l10n.homeGreetingEvening;
    return l10n.homeGreetingNight;
  }

  Future<void> _refresh() async {
    ref.invalidate(accountStatusProvider);
    await Future.wait([
      ref.read(accountStatusProvider.future),
      ref.read(customerOrdersProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(sessionProvider).user;
    final account = ref.watch(accountStatusProvider);
    final name = user?.name.split(' ').first ?? '';

    return AppScaffold.brand(
      title: name.isEmpty ? l10n.homeTitle : '${_greeting(l10n)}, $name',
      subtitle: l10n.homeSubtitle,
      floatingActionButton: const DebugFab(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppSpacing.xl * 3),
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
                  ? const HomeOrdersSection()
                  : AccountStatusCard(state: state),
            ),
          ],
        ),
      ),
    );
  }
}
