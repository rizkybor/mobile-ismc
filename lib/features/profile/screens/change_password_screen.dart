import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/auth_repository.dart';
import '../../../domain/auth_rules.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/auth_error_text.dart';
import '../../auth/screens/auth_form_shell.dart';
import '../../auth/screens/register_screen.dart' show PasswordChecklist;

/// F-07.3 Ganti password: re-autentikasi password lama → updatePassword.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _repeat = TextEditingController();
  bool _loading = false;
  Object? _error;

  @override
  void dispose() {
    for (final c in [_current, _next, _repeat]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !(_form.currentState?.validate() ?? false)) return;
    final l10n = context.l10n;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .changePassword(
            currentPassword: _current.text,
            newPassword: _next.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.passwordChanged)));
      context.pop();
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthFormShell(
      title: l10n.profileChangePassword,
      subtitle: l10n.passwordChangeSubtitle,
      showLanguageToggle: false,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: l10n.passwordCurrent,
                controller: _current,
                secure: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.password],
                prefixIcon: Icons.lock_outline_rounded,
                validator: (v) =>
                    (v ?? '').isEmpty ? l10n.validationRequired : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.passwordNew,
                controller: _next,
                secure: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                prefixIcon: Icons.lock_reset_rounded,
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
              PasswordChecklist(password: _next.text),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.passwordNewRepeat,
                controller: _repeat,
                secure: true,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.lock_reset_rounded,
                validator: (v) {
                  if ((v ?? '').isEmpty) return l10n.validationRequired;
                  if (v != _next.text) return l10n.validationPasswordMismatch;
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_error != null) ...[
                InlineMessage(text: authErrorText(l10n, _error!)),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppButton(
                label: l10n.passwordChangeButton,
                loading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
