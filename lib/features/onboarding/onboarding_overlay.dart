import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'onboarding_controller.dart';
import 'onboarding_targets.dart';

class _Step {
  const _Step({
    required this.icon,
    required this.title,
    required this.body,
    this.target,
  });
  final IconData icon;
  final String title;
  final String body;
  final GlobalKey? target;
}

/// Overlay coach-mark 5 langkah di atas UI nyata: latar gelap dengan lubang
/// sorotan pada target, kartu tooltip, indikator langkah, tombol
/// Kembali / Lanjut / Lewati (selalu terlihat).
class OnboardingOverlay extends ConsumerStatefulWidget {
  const OnboardingOverlay({super.key});

  @override
  ConsumerState<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends ConsumerState<OnboardingOverlay> {
  int _index = 0;
  int _relayouts = 0;

  @override
  void initState() {
    super.initState();
    _scheduleRelayout();
  }

  /// Target bisa belum tertata saat overlay pertama dibangun (daftar lazy /
  /// data async): hitung ulang beberapa frame berikutnya sampai ditemukan.
  void _scheduleRelayout() {
    if (_relayouts >= 10) return;
    _relayouts++;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  List<_Step> _steps(AppLocalizations l10n) => [
    _Step(
      icon: Icons.dashboard_outlined,
      title: l10n.onbStep1Title,
      body: l10n.onbStep1Body,
      target: OnboardingTargets.homeStats,
    ),
    _Step(
      icon: Icons.route_rounded,
      title: l10n.onbStep2Title,
      body: l10n.onbStep2Body,
      target: OnboardingTargets.tabTracking,
    ),
    _Step(
      icon: Icons.workspace_premium_outlined,
      title: l10n.onbStep3Title,
      body: l10n.onbStep3Body,
    ),
    _Step(
      icon: Icons.notifications_active_outlined,
      title: l10n.onbStep4Title,
      body: l10n.onbStep4Body,
      target: OnboardingTargets.tabNotifications,
    ),
    _Step(
      icon: Icons.account_circle_outlined,
      title: l10n.onbStep5Title,
      body: l10n.onbStep5Body,
      target: OnboardingTargets.tabProfile,
    ),
  ];

  Rect? _rectOf(GlobalKey? key) {
    final ctx = key?.currentContext;
    final box = ctx?.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return null;
    final origin = box.localToGlobal(Offset.zero);
    return (origin & box.size).inflate(8);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = _steps(l10n);
    final step = steps[_index];
    final rect = _rectOf(step.target);
    if (rect == null && step.target != null) _scheduleRelayout();
    final size = MediaQuery.sizeOf(context);
    final t = Theme.of(context).textTheme;
    final ctrl = ref.read(onboardingProvider.notifier);

    // Kartu di bawah target bila target di paruh atas layar, selain itu di atas.
    final placeBelow = rect == null || rect.center.dy < size.height / 2;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _HolePainter(rect))),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: placeBelow
                ? (rect == null ? null : rect.bottom + AppSpacing.md)
                : null,
            bottom: placeBelow
                ? null
                : (size.height - rect.top + AppSpacing.md),
            child: rect == null && placeBelow
                ? SizedBox(
                    height: size.height,
                    child: Center(
                      child: _card(context, l10n, t, step, steps.length, ctrl),
                    ),
                  )
                : _card(context, l10n, t, step, steps.length, ctrl),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context,
    AppLocalizations l10n,
    TextTheme t,
    _Step step,
    int total,
    OnboardingController ctrl,
  ) {
    final isLast = _index == total - 1;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(step.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(step.title, style: t.titleMedium)),
                TextButton(
                  onPressed: () => ctrl.finish(skipped: true),
                  child: Text(l10n.onbSkip),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              step.body,
              style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                for (var i = 0; i < total; i++)
                  Container(
                    width: i == _index ? 18 : 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: i == _index ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                const Spacer(),
                if (_index > 0)
                  TextButton(
                    onPressed: () => setState(() => _index--),
                    child: Text(l10n.onbBack),
                  ),
                FilledButton(
                  onPressed: () {
                    if (isLast) {
                      ctrl.finish(skipped: false);
                    } else {
                      setState(() => _index++);
                    }
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(96, 40),
                  ),
                  child: Text(isLast ? l10n.onbDone : l10n.onbNext),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HolePainter extends CustomPainter {
  _HolePainter(this.hole);
  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final cut = hole == null
        ? Path()
        : (Path()..addRRect(
            RRect.fromRectAndRadius(hole!, const Radius.circular(14)),
          ));
    final path = Path.combine(PathOperation.difference, full, cut);
    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.62),
    );
    if (hole != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(hole!, const Radius.circular(14)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(_HolePainter old) => old.hole != hole;
}
