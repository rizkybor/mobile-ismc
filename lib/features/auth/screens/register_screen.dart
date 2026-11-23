import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/auth_rules.dart';
import '../../../shared/widgets/widgets.dart';
import '../auth_error_text.dart';
import '../session_controller.dart';
import 'auth_form_shell.dart';

/// F-01.1 Daftar akun customer. Setelah sukses: tampilan "Cek email Anda".
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  bool _loading = false;
  Object? _error;
  String? _doneEmail;

  @override
  void dispose() {
    for (final c in [_name, _username, _email, _password, _repeat]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final email = _email.text.trim();
    try {
      await ref
          .read(sessionProvider.notifier)
          .register(
            name: _name.text.trim(),
            username: _username.text.trim(),
            email: email,
            password: _password.text,
          );
      if (mounted) setState(() => _doneEmail = email);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_doneEmail != null) return _RegisterDone(email: _doneEmail!);

    return AuthFormShell(
      title: l10n.registerTitle,
      subtitle: l10n.registerSubtitle,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: l10n.fieldName,
                controller: _name,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l10n.validationRequired : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.fieldUsername,
                hint: l10n.usernameHint,
                controller: _username,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newUsername],
                prefixIcon: Icons.alternate_email_rounded,
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return l10n.validationRequired;
                  if (!AuthRules.validateUsername(s)) {
                    return l10n.validationUsername;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.fieldEmail,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                prefixIcon: Icons.mail_outline_rounded,
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return l10n.validationRequired;
                  if (!AuthRules.validateEmail(s)) return l10n.validationEmail;
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.fieldPassword,
                controller: _password,
                secure: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                prefixIcon: Icons.lock_outline_rounded,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final s = v ?? '';
                  if (s.isEmpty) return l10n.validationRequired;
                  if (!AuthRules.isPasswordValid(s)) {
                    return l10n.validationPasswordWeak;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              PasswordChecklist(password: _password.text),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.fieldPasswordRepeat,
                controller: _repeat,
                secure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                prefixIcon: Icons.lock_outline_rounded,
                validator: (v) {
                  if ((v ?? '').isEmpty) return l10n.validationRequired;
                  if (v != _password.text) {
                    return l10n.validationPasswordMismatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_error != null) ...[
                InlineMessage(text: authErrorText(l10n, _error!)),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppButton(
                label: l10n.registerButton,
                loading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.registerHaveAccount),
            TextButton(
              onPressed: () => context.pushReplacement(Routes.login),
              child: Text(l10n.registerLoginLink),
            ),
          ],
        ),
      ],
    );
  }
}

/// Checklist syarat password yang berubah saat mengetik (sama dengan web).
class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist({super.key, required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = AuthRules.validatePassword(password);
    final items = [
      (l10n.passwordCheckLength, c.minLength),
      (l10n.passwordCheckCase, c.upperAndLower),
      (l10n.passwordCheckDigit, c.digit),
      (l10n.passwordCheckSymbol, c.symbol),
    ];
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        for (final (label, ok) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                ok ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 15,
                color: ok ? AppColors.success : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ok ? AppColors.success : AppColors.textMuted,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _RegisterDone extends StatelessWidget {
  const _RegisterDone({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    return AppScaffold(
      title: l10n.registerTitle,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.registerDoneTitle,
              textAlign: TextAlign.center,
              style: t.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.registerDoneBody(email),
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.registerDoneButton,
              onPressed: () => context.go(Routes.login),
            ),
          ],
        ),
      ),
    );
  }
}
