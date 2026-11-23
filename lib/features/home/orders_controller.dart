import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firebase_providers.dart';
import '../../data/orders_repository.dart';
import '../../domain/order_models.dart';
import '../auth/session_controller.dart';

/// Order milik customer yang sedang login. Dimuat manual / periodik (bukan
/// listener — NF-6 kuota). Saat jaringan gagal, memakai cache lokal
/// terakhir bila ada.
class CustomerOrdersController extends AsyncNotifier<List<Order>> {
  DateTime? lastLoadedAt;

  /// `true` bila data yang tampil berasal dari cache (gagal memuat).
  bool fromCache = false;

  @override
  Future<List<Order>> build() async {
    final user = ref.watch(sessionProvider).user;
    if (user == null || !ref.watch(firebaseReadyProvider)) return const [];
    return _load(user.email);
  }

  Future<List<Order>> _load(String email) async {
    final repo = ref.read(ordersRepositoryProvider);
    try {
      final orders = await repo.fetchCustomerOrders(email);
      lastLoadedAt = DateTime.now();
      fromCache = false;
      return orders;
    } on Object catch (e) {
      final cached = repo.readCache(email);
      if (cached == null) rethrow;
      debugPrint('[orders] gagal memuat, pakai cache: $e');
      fromCache = true;
      return cached;
    }
  }

  Future<void> refresh() async {
    final user = ref.read(sessionProvider).user;
    if (user == null) return;
    state = await AsyncValue.guard(() => _load(user.email));
  }

  /// Muat ulang bila data lebih lama dari [maxAge] (dipanggil saat aplikasi
  /// kembali ke foreground — PRD F-03.3: > 5 menit).
  Future<void> refreshIfStale({Duration maxAge = const Duration(minutes: 5)}) {
    final last = lastLoadedAt;
    if (last != null && DateTime.now().difference(last) < maxAge) {
      return Future.value();
    }
    return refresh();
  }
}

final customerOrdersProvider =
    AsyncNotifierProvider<CustomerOrdersController, List<Order>>(
      CustomerOrdersController.new,
    );
