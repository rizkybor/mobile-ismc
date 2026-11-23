# Tahap 1 — Fondasi proyek

Aplikasi: **ISM Customer** (Android & iOS) — repo `mobile-ismc`.

## Aturan umum (berlaku di semua tahap)

- Baca dulu: `docs/01-BRD.md`, `docs/02-PRD.md`, `docs/03-FLOWCHART.md`. Bila prompt ini bertentangan dengan PRD, ikuti PRD dan sebutkan perbedaannya.
- Stack: Expo (React Native) + TypeScript strict + Expo Router + Firebase JS SDK modular. Jangan menambah library besar tanpa alasan tertulis di PR.
- Backend = Firebase project CSMS yang sudah ada. **Jangan** mengubah struktur data; bentuk query harus sama persis dengan PRD §6 agar lolos Security Rules.
- Rahasia (konfigurasi Firebase) hanya di `.env` (`EXPO_PUBLIC_FIREBASE_*`), tidak di-commit. Sertakan `.env.example`.
- Uji ke **Firebase Emulator** (`EXPO_PUBLIC_USE_EMULATOR=1`), bukan data produksi.
- Teks UI Bahasa Indonesia; tanggal WIB (`Asia/Jakarta`).
- Setiap logika bisnis (status akun, 7 tahap, hak unduh, rakit PDF) berupa fungsi murni di `src/lib/` dengan unit test.
- Selesai = `npm run lint`, `npm run typecheck`, `npm test` bersih + checklist "Kriteria selesai" terpenuhi. Laporkan apa yang diuji dan apa yang belum.

## Peran
Anda senior mobile engineer React Native/Expo yang menyiapkan fondasi aplikasi **ISM Customer** (Android & iOS).

## Tujuan
Proyek siap dikembangkan: struktur folder, navigasi kerangka, desain sistem, koneksi Firebase (produksi & emulator), alat kualitas.

## Kerjakan
1. Buat proyek Expo SDK terbaru (TypeScript, Expo Router). Nama tampilan "ISM Customer", bundle id `id.co.indosafetymarine.customer` (Android `applicationId` sama).
2. Struktur:
   ```
   app/(auth)/  app/(app)/(tabs)/  app/(app)/order/[orderId].tsx
   src/lib/ (logika murni)  src/services/ (firebase, repo data)
   src/components/  src/theme/  src/store/  src/hooks/  assets/
   ```
3. `src/services/firebase.ts`: `initializeApp` dari env; `initializeAuth` + `getReactNativePersistence(AsyncStorage)`; Firestore; bila `EXPO_PUBLIC_USE_EMULATOR=1` → `connectAuthEmulator` (port 9099) & `connectFirestoreEmulator` (port 8086, host dari env agar bisa diakses HP fisik / emulator Android `10.0.2.2`).
4. Desain sistem `src/theme/`: token warna PRD §10 (primer #0A488F, navy #0B1E3A, merah #8E1028, sukses #1E9E6A, peringatan #D98E04, error #B3122E), spasi 4/8/12/16/24, radius 8/12/16, tipografi (Inter atau sistem). Komponen dasar: `Screen`, `AppText`, `Button` (primary/outline/text, loading), `TextField` (label, error, secure toggle), `Card`, `Chip` (status), `EmptyState`, `ErrorState`, `Skeleton`, `OfflineBanner`.
5. Kerangka navigasi: grup `(auth)` dan `(app)` dengan guard dummy; tab Beranda, Lacak, Notifikasi, Profil (ikon MaterialCommunityIcons: home-outline, map-marker-path, bell-outline, account-circle-outline).
6. Aset: ikon & splash dari logo ISM (latar putih, logo di tengah), warna status bar.
7. Kualitas: ESLint + Prettier, `tsc --noEmit`, Jest + React Native Testing Library, skrip `lint`, `typecheck`, `test`. GitHub Actions: jalankan ketiganya di setiap PR.
8. `eas.json` dengan profil `development`, `preview`, `production` (belum perlu build).
9. README pengembangan: cara install, `.env`, menjalankan emulator Firebase (memakai repo CSMS `qa/automation`: `npm run emulators` lalu `npm run seed`), menjalankan di Android/iOS.

## Kriteria selesai
- [ ] Aplikasi berjalan di Android & iOS (Expo Go / development build) dan menampilkan 4 tab kosong.
- [ ] Koneksi emulator terbukti: layar debug kecil (hanya mode dev) menampilkan jumlah dokumen `orders` yang terbaca setelah login akun seed.
- [ ] Lint, typecheck, test, CI hijau.
- [ ] `.env.example` lengkap; tidak ada kunci di git.
