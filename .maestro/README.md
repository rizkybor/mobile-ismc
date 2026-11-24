# E2E Maestro

Alur utama dijalankan dalam **ID** dan **EN** terhadap Firebase Emulator (seed CSMS).

```bash
# 1. Emulator + seed (repo CSMS)
cd ../admin-indosafetymarine/qa/automation && npm run emulators   # terminal 1
npm run seed                                                      # terminal 2
# 2. Pasang aplikasi (env/dev.json → USE_EMULATOR, EMULATOR_HOST kosong untuk simulator)
flutter build ios --simulator --dart-define-from-file=env/dev.json
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
# 3. Jalankan
maestro test .maestro/            # semua alur
maestro test .maestro/02-login-home-tracking-document.yaml -e LANG=en
```

Elemen penting diberi `Semantics(identifier:)` (`login-email`, `login-password`,
`login-submit`, `welcome-login`). Teks tombol/tab dicocokkan per bahasa lewat variabel `LANG`.
