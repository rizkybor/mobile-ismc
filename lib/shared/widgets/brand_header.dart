import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Header gradien bermerek untuk layar tab: judul besar, subjudul, aksi
/// opsional, dan sudut bawah melengkung. Ikon status bar otomatis terang.
class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  /// Widget yang "menggantung" di tepi bawah header (mis. kartu ringkasan).
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Stack(
              children: [
                const Positioned(right: -40, top: -50, child: _Orb(size: 180)),
                const Positioned(right: 60, top: 30, child: _Orb(size: 70)),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      bottom == null ? AppSpacing.xl + 4 : AppSpacing.xl + 44,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  subtitle!,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.78),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        ?trailing,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (bottom != null)
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: -36,
              child: bottom!,
            ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
    );
  }
}
