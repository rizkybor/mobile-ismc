# Tahap 5 — Lacak Order (7 tahap)

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
Daftar semua order dan layar detail dengan stepper 7 tahap + riwayat (PRD F-04, §8, flowchart §5–6).

## Kerjakan
1. `src/lib/orderTracking.ts`: **port 1:1** dari CSMS `src/helper/orderTracking.js` (TRACK_STEPS, EVENT_LABELS, eventLabel, stepDoneBy, orderEvents, stepStates, buildTracking, hasCertificate). Pertahankan nama fungsi & perilaku; tambah tipe TypeScript.
2. Unit test minimal (data dari seed CSMS `qa/automation/seed/seed.mjs`):
   - Order `Waiting for Inspection process` → tahap 1 berjalan.
   - `Waiting for Client to approve Inspection` + `quotationNo` → tahap 2 berjalan, catatan "Penawaran …".
   - `Final Order` + `poNumber` tanpa sertifikat → tahap 4 berjalan, catatan "PO …".
   - Sertifikat ada tanpa PO → tahap 4 selesai, catatan "Dicetak tanpa PO"; invoice terbit belum bayar → tahap 5 tertunda "Menunggu pembayaran".
   - Tempo → tahap 5 tertunda "Tempo"; Lunas + DO → selesai semua.
   - `Inspection Rejected` → tahap 2 ditolak; `Rejected` → tahap 4 ditolak.
   - Order tanpa `statusHistory` → riwayat disusun dari data (quotation, sertifikat, invoice, DO).
3. Layar Lacak: daftar dengan pencarian (No. order, vessel, status, produk) & filter Berjalan/Selesai; kartu menampilkan tahap saat ini + "n/7 tahap".
4. Layar detail `order/[orderId]` (bisa dibuka dari notifikasi/deep link): kepala (No. order, tanggal, vessel, chip status), **stepper vertikal** (ikon status, label, "Selesai · tanggal"/"Sedang berjalan"/"Tertunda"/"Ditolak"/"Menunggu", catatan kecil), **daftar alat** (produk, merk, tipe, S/N), **riwayat** (5 terbaru + "Tampilkan semua"), tempat dokumen (diisi Tahap 6), tombol bagikan ringkasan.
5. Detail mengambil order langsung (`getDoc(orders/{id})`) agar data paling baru; `id` bukan milik customer → layar "Order tidak ditemukan".

## Kriteria selesai
- [ ] Semua unit test di atas lulus dan hasilnya sama dengan Lacak Order di portal web untuk order seed 001–006.
- [ ] Deep link `ismcustomer://order/<id>` membuka detail.
