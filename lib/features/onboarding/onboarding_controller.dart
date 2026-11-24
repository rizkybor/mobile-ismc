import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/locale_controller.dart';
import '../activation/account_status_provider.dart';
import '../auth/session_controller.dart';

/// Panduan pertama login (PRD F-08.3): tampil sekali per perangkat + uid
/// (`onboarding.done.<uid>`), bisa dilewati, bisa dibuka lagi dari Profil.
class OnboardingController extends Notifier<bool> {
  static String prefKey(String uid) => 'onboarding.done.$uid';

  /// `true` = panduan sedang/harus ditampilkan.
  @override
  bool build() {
    final session = ref.watch(sessionProvider);
    final active = ref.watch(isAccountActiveProvider);
    final uid = session.user?.uid;
    if (uid == null || !session.isReady || !active) return false;
    final done =
        ref.read(sharedPreferencesProvider).getBool(prefKey(uid)) ?? false;
    return !done;
  }

  Future<void> finish({required bool skipped}) async {
    final uid = ref.read(sessionProvider).user?.uid;
    state = false;
    if (uid != null) {
      await ref.read(sharedPreferencesProvider).setBool(prefKey(uid), true);
    }
  }

  /// Dari Profil → "Panduan aplikasi".
  void reopen() => state = true;
}

final onboardingProvider = NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);
