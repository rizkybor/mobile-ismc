# Tahap 9 — Quality assurance

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
Membuktikan aplikasi siap rilis: test otomatis, uji perangkat, kinerja, keamanan.

## Kerjakan
1. Lengkapi unit test `src/lib/*` (target cakupan ≥ 80% untuk `src/lib`).
2. Test integrasi ke Firebase Emulator (Jest, project `demo-*` atau seed CSMS): query orders/customers/notifications sesuai bentuk rules; dokumen terkunci ditolak; customer lain tidak bisa membaca order.
3. E2E **Maestro** (`.maestro/`): (a) daftar → verifikasi (aktifkan lewat Emulator REST) → aktivasi; (b) login seed → Beranda → Lacak → detail 006 → buka Penawaran; (c) notifikasi → detail order; (d) keluar. Jalankan di emulator Android & simulator iOS.
4. Checklist manual `docs/QA-CHECKLIST.md`: layar kecil (360×640) & besar, mode gelap (bila ada), ukuran huruf sistem besar, jaringan 3G/offline, rotasi, izin kamera ditolak, sesi kedaluwarsa, akun dinonaktifkan saat sedang login.
5. Kinerja: cold start, ukuran APK/IPA, jumlah baca Firestore per sesi (log mode dev) — catat di laporan.
6. Keamanan: tidak ada log data pribadi; `.env` tidak ter-bundle selain `EXPO_PUBLIC_*` yang memang publik; tidak ada akses ke koleksi di luar PRD §6.

## Kriteria selesai
- [ ] Semua test hijau di CI; laporan QA (lulus/gagal per skenario, temuan + prioritas) di `docs/QA-REPORT.md`.
