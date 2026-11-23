import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Indikator memuat bermerek: tiga titik yang berdenyut bergantian.
/// Dipakai di splash, tombol, dan status memuat layar.
class AppLoader extends StatefulWidget {
  const AppLoader({
    super.key,
    this.color = AppColors.primary,
    this.size = 10,
    this.label,
  });

  final Color color;
  final double size;
  final String? label;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Tiap titik bergeser fase 1/3 siklus.
            final t = ((_c.value - i / 3) % 1.0);
            final pulse = Curves.easeInOut.transform(
              t < 0.5 ? t * 2 : (1 - t) * 2,
            );
            return Container(
              width: widget.size,
              height: widget.size,
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.35),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.35 + 0.65 * pulse),
              ),
              transform: Matrix4.diagonal3Values(
                0.75 + 0.35 * pulse,
                0.75 + 0.35 * pulse,
                1,
              ),
              transformAlignment: Alignment.center,
            );
          }),
        );
      },
    );
    if (widget.label == null) return dots;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dots,
        const SizedBox(height: 14),
        Text(
          widget.label!,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: widget.color.withValues(alpha: 0.85)),
        ),
      ],
    );
  }
}
