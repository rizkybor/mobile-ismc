# Tahap 6 — Dokumen PDF

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
Customer dapat membuka, menyimpan, dan membagikan Penawaran, Invoice, Sertifikat sesuai aturan pembayaran (PRD F-05, §9, flowchart §7).

## Kerjakan
1. `src/lib/documents.ts`:
   - `customerDocuments(order)` → `[{ type, title, owner, docId, fileName, free }]`: invoice (`invoiceId` + `invoicePdf.docId`, owner `{ invoiceId }`), lalu `quotation`, `certificateGas`, `certificateUti`, `certificateKan` dari `pdfFiles` (owner = orderId). Judul: "Penawaran (Quotation)", "Invoice", "Sertifikat Kalibrasi Gas Meter/UTI Meter/KAN".
   - `canDownload(order, type)`: quotation → true; lainnya → `invoiceStatus === "Lunas" || invoiceTempo === true`.
   - `paymentState(order)`: Lunas / Tempo / Belum Dibayar / null.
2. `src/services/documents.ts`: `fetchPdf(owner, docId, onProgress)` → `getDoc` arsip → bila tanpa `chunks` & ada `path` → error `legacy`; query `collection(..., "chunks")` `orderBy("n")`; jumlah ≠ `chunks` → error `incomplete`; gabung `data` → `FileSystem.writeAsStringAsync(cache/<docId>.pdf, base64, { encoding: Base64 })`. Cache: bila file ada & ukuran > 0 → pakai langsung.
3. UI di detail order: kartu Dokumen + chip pembayaran; item terkunci (ikon gembok, teks "Bisa diunduh setelah pembayaran dikonfirmasi"); Penawaran selalu terbuka. Teks bawah: "Invoice & sertifikat bisa diunduh setelah invoice terbit dan dibayar." / bila Tempo: tampilkan catatan tempo bila ada.
4. Layar `pdf-viewer`: pratinjau (react-native-pdf pada development build, atau WebView fallback), tombol **Bagikan** (`expo-sharing`, nama file asli) dan judul dokumen.
5. Bersihkan cache dokumen saat keluar akun.

## Kriteria selesai
- [ ] Order 006 (seed): Penawaran terbuka; Sertifikat terkunci.
- [ ] Setelah Admin menandai invoice Lunas (emulator) → Invoice & Sertifikat terbuka tanpa login ulang (tarik untuk segarkan).
- [ ] Mencoba membaca dokumen terkunci langsung lewat SDK → ditolak rules (tulis sebagai test integrasi emulator).
- [ ] Unit test `customerDocuments`, `canDownload`, perakitan chunk (urutan, jumlah kurang).
