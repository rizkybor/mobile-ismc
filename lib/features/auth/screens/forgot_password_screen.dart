import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/auth_repository.dart';
import '../../../domain/auth_rules.dart';
import '../../../shared/widgets/widgets.dart';
import '../auth_error_text.dart';
import 'auth_form_shell.dart';

/// F-01.3 Lupa password — pesan selalu netral agar email tidak bisa ditebak.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _done = false;
  Object? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordReset(_email.text.trim());
      if (mounted) setState(() => _done = true);
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
      title: l10n.forgotPasswordTitle,
      subtitle: l10n.forgotSubtitle,
      children: [
        if (_done) ...[
          InlineMessage(text: l10n.forgotDone, tone: InlineMessageTone.success),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.forgotBackToLogin,
            variant: AppButtonVariant.outline,
            onPressed: () => context.pop(),
          ),
        ] else
          Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: l10n.fieldEmail,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  prefixIcon: Icons.mail_outline_rounded,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return l10n.validationRequired;
                    if (!AuthRules.validateEmail(s)) {
                      return l10n.validationEmail;
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
                  label: l10n.forgotButton,
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
