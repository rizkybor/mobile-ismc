import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum ChipTone { done, current, pending, rejected, waiting, neutral }

/// Chip status kecil dengan warna lembut (latar 12% + teks penuh).
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = ChipTone.neutral,
  });

  final String label;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final s = context.statusColors;
    final color = switch (tone) {
      ChipTone.done => s.done,
      ChipTone.current => s.current,
      ChipTone.pending => s.pending,
      ChipTone.rejected => s.rejected,
      ChipTone.waiting => s.waiting,
      ChipTone.neutral => AppColors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
