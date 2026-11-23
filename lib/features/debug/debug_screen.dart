import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/i18n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/firebase_providers.dart';
import '../../data/orders_repository.dart';
import '../../shared/widgets/widgets.dart';
import '../auth/session_controller.dart';
import 'language_toggle.dart';

/// Akun seed Firebase Emulator (repo CSMS `qa/automation/seed/seed.mjs`).
/// Hanya dipakai di mode debug terhadap emulator — bukan kredensial nyata.
const _seedEmail = 'ops@samudra.example.com';
const _seedPassword = 'Cust#2026!';

/// Layar debug (hanya `kDebugMode`): ganti bahasa, info koneksi Firebase,
/// uji login seed + hitung dokumen `orders`, toggle guard dummy.
class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  bool _busy = false;
  int? _count;
  String? _error;

  Future<void> _loginAndCount() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = ref.read(firebaseAuthProvider);
      if (auth.currentUser == null) {
        await auth.signInWithEmailAndPassword(
          email: _seedEmail,
          password: _seedPassword,
        );
      }
      final orders = await ref
          .read(ordersRepositoryProvider)
          .fetchCustomerOrders(auth.currentUser!.email!);
      setState(() => _count = orders.length);
    } on Object catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(kDebugMode, 'DebugScreen hanya untuk mode debug');
    final l10n = context.l10n;
    final firebaseReady = ref.watch(firebaseReadyProvider);
    final session = ref.watch(sessionProvider);
    final user = firebaseReady
        ? ref.watch(firebaseAuthProvider).currentUser
        : null;

    return AppScaffold(
      title: l10n.debugTitle,
      body: ListView(
        children: [
          AppCard(
            child: Row(
              children: [
                Expanded(child: Text(l10n.languageLabel)),
                const LanguageToggle(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  !firebaseReady
                      ? l10n.debugFirebaseNotConfigured
                      : Env.useEmulator
                      ? l10n.debugEmulatorOn(Env.emulatorHost)
                      : l10n.debugEmulatorOff(Env.firebaseProjectId),
                  style: TextStyle(
                    color: firebaseReady
                        ? AppColors.textPrimary
                        : AppColors.error,
                  ),
                ),
                if (user != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.debugSignedInAs(user.email ?? user.uid)),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(
                  session.status.name,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (_count != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.debugOrdersCount(_count!),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: l10n.debugLoginSeed,
                  loading: _busy,
                  onPressed: firebaseReady ? _loginAndCount : null,
                ),
                if (user != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: l10n.debugSignOut,
                    variant: AppButtonVariant.text,
                    onPressed: () async {
                      await ref.read(sessionProvider.notifier).signOut();
                      setState(() => _count = null);
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
