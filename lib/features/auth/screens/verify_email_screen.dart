import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../auth_error_text.dart';
import '../session_controller.dart';
import 'auth_form_shell.dart';

/// Email belum diverifikasi: kirim ulang, "Saya sudah verifikasi", atau
/// keluar untuk masuk dengan akun lain.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _checking = false;
  bool _resending = false;
  String? _message;
  InlineMessageTone _tone = InlineMessageTone.info;

  Future<void> _check() async {
    setState(() {
      _checking = true;
      _message = null;
    });
    final l10n = context.l10n;
    try {
      final ok = await ref.read(sessionProvider.notifier).refreshVerification();
      if (!ok && mounted) {
        setState(() {
          _tone = InlineMessageTone.info;
          _message = l10n.verifyNotYet;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _tone = InlineMessageTone.error;
          _message = authErrorText(l10n, e);
        });
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _message = null;
    });
    final l10n = context.l10n;
    try {
      await ref.read(sessionProvider.notifier).resendVerification();
      if (mounted) {
        setState(() {
          _tone = InlineMessageTone.success;
          _message = l10n.verifyResent;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _tone = InlineMessageTone.error;
          _message = authErrorText(l10n, e);
        });
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = ref.watch(sessionProvider).pendingEmail ?? '';
    return AuthFormShell(
      title: l10n.verifyEmailTitle,
      subtitle: l10n.verifyBody(email),
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_unread_outlined,
              color: AppColors.primary,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_message != null) ...[
          InlineMessage(text: _message!, tone: _tone),
          const SizedBox(height: AppSpacing.lg),
        ],
        AppButton(
          label: l10n.verifyCheck,
          loading: _checking,
          onPressed: _check,
          icon: Icons.verified_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.verifyResend,
          variant: AppButtonVariant.outline,
          loading: _resending,
          onPressed: _resend,
          icon: Icons.send_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.verifySignOut,
          variant: AppButtonVariant.text,
          onPressed: () => ref.read(sessionProvider.notifier).signOut(),
        ),
      ],
    );
  }
}
