import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/auth_rules.dart';
import '../../../shared/widgets/widgets.dart';
import '../auth_error_text.dart';
import '../session_controller.dart';
import '../widgets/google_sign_in_button.dart';
import 'auth_form_shell.dart';

/// F-01.2 Masuk. Sukses → guard router mengarahkan ke Beranda; email belum
/// diverifikasi → layar verifikasi.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    // Sesi tersimpan yang ditolak saat aplikasi dibuka (akun nonaktif, dsb.).
    final last = ref.read(sessionProvider).lastError;
    if (last != null) {
      _error = last;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(sessionProvider.notifier).clearError(),
      );
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
          .read(sessionProvider.notifier)
          .signIn(_email.text.trim(), _password.text);
      // Navigasi ditangani guard (`ready` → Beranda, `needsVerification` →
      // verify-email).
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    if (_loading || _googleLoading) return;
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).signInWithGoogle();
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthFormShell(
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
      children: [
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: l10n.fieldEmail,
                  semanticId: 'login-email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  prefixIcon: Icons.mail_outline_rounded,
                  onChanged: (_) =>
                      _error == null ? null : setState(() => _error = null),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return l10n.validationRequired;
                    if (!AuthRules.validateEmail(s)) {
                      return l10n.validationEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: l10n.fieldPassword,
                  semanticId: 'login-password',
                  controller: _password,
                  secure: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  prefixIcon: Icons.lock_outline_rounded,
                  onChanged: (_) =>
                      _error == null ? null : setState(() => _error = null),
                  validator: (v) =>
                      (v ?? '').isEmpty ? l10n.validationRequired : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(Routes.forgotPassword),
                    child: Text(l10n.loginForgot),
                  ),
                ),
                if (_error != null) ...[
                  InlineMessage(text: authErrorText(l10n, _error!)),
                  const SizedBox(height: AppSpacing.lg),
                ] else
                  const SizedBox(height: AppSpacing.sm),
                AppButton(
                  semanticId: 'login-submit',
                  label: l10n.loginButton,
                  loading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        GoogleSignInButton(onPressed: _google, loading: _googleLoading),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.loginNoAccount),
            TextButton(
              onPressed: () => context.pushReplacement(Routes.register),
              child: Text(l10n.loginRegisterLink),
            ),
          ],
        ),
      ],
    );
  }
}
