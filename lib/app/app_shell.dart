import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/i18n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../features/activation/account_status_provider.dart';

/// Kerangka tab bawah: Beranda, Lacak, Notifikasi, Profil (PRD §10).
/// Padanan ikon mdi web: home-outline, map-marker-path, bell-outline,
/// account-circle-outline.
/// Tab Lacak & Notifikasi terkunci selama akun belum aktif (PRD §3).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const _lockedIndexes = {1, 2};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final active = ref.watch(isAccountActiveProvider);
    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.borderSoft)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) {
            if (!active && _lockedIndexes.contains(i)) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(SnackBar(content: Text(l10n.tabLockedMessage)));
              return;
            }
            shell.goBranch(i, initialLocation: i == shell.currentIndex);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.tabHome,
            ),
            NavigationDestination(
              icon: _LockableIcon(Icons.route_outlined, locked: !active),
              selectedIcon: const Icon(Icons.route_rounded),
              label: l10n.tabTracking,
            ),
            NavigationDestination(
              icon: _LockableIcon(
                Icons.notifications_outlined,
                locked: !active,
              ),
              selectedIcon: const Icon(Icons.notifications_rounded),
              label: l10n.tabNotifications,
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_circle_outlined),
              selectedIcon: const Icon(Icons.account_circle_rounded),
              label: l10n.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}

class _LockableIcon extends StatelessWidget {
  const _LockableIcon(this.icon, {required this.locked});
  final IconData icon;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    if (!locked) return Icon(icon);
    return Badge(
      backgroundColor: AppColors.textMuted,
      smallSize: 14,
      label: const Icon(Icons.lock, size: 9, color: Colors.white),
      child: Icon(icon, color: AppColors.textMuted),
    );
  }
}
