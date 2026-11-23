import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../debug/language_toggle.dart';

/// Kerangka layar auth sekunder: AppBar putih + toggle bahasa, judul besar,
/// subjudul, lalu isi form yang bisa digulir (aman dari keyboard).
class AuthFormShell extends StatelessWidget {
  const AuthFormShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showLanguageToggle = true,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool showLanguageToggle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppScaffold(
      title: title,
      actions: showLanguageToggle ? const [LanguageToggle()] : null,
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl + 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: t.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            ...children,
          ],
        ),
      ),
    );
  }
}
