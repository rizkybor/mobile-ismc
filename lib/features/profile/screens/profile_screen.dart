import 'package:flutter/material.dart';

import '../../../core/i18n/l10n.dart';
import '../../../shared/widgets/widgets.dart';
import '../../debug/debug_fab.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold.brand(
      title: l10n.profileTitle,
      subtitle: l10n.profileSubtitle,
      floatingActionButton: const DebugFab(),
      body: const StagePlaceholder(
        stage: 8,
        icon: Icons.account_circle_outlined,
      ),
    );
  }
}
