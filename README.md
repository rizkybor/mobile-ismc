# ISM Customer — Aplikasi Mobile (Android & iOS)

Aplikasi mobile untuk **customer PT Indo Safety Marine** memantau order kalibrasi yang dibuat tim ISM di **ISM CSMS**: progres 7 tahap, dokumen resmi (Penawaran, Invoice, Sertifikat), dan notifikasi. Customer **tidak** membuat order dan tidak ada fitur chat.

Aplikasi **dua bahasa: Bahasa Indonesia (default) & English**, bisa diganti kapan saja di aplikasi.

Dibangun dengan **Flutter** (Android & iOS satu codebase). Backend memakai Firebase project CSMS yang sudah ada (Authentication + Cloud Firestore, paket Spark) dan Security Rules yang sama dengan portal web.

## Dokumen

> Folder `docs/` dan `prompts/` adalah dokumen internal dan **tidak disimpan di git** (lihat `.gitignore`). Minta salinannya ke tim ISM; tautan di bawah berlaku pada salinan lokal.

| Dokumen | Isi |
|---|---|
| [docs/01-BRD.md](docs/01-BRD.md) | Kebutuhan bisnis: tujuan & KPI, ruang lingkup, aturan bisnis, risiko, keputusan yang dibutuhkan |
| [docs/02-PRD.md](docs/02-PRD.md) | Kebutuhan produk: arsitektur, fitur & kriteria penerimaan, kontrak data Firestore, logika 7 tahap, dokumen PDF, desain |
| [docs/03-FLOWCHART.md](docs/03-FLOWCHART.md) | Diagram alur (Mermaid): aplikasi, daftar, masuk, aktivasi, siklus order, 7 tahap, PDF, notifikasi, hapus akun, tahapan pengembangan |
| [docs/03-FLOWCHART.pdf](docs/03-FLOWCHART.pdf) | Versi PDF flowchart untuk dibagikan / dicetak |

## Tahapan pengembangan & prompt

Setiap tahap punya `prompt.md` siap dipakai (developer atau AI coding agent). Kerjakan berurutan; satu tahap = satu PR.

| Tahap | Prompt | Hasil |
|---|---|---|
| 1 | [prompts/01-fondasi-proyek](prompts/01-fondasi-proyek/prompt.md) | Flutter, navigasi (go_router), desain sistem, i18n, Firebase (produksi & emulator), CI |
| 2 | [prompts/02-autentikasi](prompts/02-autentikasi/prompt.md) | Daftar, verifikasi email, masuk, lupa password, sesi |
| 3 | [prompts/03-aktivasi-akun](prompts/03-aktivasi-akun/prompt.md) | Status akun & form data perusahaan |
| 4 | [prompts/04-beranda-daftar-order](prompts/04-beranda-daftar-order/prompt.md) | Beranda, ringkasan, order terbaru, offline cache |
| 5 | [prompts/05-lacak-order](prompts/05-lacak-order/prompt.md) | Daftar order & detail stepper 7 tahap + riwayat |
| 6 | [prompts/06-dokumen-pdf](prompts/06-dokumen-pdf/prompt.md) | Buka/simpan/bagikan PDF sesuai aturan pembayaran |
| 7 | [prompts/07-notifikasi](prompts/07-notifikasi/prompt.md) | Notifikasi in-app realtime, status baca, persiapan push |
| 8 | [prompts/08-profil-akun](prompts/08-profil-akun/prompt.md) | Profil, foto, ganti password, hapus akun |
| 9 | [prompts/09-quality-assurance](prompts/09-quality-assurance/prompt.md) | Panduan pertama login (coach-mark, bisa dilewati), unit ≥ 80 % domain, integrasi emulator, E2E Maestro, checklist & laporan QA |
| 10 | [prompts/10-rilis-store](prompts/10-rilis-store/prompt.md) | Build AAB/IPA, materi store, privasi, rilis bertahap |

**Cara memakai prompt:** buka prompt tahap yang dikerjakan, tempelkan ke agent/assistant di root repo ini (setelah Tahap 1 berisi kode), minta agent membaca `docs/` lebih dulu, lalu review hasil terhadap bagian **Kriteria selesai**.

## Pengembangan

### Prasyarat

- Flutter stable 3.47+ (`flutter doctor` bersih untuk Android & iOS), Xcode 15+ dan CocoaPods untuk iOS, Android Studio / SDK 36 untuk Android.
- Node.js 20+ dan Firebase CLI untuk menjalankan Firebase Emulator dari repo CSMS.

### Konfigurasi (`env/`)

Kunci Firebase **tidak** disimpan di repo. Salin contoh lalu isi nilainya dari Firebase Console (Project settings → Your apps):

```bash
cp env/example.json env/dev.json   # env/*.json di-ignore git, kecuali example.json
```

| Kunci | Keterangan |
|---|---|
| `FIREBASE_API_KEY`, `FIREBASE_PROJECT_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_STORAGE_BUCKET` | Dari Firebase Console (project CSMS) |
| `FIREBASE_APP_ID_ANDROID`, `FIREBASE_APP_ID_IOS` | App ID per platform; untuk emulator boleh nilai dummy |
| (emulator) | Saat `USE_EMULATOR=true`, API key boleh dummy **tetapi harus berformat valid**: 39 karakter diawali `AIza` (nilai di `env/example.json` sudah memenuhi); iOS menolak format lain saat start |
| `USE_EMULATOR` | `true` → Auth `:9099` & Firestore `:8086` di emulator lokal |
| `EMULATOR_HOST` | Kosong = otomatis (`10.0.2.2` emulator Android, `localhost` simulator iOS). HP fisik: isi IP komputer |
| `PUSH_ENABLED` | Fase 2 (push notification) |
| `PRIVACY_POLICY_URL` | Tautan kebijakan privasi di Profil |

