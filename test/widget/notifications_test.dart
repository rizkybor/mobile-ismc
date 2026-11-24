import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/app/app.dart';
import 'package:ism_customer/domain/notification_models.dart';
import 'package:ism_customer/features/notifications/screens/notifications_screen.dart';
import 'package:ism_customer/features/splash/splash_screen.dart';

import 'test_app.dart';

AppNotification n(
  String id,
  String title, {
  bool read = false,
  String type = 'order',
}) => AppNotification(
  id: id,
  audience: 'customer',
  type: type,
  title: title,
  body:
      'Order OR/20261121/001 sudah kami terima dan sedang diperiksa tim kami.',
  orderId: 'o1',
  ordersNo: 'OR/20261121/001',
  readBy: read ? [testUser.uid] : const [],
  createdAt: DateTime.now()
      .toUtc()
      .subtract(const Duration(minutes: 5))
      .toIso8601String(),
);

Future<void> pumpApp(WidgetTester tester, List<AppNotification> items) async {
  final c = await makeContainer(notifications: items);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: c, child: const IsmCustomerApp()),
  );
  await tester.pump();
  await tester.pump(
    SplashScreen.minimumDuration + const Duration(milliseconds: 100),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'badge tab & daftar dengan judul terjemahan dan titik belum dibaca',
    (tester) async {
      await pumpApp(tester, [
        n('1', 'Order diterima'),
        n('2', 'Service selesai', read: true, type: 'success'),
      ]);
      expect(find.text('1'), findsOneWidget); // badge
      await tester.tap(find.text('Notifikasi'));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsScreen), findsOneWidget);
      expect(find.text('Order diterima'), findsOneWidget);
      expect(find.text('Service selesai'), findsOneWidget);
      expect(find.text('5 mnt lalu'), findsNWidgets(2));
      expect(find.text('1 belum dibaca'), findsOneWidget);
      expect(find.text('Tandai dibaca'), findsOneWidget);
    },
  );

  testWidgets('EN: judul diterjemahkan', (tester) async {
    final c = await makeContainer(
      notifications: [n('1', 'Delivery Order diterbitkan')],
    );
    await tester.pumpWidget(
      wrapScreen(c, const NotificationsScreen(), locale: const Locale('en')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Delivery Order issued'), findsOneWidget);
  });

  testWidgets('kosong', (tester) async {
    await pumpApp(tester, const []);
    await tester.tap(find.text('Notifikasi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada notifikasi'), findsOneWidget);
  });
}
