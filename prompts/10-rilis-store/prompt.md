# Tahap 10 — Rilis ke Google Play & App Store

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

## Tujuan
Build produksi dan pengajuan ke store.

## Kerjakan
1. Konfigurasi `app.config.ts` produksi: nama "ISM Customer", versi semver + `buildNumber`/`versionCode`, ikon adaptif Android, splash, `ios.bundleIdentifier` & `android.package` `id.co.indosafetymarine.customer`, deep link scheme `ismcustomer`, izin minimum (kamera & galeri untuk foto profil; notifikasi bila push aktif) dengan teks alasan Bahasa Indonesia.
2. EAS: `eas build --profile production` (Android AAB, iOS IPA); `eas submit`. Simpan kredensial di EAS, bukan di repo.
3. Materi store (folder `store/`): judul, deskripsi singkat & panjang (ID, opsional EN), kata kunci, 4–6 screenshot per platform (data demo, bukan data customer asli), ikon 512/1024, kategori Bisnis.
4. Kebijakan privasi (halaman publik) & formulir **Data Safety** (Play) / **App Privacy** (App Store): email, nama, nomor telepon, alamat perusahaan, foto (opsional); tujuan fungsi aplikasi; tidak dibagikan ke pihak ketiga; tersedia penghapusan akun di aplikasi.
5. Akun uji untuk reviewer (akun customer aktif di **produksi** yang dibuat Admin ISM, berisi order demo) + catatan review: aplikasi untuk customer terdaftar ISM; order dibuat tim ISM.
6. Rilis bertahap: Internal testing → Closed testing (5–10 customer) → Produksi (staged rollout 20% → 100%); iOS: TestFlight → App Review.
7. EAS Update channel `production` untuk perbaikan JS kecil; catat kebijakan versi minimal.

## Kriteria selesai
- [ ] Build produksi terpasang di perangkat nyata dan terhubung ke Firebase produksi (akun uji).
- [ ] Lolos review Google Play & App Store; tautan store dicatat di README.
