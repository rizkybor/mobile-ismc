import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/i18n/l10n.dart';
import '../../core/theme/app_colors.dart';

/// Tombol kecil pembuka panel debug; tidak pernah ada di build rilis.
class DebugFab extends StatelessWidget {
  const DebugFab({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return FloatingActionButton.small(
      heroTag: 'debug-fab',
      elevation: 2,
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      tooltip: context.l10n.debugOpen,
      onPressed: () => context.push(Routes.debug),
      child: const Icon(Icons.bug_report_outlined),
    );
  }
}
