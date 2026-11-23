import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/i18n/supported_locales.dart';
import '../../core/theme/app_colors.dart';

// Kode bahasa ISO, bukan teks yang diterjemahkan — tetap sama di ID & EN.
const _labelId = 'ID';
const _labelEn = 'EN';

/// Tombol **ID / EN** (F-01.6). Dipakai di Welcome, Masuk, dan panel debug.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key, this.onDark = false});
  final bool onDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final fg = onDark ? Colors.white : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SegmentedButton<Locale>(
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          side: WidgetStatePropertyAll(
            BorderSide(color: fg.withValues(alpha: 0.6)),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? (onDark ? AppColors.primary : Colors.white)
                : fg,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? (onDark ? Colors.white : AppColors.primary)
                : Colors.transparent,
          ),
        ),
        segments: const [
          ButtonSegment(value: SupportedLocales.id, label: Text(_labelId)),
          ButtonSegment(value: SupportedLocales.en, label: Text(_labelEn)),
        ],
        selected: {locale},
        onSelectionChanged: (s) =>
            ref.read(localeProvider.notifier).setLocale(s.first),
      ),
    );
  }
}
