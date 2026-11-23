# Tahap 4 — Beranda & daftar order

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
Beranda untuk akun aktif: sapaan, ringkasan, order terbaru (PRD F-03, §7).

## Kerjakan
1. `src/services/orders.ts`: `fetchCustomerOrders(email)` — query **persis** `where("isDeleted","==",false), where("customerEmail","==",email)`; urutkan `createdAt` menurun di aplikasi. Cache hasil terakhir di AsyncStorage (per email) untuk mode offline.
2. `src/lib/orderStatus.ts`: `ORDER_STAGES`, `getOrderStage(statusDesc)` (status tak dikenal → "Dalam proses"), `statusLabel` (label dipendekkan) — sesuai PRD §7.
3. Beranda: header biru (sapaan "Selamat pagi/siang/sore/malam" + nama), 3 kartu statistik (Total, Sedang diproses = total − selesai − ditolak, Selesai), daftar 5 order terbaru → kartu: No. order, tanggal, vessel, produk (titik warna: Gas Meter #0A488F, UTI Meter #8E1028, lainnya #475569), chip status, mini-progress 7 segmen (pakai `buildTracking` dari Tahap 5 — sementara stub), tombol "Lihat semua".
4. Tarik-untuk-segarkan; muat ulang otomatis saat app kembali ke foreground setelah > 5 menit.
5. State kosong, error ("Riwayat order gagal dimuat." + Coba lagi), skeleton saat memuat, banner offline.

## Kriteria selesai
- [ ] Akun seed menampilkan order miliknya saja (bandingkan dengan portal web).
- [ ] Mode pesawat: data terakhir tetap tampil + banner offline.
- [ ] Unit test `getOrderStage`/statistik.
