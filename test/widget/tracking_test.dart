import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/domain/order_models.dart';
import 'package:ism_customer/features/home/widgets/order_card.dart';
import 'package:ism_customer/features/tracking/screens/order_detail_screen.dart';
import 'package:ism_customer/features/tracking/screens/tracking_screen.dart';
import 'package:ism_customer/features/tracking/widgets/track_stepper.dart';

import '../fixtures/orders.dart' as fx;
import 'test_app.dart';

void main() {
  group('TrackingScreen', () {
    testWidgets('daftar, filter Selesai, pencarian', (tester) async {
      final c = await makeContainer(
        orders: [fx.o1, fx.o3, fx.o6, fx.completed],
      );
      await tester.pumpWidget(wrapScreen(c, const TrackingScreen()));
      await tester.pumpAndSettle();
      expect(find.text('3 order'), findsOneWidget);
      expect(find.byType(OrderCard), findsAtLeastNWidgets(2));

      await tester.tap(find.text('Selesai').first);
      await tester.pumpAndSettle();
      expect(find.byType(OrderCard), findsOneWidget);
      expect(
        find.text('DO-2611-0001'),
        findsNothing,
      ); // kartu tidak menampilkan DO

      await tester.tap(find.text('Berjalan'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '/006');
      await tester.pumpAndSettle();
      expect(find.byType(OrderCard), findsOneWidget);
      expect(find.text('OR/20261121/006'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('Tidak ada hasil'), findsOneWidget);
    });
  });

  group('OrderDetailScreen', () {
    Future<void> pumpDetail(
      WidgetTester tester, {
      required String id,
      required Order? order,
    }) async {
      // Layar tinggi agar seluruh ListView terbangun (tanpa gulir).
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = await makeContainer(orderDetail: (_) async => order);
      await tester.pumpWidget(wrapScreen(c, OrderDetailScreen(orderId: id)));
      await tester.pumpAndSettle();
    }

    testWidgets('order 006: stepper, catatan PO, daftar alat, riwayat approx', (
      tester,
    ) async {
      await pumpDetail(tester, id: 'o6', order: fx.o6);
      expect(find.text('OR/20261121/006'), findsWidgets);
      expect(find.byType(TrackStepper), findsOneWidget);
      expect(find.text('PO PO-2611-77'), findsOneWidget);
      expect(find.text('Sedang berjalan'), findsOneWidget);
      expect(find.text('Daftar alat'), findsOneWidget);
      expect(find.text('GX-A0'), findsOneWidget);
      expect(
        find.text('Riwayat disusun dari data yang tersedia.'),
        findsOneWidget,
      );
      expect(find.text('Bagikan ringkasan'), findsOneWidget);
    });

    testWidgets('order selesai: riwayat 5 + Tampilkan semua', (tester) async {
      await pumpDetail(tester, id: 'done', order: fx.completed);
      expect(find.text('Selesai'), findsWidgets);
      expect(find.text('Delivery Order diterbitkan'), findsOneWidget);
      expect(find.text('Order dibuat'), findsNothing); // tersembunyi (ke-8)
      await tester.tap(find.text('Tampilkan semua'));
      await tester.pumpAndSettle();
      expect(find.text('Order dibuat'), findsOneWidget);
    });

    testWidgets('tidak ditemukan / bukan milik customer', (tester) async {
      await pumpDetail(tester, id: 'x', order: null);
      expect(find.text('Order tidak ditemukan'), findsOneWidget);
    });
  });
}
