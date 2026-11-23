import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_user.dart';
import '../domain/auth_rules.dart';
import 'firebase_providers.dart';

/// Koleksi `users/{username}` dan `roles/{uid}` (PRD §6). Bentuk dokumen
/// **sama persis** dengan portal web agar lolos Security Rules.
class UsersRepository {
  UsersRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _roles =>
      _db.collection('roles');

  /// Rules hanya mengizinkan `get` bila dokumen belum ada; ditolak
  /// (`permission-denied`) berarti username sudah dipakai.
  Future<bool> isUsernameTaken(String username) async {
    try {
      final doc = await _users.doc(username).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return true;
      rethrow;
    }
  }

  Future<void> createCustomerUser({
    required String uid,
    required String username,
    required String name,
    required String email,
  }) {
    return _users.doc(username).set({
      'userId': uid,
      'email': email,
      'username': username,
      'name': name,
      'role': 'customer',
      'isActive': true,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'createdBy': 'Customer',
      'updatedBy': '',
      'updatedAt': '',
    });
  }

  /// `users where userId == uid limit 1` → data mentah, atau `null`.
  Future<Map<String, Object?>?> findByUid(String uid) async {
    final snap = await _users.where('userId', isEqualTo: uid).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data();
  }

  /// Validasi login seperti web: ada dokumen, role customer, tidak nonaktif.
  Future<AppUser> loadCustomer(String uid) async {
    final data = await findByUid(uid);
    if (data == null) throw const AuthFailure(AuthErrorKind.notRegistered);
    if (!AuthRules.isCustomerRole(data['role'])) {
      throw const AuthFailure(AuthErrorKind.notCustomer);
    }
    if (data['isActive'] == false) {
      throw const AuthFailure(AuthErrorKind.accountDisabled);
    }
    return AppUser.fromMap(uid, data);
  }

  /// `roles/{uid}` dibuat bila belum ada (CSMS `ensureCustomerRole`).
  Future<void> ensureCustomerRole(String uid, String email) async {
    final ref = _roles.doc(uid);
    final doc = await ref.get();
    if (doc.exists) return;
    await ref.set({
      'role': 'customer',
      'email': email,
      'username': '',
      'active': true,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }
}

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepository(ref.watch(firestoreProvider)),
);
