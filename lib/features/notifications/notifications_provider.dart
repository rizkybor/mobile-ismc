import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firebase_providers.dart';
import '../../data/notifications_repository.dart';
import '../../domain/notification_models.dart';
import '../activation/account_status_provider.dart';
import '../auth/session_controller.dart';

/// Listener notifikasi realtime (hanya saat akun aktif — NF-6 kuota).
final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(sessionProvider).user;
  if (user == null ||
      !ref.watch(firebaseReadyProvider) ||
      !ref.watch(isAccountActiveProvider)) {
    return Stream.value(const []);
  }
  return ref.watch(notificationsRepositoryProvider).watchForEmail(user.email);
});

/// Jumlah belum dibaca untuk badge tab.
final unreadCountProvider = Provider<int>((ref) {
  final uid = ref.watch(sessionProvider).user?.uid;
  final list = ref.watch(notificationsProvider).value ?? const [];
  return uid == null ? 0 : NotificationRules.unreadCount(list, uid);
});
