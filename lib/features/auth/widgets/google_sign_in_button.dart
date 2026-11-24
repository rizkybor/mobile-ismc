import 'package:flutter/material.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_loader.dart';

/// Tombol "Masuk dengan Google" (putih, logo G berwarna) + pemisah "atau".
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.loading = false,
    this.withDivider = true,
  });

  final VoidCallback? onPressed;
  final bool loading;
  final bool withDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (withDivider) ...[
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(l10n.authOr, style: t.bodySmall),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Semantics(
          identifier: 'login-google',
          child: OutlinedButton(
            onPressed: loading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
            ),
            child: loading
                ? const AppLoader(size: 7)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CustomPaint(painter: _GooglePainter()),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(l10n.loginGoogle),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

/// Logo "G" Google digambar dengan 4 warna resmi (tanpa aset bitmap).
class _GooglePainter extends CustomPainter {
  const _GooglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.22;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final r = (Offset.zero & size).deflate(stroke / 2);
    const deg = 3.14159265 / 180;
    canvas.drawArc(
      r,
      200 * deg,
      100 * deg,
      false,
      paint..color = const Color(0xFFEA4335),
    );
    canvas.drawArc(
      r,
      120 * deg,
      80 * deg,
      false,
      paint..color = const Color(0xFFFBBC05),
    );
    canvas.drawArc(
      r,
      45 * deg,
      75 * deg,
      false,
      paint..color = const Color(0xFF34A853),
    );
    canvas.drawArc(
      r,
      0,
      45 * deg,
      false,
      paint..color = const Color(0xFF4285F4),
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2,
        size.height / 2 - stroke / 2,
        size.width / 2 - stroke / 2,
        stroke,
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
