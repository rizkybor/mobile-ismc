// Alat bantu dev: masuk dengan akun seed emulator dan TETAP masuk, sehingga
// build normal yang dipasang setelahnya langsung menampilkan Beranda
// (sesi Firebase Auth tersimpan di keychain/keystore perangkat).
//   flutter test integration_test/dev_sign_in_seed_test.dart -d <device> \
//     --dart-define-from-file=env/dev.json
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ism_customer/core/config/env.dart';
import 'package:ism_customer/data/firebase.dart';

// Akun seed emulator — bukan kredensial nyata.
const seedEmail = 'ops@samudra.example.com';
const seedPassword = 'Cust#2026!';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('masuk akun seed dan biarkan sesi tersimpan', (tester) async {
    expect(Env.useEmulator, isTrue);
    expect(await initFirebase(), isTrue);
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInWithEmailAndPassword(
        email: seedEmail,
        password: seedPassword,
      );
    }
    expect(auth.currentUser?.email, seedEmail);
  });
}
