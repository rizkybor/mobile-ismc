import 'package:flutter/material.dart';

/// Token warna PRD §10.
abstract final class AppColors {
  static const primary = Color(0xFF0A488F);
  static const primaryDark = Color(0xFF083567);
  static const primaryLight = Color(0xFFE6EEF8);
  static const navy = Color(0xFF0B1E3A);
  static const accentRed = Color(0xFF8E1028);
  static const success = Color(0xFF1E9E6A);
  static const warning = Color(0xFFD98E04);
  static const error = Color(0xFFB3122E);

  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F7FA);
  static const border = Color(0xFFE2E8F0);
  static const borderSoft = Color(0xFFEDF1F6);

  /// Gradien header bermerek (navy → primer).
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B2A5B), primary, Color(0xFF1C63B8)],
    stops: [0, 0.55, 1],
  );

  /// Bayangan lembut untuk kartu (navy 6%).
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: navy.withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
  static const textPrimary = Color(0xFF0B1E3A);
  static const textSecondary = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);

  // Warna produk (PRD Tahap 4).
  static const productGas = primary;
  static const productUti = accentRed;
  static const productOther = Color(0xFF475569);
}

/// Warna status tahap/chip (selesai, berjalan, tertunda, ditolak, menunggu).
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.done,
    required this.current,
    required this.pending,
    required this.rejected,
    required this.waiting,
  });

  final Color done;
  final Color current;
  final Color pending;
  final Color rejected;
  final Color waiting;

  static const light = StatusColors(
    done: AppColors.success,
    current: AppColors.primary,
    pending: AppColors.warning,
    rejected: AppColors.error,
    waiting: AppColors.textMuted,
  );

  @override
  StatusColors copyWith({
    Color? done,
    Color? current,
    Color? pending,
    Color? rejected,
    Color? waiting,
  }) {
    return StatusColors(
      done: done ?? this.done,
      current: current ?? this.current,
      pending: pending ?? this.pending,
      rejected: rejected ?? this.rejected,
      waiting: waiting ?? this.waiting,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      done: Color.lerp(done, other.done, t)!,
      current: Color.lerp(current, other.current, t)!,
      pending: Color.lerp(pending, other.pending, t)!,
      rejected: Color.lerp(rejected, other.rejected, t)!,
      waiting: Color.lerp(waiting, other.waiting, t)!,
    );
  }
}

extension StatusColorsX on BuildContext {
  StatusColors get statusColors =>
      Theme.of(this).extension<StatusColors>() ?? StatusColors.light;
}
