import 'package:flutter/material.dart';

import '../../../core/i18n/l10n.dart';
import '../../../shared/widgets/widgets.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: context.l10n.orderDetailTitle,
    body: const StagePlaceholder(stage: 5),
  );
}
