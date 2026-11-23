import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/customers_repository.dart';
import '../../data/firebase_providers.dart';
import '../../domain/account_status.dart';
import '../auth/session_controller.dart';

/// Status akun customer secara realtime (listener `customers where email`),
/// sehingga berubah otomatis ketika admin memverifikasi di Admin Panel.
/// Tanpa sesi / tanpa Firebase → `unregistered`.
final accountStatusProvider = StreamProvider<AccountState>((ref) {
  final user = ref.watch(sessionProvider).user;
  if (user == null || !ref.watch(firebaseReadyProvider)) {
    return Stream.value(const AccountState(AccountStatus.unregistered));
  }
  return ref
      .watch(customersRepositoryProvider)
      .watchByEmail(user.email)
      .map(AccountStatusRules.resolve);
});

/// `true` hanya bila status sudah diketahui **dan** aktif. Dipakai untuk
/// mengunci tab Lacak & Notifikasi.
final isAccountActiveProvider = Provider<bool>(
  (ref) => ref.watch(accountStatusProvider).value?.isActive ?? false,
);
