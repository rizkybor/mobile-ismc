import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../debug/language_toggle.dart';

/// Layar Welcome bermerek dengan pilihan bahasa (F-01.6).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            // Hero gradien dengan logo.
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.xl + 8,
                  ),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: LanguageToggle(onDark: true),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 30,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo-ism.png',
                          height: 84,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.welcomeBrand.toUpperCase(),
                        style: t.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl + 4,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.welcomeTitle, style: t.headlineSmall),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.welcomeSubtitle,
                      style: t.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _Feature(
                      icon: Icons.route_rounded,
                      text: l10n.welcomeFeatureTrack,
                    ),
                    _Feature(
                      icon: Icons.workspace_premium_outlined,
                      text: l10n.welcomeFeatureDocs,
                    ),
                    _Feature(
                      icon: Icons.notifications_active_outlined,
                      text: l10n.welcomeFeatureNotif,
                    ),
                    const Spacer(),
                    AppButton(
                      label: l10n.welcomeLogin,
                      onPressed: () => context.push(Routes.login),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: l10n.welcomeRegister,
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.push(Routes.register),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: context.l10n.loginTitle,
    actions: const [LanguageToggle()],
    body: const StagePlaceholder(stage: 2, icon: Icons.lock_outline_rounded),
  );
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: context.l10n.registerTitle,
    body: const StagePlaceholder(
      stage: 2,
      icon: Icons.person_add_alt_1_outlined,
    ),
  );
}

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: context.l10n.verifyEmailTitle,
    body: const StagePlaceholder(
      stage: 2,
      icon: Icons.mark_email_read_outlined,
    ),
  );
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: context.l10n.forgotPasswordTitle,
    body: const StagePlaceholder(stage: 2, icon: Icons.key_outlined),
  );
}