Konfigurasi dibaca lewat `--dart-define-from-file`, jadi **tidak ada** `firebase_options.dart`, `google-services.json`, atau `GoogleService-Info.plist` di repo.

### Firebase Emulator (data uji)

Dari repo `admin-indosafetymarine`:

```bash
cd ../admin-indosafetymarine/qa/automation
npm install
npm run emulators     # Auth 9099, Firestore 8086, UI http://localhost:4000
npm run seed          # di terminal lain: isi akun & order contoh
```

Akun customer seed: `ops@samudra.example.com` / `Cust#2026!`.

### Menjalankan

```bash
flutter pub get                      # juga menghasilkan lib/l10n/generated/
tool/run.sh                          # = flutter run --dart-define-from-file=env/dev.json
tool/run.sh dev -d <device-id>       # pilih perangkat (flutter devices)
```

Di mode debug ada tombol serangga (kanan bawah) → panel debug: ganti bahasa ID/EN, status koneksi Firebase/emulator, tombol **masuk akun seed & hitung order** untuk membuktikan koneksi, dan saklar guard dummy.

### Uji di iPhone fisik (kabel)

1. Sambungkan iPhone dengan kabel, buka kunci layar, pilih **Trust** saat ditanya. Di iPhone aktifkan **Settings → Privacy & Security → Developer Mode** (iOS 16+), lalu restart bila diminta.
2. Signing: buka `ios/Runner.xcworkspace` di Xcode sekali, target **Runner → Signing & Capabilities**, centang *Automatically manage signing* dan pilih Team (akun Apple ID pribadi cukup untuk development; untuk TestFlight/App Store dibutuhkan akun Apple Developer atas nama PT, lihat Tahap 10). Bundle id `id.co.indosafetymarine.customer` harus unik di team tersebut.
3. Cek perangkat terdeteksi lalu jalankan:

   ```bash
   flutter devices                 # catat id iPhone (bukan simulator)
   tool/run.sh dev -d <id-iphone>  # build + install + hot reload
   ```

   Pertama kali, iPhone akan menolak membuka aplikasi: **Settings → General → VPN & Device Management → Developer App → Trust**.
4. Firebase Emulator dari HP fisik: emulator berjalan di Mac, jadi isi `EMULATOR_HOST` di `env/dev.json` dengan IP Mac di Wi-Fi yang sama (mis. `192.168.1.10`, lihat `ipconfig getifaddr en0`). Emulator CSMS harus menerima koneksi dari luar localhost: tambahkan `"host": "0.0.0.0"` pada bagian `auth` dan `firestore` di `admin-indosafetymarine/qa/automation/firebase.json`, lalu jalankan ulang `npm run emulators`. HP dan Mac harus di jaringan Wi-Fi yang sama.
5. Profil/release build untuk menguji performa nyata: `flutter run --profile -d <id-iphone> --dart-define-from-file=env/dev.json`.

Catatan: sertifikat development Apple ID gratis kedaluwarsa tiap 7 hari dan hanya untuk maksimal 3 aplikasi per perangkat; cukup jalankan ulang `tool/run.sh` untuk memperbarui.

### Kualitas

```bash
flutter analyze --fatal-infos
dart format --set-exit-if-changed lib test tool
dart run tool/check_hardcoded_text.dart   # semua teks UI harus lewat l10n
flutter test
```

Ketiganya plus `flutter build apk --debug` dijalankan GitHub Actions di setiap PR (`.github/workflows/ci.yml`).

### Integration test (Firebase Emulator) & E2E

```bash
# emulator CSMS jalan + seed, env/dev.json dengan EMULATOR_HOST kosong untuk simulator
flutter test integration_test/auth_emulator_test.dart -d <simulator-id> --dart-define-from-file=env/dev.json
flutter test --coverage      # unit + widget; cakupan di coverage/lcov.info
```

E2E Maestro: alur di `.maestro/` (daftar → aktivasi, login → Lacak → Penawaran, notifikasi, bahasa & keluar), masing-masing bisa dijalankan dengan `-e LANG=id|en`. Pasang CLI dulu (`curl -Ls https://get.maestro.mobile.dev | bash`), lihat `.maestro/README.md`.

Checklist uji manual dan laporan QA ada di `docs/QA-CHECKLIST.md` dan `docs/QA-REPORT.md` (dokumen internal).

### Multi-bahasa

Teks UI ada di `lib/l10n/app_id.arb` (sumber) dan `app_en.arb`; `flutter gen-l10n` membuat `lib/l10n/generated/` (di-ignore git). Pakai `context.l10n.<kunci>`. Test memastikan kunci ID = EN dan tidak ada nilai kosong. Bahasa awal selalu Indonesia; pilihan customer tersimpan di `shared_preferences` (`app.language`).

### Ikon & splash

Sumber `assets/images/` (logo ISM di atas putih). Regenerasi bila berubah:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Keputusan yang masih terbuka

Lihat BRD §11: push notification (paket Blaze), metode masuk (Google/Apple), mekanisme hapus akun, pendaftaran mandiri, nama & akun developer store.

## Repo terkait

- **admin-indosafetymarine** — ISM CSMS (Admin Panel + portal web customer), sumber Security Rules, helper `orderTracking.js`, dan seed Firebase Emulator (`qa/automation`).
