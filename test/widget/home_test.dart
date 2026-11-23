import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/app/app.dart';
import 'package:ism_customer/domain/order_models.dart';
import 'package:ism_customer/features/home/widgets/order_card.dart';
import 'package:ism_customer/features/splash/splash_screen.dart';

import '../fixtures/orders.dart' as fx;
import 'test_app.dart';

Future<void> pumpHome(
  WidgetTester tester, {
  List<Order> orders = const [],
  bool fail = false,
}) async {
  final container = await makeContainer(orders: orders, ordersFail: fail);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const IsmCustomerApp(),
    ),
  );
  await tester.pump();
  await tester.pump(
    SplashScreen.minimumDuration + const Duration(milliseconds: 100),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('statistik & 5 order terbaru + Lihat semua', (tester) async {
    final many = [
      fx.o1,
      fx.o3,
      fx.o5,
      fx.o6,
      fx.completed,
      fx.rejected,
      fx.tempo,
    ];
    await pumpHome(tester, orders: many);
    expect(find.text('Total order'), findsOneWidget);
    expect(find.text('7'), findsOneWidget); // total
    expect(find.text('Selesai'), findsWidgets);
    expect(find.byType(OrderCard), findsNWidgets(5));
    expect(find.text('Lihat semua'), findsOneWidget);
    expect(find.text('OR/20261121/003'), findsOneWidget);
  });

  testWidgets('kosong → pesan kosong', (tester) async {
    await pumpHome(tester);
    expect(find.text('Belum ada order'), findsOneWidget);
    expect(find.byType(OrderCard), findsNothing);
  });

  testWidgets('gagal memuat → pesan error + Coba lagi', (tester) async {
    await pumpHome(tester, fail: true);
    expect(find.text('Riwayat order gagal dimuat.'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('kartu order menampilkan tahap saat ini & progres', (
    tester,
  ) async {
    await pumpHome(tester, orders: [fx.o6]);
    expect(find.text('Sertifikat'), findsOneWidget);
    expect(find.text('4/7 tahap'), findsOneWidget);
    expect(find.text('MT Bahari Jaya'), findsOneWidget);
  });
}
