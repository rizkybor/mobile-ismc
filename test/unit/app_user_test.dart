import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/domain/app_user.dart';
import 'package:ism_customer/domain/notification_models.dart';

void main() {
  test('AppUser.fromMap & copyWith', () {
    final u = AppUser.fromMap('uid1', {
      'username': 'samudra.ops',
      'name': 'Ops Samudra',
      'email': 'ops@samudra.example.com',
      'role': 'customer',
      'photoURL': null,
    });
    expect(u.uid, 'uid1');
    expect(u.photoUrl, '');
    final v = u.copyWith(photoUrl: 'data:x', name: 'Baru');
    expect(v.photoUrl, 'data:x');
    expect(v.name, 'Baru');
    expect(v.email, u.email);
  });

  test('AppNotification.fromMap toleran', () {
    final n = AppNotification.fromMap('n1', {
      'audience': 'customer',
      'type': null,
      'title': 'Order diterima',
      'readBy': ['a', 1],
      'createdAt': '2026-11-21T00:00:00Z',
      'params': {'ordersNo': 'OR/1', 'x': 2},
      'key': 'orderReceived',
    });
    expect(n.type, '');
    expect(n.readBy, ['a', '1']);
    expect(n.params, {'ordersNo': 'OR/1', 'x': '2'});
    expect(n.isUnreadFor('a'), isFalse);
    expect(n.isUnreadFor('z'), isTrue);
    final m = AppNotification.fromMap('n2', {'readBy': 'bukan list'});
    expect(m.readBy, isEmpty);
  });
}
