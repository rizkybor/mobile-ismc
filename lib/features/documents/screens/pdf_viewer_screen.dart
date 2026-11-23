import 'package:flutter/material.dart';

import '../../../core/i18n/l10n.dart';
import '../../../shared/widgets/widgets.dart';

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: context.l10n.pdfViewerTitle,
    body: const StagePlaceholder(stage: 6),
  );
}
