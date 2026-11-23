import 'package:flutter/material.dart';

import '../../../core/i18n/l10n.dart';
import '../../../shared/widgets/widgets.dart';
import '../../debug/debug_fab.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold.brand(
      title: l10n.notificationsTitle,
      subtitle: l10n.notificationsSubtitle,
      floatingActionButton: const DebugFab(),
      body: const StagePlaceholder(
        stage: 7,
        icon: Icons.notifications_active_outlined,
      ),
    );
  }
}
