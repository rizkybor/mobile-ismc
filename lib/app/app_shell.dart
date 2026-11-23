import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/i18n/l10n.dart';
import '../core/theme/app_colors.dart';

/// Kerangka tab bawah: Beranda, Lacak, Notifikasi, Profil (PRD §10).
/// Padanan ikon mdi web: home-outline, map-marker-path, bell-outline,
/// account-circle-outline.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.tabHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.route_outlined),
              selectedIcon: const Icon(Icons.route_rounded),
              label: l10n.tabTracking,
            ),
            NavigationDestination(
              icon: const Icon(Icons.notifications_outlined),
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
