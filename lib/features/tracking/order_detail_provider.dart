import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firebase_providers.dart';
import '../../data/orders_repository.dart';
import '../../domain/order_models.dart';
import '../auth/session_controller.dart';
import '../home/orders_controller.dart';

/// Detail order: ambil dokumen langsung (`orders/{id}`) agar paling baru;
/// bila gagal (offline) pakai salinan dari daftar/cache. `null` = tidak
/// ditemukan atau bukan milik customer (rules menolak).
final orderDetailProvider = FutureProvider.autoDispose.family<Order?, String>((
  ref,
  id,
) async {
  if (!ref.watch(firebaseReadyProvider) ||
      ref.watch(sessionProvider).user == null) {
    return _fromList(ref, id);
  }
  try {
    return await ref.read(ordersRepositoryProvider).fetchOrder(id);
  } on Object {
    final cached = _fromList(ref, id);
    if (cached != null) return cached;
    rethrow;
  }
});

Order? _fromList(Ref ref, String id) {
  final list = ref.read(customerOrdersProvider).value ?? const [];
  for (final o in list) {
    if (o.id == id) return o;
  }
  return null;
}
