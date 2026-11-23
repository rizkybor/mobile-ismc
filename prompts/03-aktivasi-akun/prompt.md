# Tahap 3 — Aktivasi akun

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
Menentukan status akun customer dan memandu aktivasi (PRD F-02, flowchart §4).

## Kerjakan
1. `src/lib/accountStatus.ts` (fungsi murni): input daftar dokumen `customers` → ambil yang `isDeleted === false`, terbaru (`createdAt`) → status `unregistered | waiting | inactive | active` sesuai PRD F-02.1.
2. `src/services/customers.ts`: query **persis** `where("email", "==", user.email)`; listener supaya status berubah otomatis saat admin memverifikasi.
3. Kartu status di Beranda untuk selain `active`: stepper 3 langkah (Daftar akun ✓ → Lengkapi data perusahaan → Verifikasi admin "Biasanya 1×24 jam kerja"); `inactive` → kartu merah "Akun Anda tidak aktif. Hubungi admin Indo Safety Marine." dengan tombol telepon/email kontak ISM (ambil dari konfigurasi, bukan hard-code tersebar).
4. Layar `aktivasi`: toggle Perusahaan/Perorangan; nama perusahaan (wajib bila perusahaan), No. HP (angka, wajib), telepon kantor (opsional), alamat (wajib, multiline).
   - Cek dulu `customers where email == email`; ada → "Data customer dengan email ini sudah ada. Hubungi admin bila perlu diperbarui."
   - `addDoc(customers, { customerName (perorangan = nama akun), statusCustomer, address, email, telp, phone, isActive: false, isVerify: false, isRegistered: true, isDeleted: false, createdAt, createdBy: "Self", updatedBy: "", updatedAt: "", deletedAt: "", deletedBy: "" })`.
   - Notifikasi tim: `addDoc(notifications, { audience: "panel", roles: null, customerId: "", customerEmail: "", type: "account", title: "Customer baru menunggu verifikasi", body: <customerName>, orderId: "", ordersNo: "", link: { name: "customers-list" }, readBy: [], createdAt, createdBy: <nama>, createdByUid: uid })` — gagal tidak membatalkan aktivasi.
5. Tab Lacak & Notifikasi disembunyikan/terkunci selama status ≠ `active`.

## Kriteria selesai
- [ ] Unit test 4 status + data ganda (yang dihapus diabaikan).
- [ ] Akun baru: isi aktivasi → status "Menunggu verifikasi"; verifikasi di Admin Panel (emulator) → aplikasi otomatis berubah "Aktif" tanpa login ulang.
- [ ] Rules tidak menolak (bila ditolak, periksa bentuk data, jangan ubah rules dari repo ini).
