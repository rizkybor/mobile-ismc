import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/i18n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/order_tracking.dart';
import '../tracking_text.dart';

/// Stepper vertikal 7 tahap (PRD F-04.2): ikon status, label, keterangan
/// (Selesai · tanggal / Sedang berjalan / Tertunda / Ditolak / Menunggu),
/// catatan kecil.
class TrackStepper extends ConsumerWidget {
  const TrackStepper({super.key, required this.tracking});
  final OrderTracking tracking;

  static IconData _icon(TrackStepKey k) => switch (k) {
    TrackStepKey.order => Icons.shopping_cart_checkout_rounded,
    TrackStepKey.workform => Icons.assignment_outlined,
    TrackStepKey.quotation => Icons.request_quote_outlined,
    TrackStepKey.service => Icons.build_outlined,
    TrackStepKey.certificate => Icons.workspace_premium_outlined,
    TrackStepKey.invoice => Icons.receipt_long_outlined,
    TrackStepKey.delivery => Icons.local_shipping_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = ref.watch(localeProvider).languageCode;
    final t = Theme.of(context).textTheme;
    final steps = tracking.steps;

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _StepTile(
            step: steps[i],
            isLast: i == steps.length - 1,
            nextDone:
                i < steps.length - 1 && steps[i + 1].state == TrackState.done,
            icon: _icon(steps[i].key),
            title: TrackingText.step(l10n, steps[i].key),
            subtitle: _subtitle(l10n, steps[i], lang),
            note: TrackingText.resolve(l10n, steps[i].note),
            t: t,
          ),
      ],
    );
  }

  String _subtitle(AppLocalizations l10n, TrackStep s, String lang) {
    final at = Formatters.parseIso(s.at);
    return switch (s.state) {
      TrackState.done =>
        at == null
            ? l10n.stepDone
            : l10n.stepDoneAt(Formatters.formatDate(at, lang)),
      TrackState.current => l10n.stepCurrent,
      TrackState.warning => l10n.stepPending,
      TrackState.error => l10n.stepRejected,
      TrackState.todo => l10n.stepWaiting,
    };
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.step,
    required this.isLast,
    required this.nextDone,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.note,
    required this.t,
  });

  final TrackStep step;
  final bool isLast;
  final bool nextDone;
  final IconData icon;
  final String title;
  final String subtitle;
  final String note;
  final TextTheme t;

  @override
  Widget build(BuildContext context) {
    final color = stepStateColor(context, step.state);
    final isTodo = step.state == TrackState.todo;
    final badge = switch (step.state) {
      TrackState.done => Icons.check_rounded,
      TrackState.current => null,
      TrackState.warning => Icons.pause_rounded,
      TrackState.error => Icons.close_rounded,
      TrackState.todo => null,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isTodo
                        ? Colors.transparent
                        : color.withValues(alpha: 0.14),
                    border: Border.all(
                      color: isTodo ? AppColors.border : color,
                      width: step.state == TrackState.current ? 2 : 1.4,
                    ),
                  ),
                  child: Icon(
                    badge ?? icon,
                    size: 20,
                    color: isTodo ? AppColors.textMuted : color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: step.state == TrackState.done && nextDone
                          ? context.statusColors.done
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 8,
                bottom: isLast ? 0 : AppSpacing.lg + 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: t.titleSmall?.copyWith(
                      color: isTodo
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: t.bodySmall?.copyWith(
                      color: isTodo ? AppColors.textMuted : color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(note, style: t.bodySmall),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
