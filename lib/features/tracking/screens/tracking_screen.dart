import 'package:flutter/material.dart';

import '../../../core/i18n/l10n.dart';
import '../../../shared/widgets/widgets.dart';
import '../../debug/debug_fab.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold.brand(
      title: l10n.trackingTitle,
      subtitle: l10n.trackingSubtitle,
      floatingActionButton: const DebugFab(),
      body: const StagePlaceholder(stage: 5, icon: Icons.route_rounded),
    );
  }
}
