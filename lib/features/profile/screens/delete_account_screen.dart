import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/auth_error_text.dart';
import '../../auth/screens/auth_form_shell.dart';
import '../../auth/session_controller.dart';

/// F-07.4 Hapus akun (syarat store): penjelasan → ketik HAPUS + password →
/// re-autentikasi → tandai permintaan (bila rules mengizinkan) → hapus
/// akun Auth → keluar. Guard router lalu mengarahkan ke Welcome.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _form = GlobalKey<FormState>();
  final _confirm = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  Object? _error;

  @override
  void dispose() {
    _confirm.dispose();
    _password.dispose();
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
      final marked = await ref
          .read(sessionProvider.notifier)
          .deleteAccount(_password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            marked
                ? l10n.deleteDone
                : '${l10n.deleteDone} ${l10n.deleteMarkFailedNote}',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
      // Navigasi ke Welcome ditangani guard (sesi → signedOut).
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    final typed = _confirm.text.trim() == l10n.deleteTypeWord;
    return AuthFormShell(
      title: l10n.deleteTitle,
      subtitle: l10n.deleteSubtitle,
      showLanguageToggle: false,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in [
                l10n.deleteExplain1,
                l10n.deleteExplain2,
                l10n.deleteExplain3,
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.circle, size: 6, color: AppColors.error),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(s, style: t.bodyMedium)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: l10n.deleteTypeLabel,
                controller: _confirm,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.keyboard_outlined,
                onChanged: (_) => setState(() {}),
                validator: (v) => (v ?? '').trim() == l10n.deleteTypeWord
                    ? null
                    : l10n.deleteTypeMismatch,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.fieldPassword,
                controller: _password,
                secure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                prefixIcon: Icons.lock_outline_rounded,
                validator: (v) =>
                    (v ?? '').isEmpty ? l10n.validationRequired : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_error != null) ...[
                InlineMessage(text: authErrorText(l10n, _error!)),
                const SizedBox(height: AppSpacing.lg),
              ],
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: typed && !_loading ? _submit : null,
                icon: _loading
                    ? const AppLoader(size: 7, color: Colors.white)
                    : const Icon(Icons.delete_forever_rounded),
                label: Text(l10n.deleteButton),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
