import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/account_status.dart';
import 'firebase_providers.dart';

/// Koleksi `customers` & notifikasi aktivasi (PRD §6, F-02). Bentuk query
/// **persis** `where("email", "==", <email login terverifikasi>)` agar lolos
/// rules; pemilihan dokumen terbaru dilakukan di aplikasi.
class CustomersRepository {
  CustomersRepository(this._db);
  final FirebaseFirestore _db;

  Query<Map<String, dynamic>> _byEmail(String email) =>
      _db.collection('customers').where('email', isEqualTo: email);

  Stream<List<CustomerProfile>> watchByEmail(String email) => _byEmail(email)
      .snapshots()
      .map(
        (s) =>
            s.docs.map((d) => CustomerProfile.fromMap(d.id, d.data())).toList(),
      );

  Future<List<CustomerProfile>> fetchByEmail(String email) async {
    final s = await _byEmail(email).get();
    return s.docs.map((d) => CustomerProfile.fromMap(d.id, d.data())).toList();
  }

  /// Aktivasi: satu email hanya boleh punya satu data customer (termasuk
  /// yang sudah dihapus — sama dengan web).
  Future<bool> hasAnyCustomer(String email) async =>
      (await _byEmail(email).limit(1).get()).docs.isNotEmpty;

  /// Dokumen baru `customers` — field sama persis dengan portal web
  /// (`activated_account.vue`). Rules mewajibkan `isVerify == false`,
  /// `isActive == false`, `email == email login`.
  Future<String> createActivation({
    required String email,
    required String customerName,
    required bool isCompany,
    required String address,
    required String phone,
    required String telp,
  }) async {
    final ref = await _db.collection('customers').add({
      'customerName': customerName,
      'statusCustomer': isCompany,
      'address': address,
      'email': email,
      'telp': telp,
      'phone': phone,
      'isActive': false,
      'isVerify': false,
      'isRegistered': true,
      'isDeleted': false,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'createdBy': 'Self',
      'updatedBy': '',
      'updatedAt': '',
      'deletedAt': '',
      'deletedBy': '',
    });
    return ref.id;
  }

  /// Notifikasi ke tim ISM (CSMS `notifyCustomerAccount("requested")`).
  /// Rules `customerNotification()` mengunci judul, type, link, audience.
  Future<void> notifyPanelActivationRequested({
    required String customerName,
    required String createdByName,
    required String uid,
  }) {
    return _db.collection('notifications').add({
      'audience': 'panel',
      'roles': ['Admin', 'Staff'],
      'customerId': '',
      'customerEmail': '',
      'type': 'account',
      'title': 'Customer baru menunggu verifikasi',
      'body': '$customerName mengirim permintaan aktivasi akun.',
      'orderId': '',
      'ordersNo': '',
      'link': {'name': 'customers-list'},
      'readBy': <String>[],
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'createdBy': createdByName,
      'createdByUid': uid,
    });
  }
}

final customersRepositoryProvider = Provider<CustomersRepository>(
  (ref) => CustomersRepository(ref.watch(firestoreProvider)),
);
