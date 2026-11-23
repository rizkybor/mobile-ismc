import 'package:flutter/material.dart';

import '../../../core/i18n/l10n.dart';
import '../../../shared/widgets/widgets.dart';
import '../../debug/debug_fab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold.brand(
      title: l10n.homeTitle,
      subtitle: l10n.homeSubtitle,
      floatingActionButton: const DebugFab(),
      body: const StagePlaceholder(stage: 4, icon: Icons.dashboard_outlined),
    );
  }
}
