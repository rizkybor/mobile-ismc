import 'package:flutter/material.dart';

import '../../../core/i18n/l10n.dart';
import '../../../shared/widgets/widgets.dart';

class ActivationScreen extends StatelessWidget {
  const ActivationScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: context.l10n.activationTitle,
    body: const StagePlaceholder(stage: 3),
  );
}
