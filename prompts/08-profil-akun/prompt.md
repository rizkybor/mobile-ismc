# Tahap 8 — Profil & hapus akun

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
Profil, ganti foto & password, kebijakan privasi, dan **hapus akun** (syarat store) (PRD F-07, flowchart §9).

## Kerjakan
1. Layar Profil: avatar, nama, username, email (tidak bisa diubah), role; Data Perusahaan (baca saja: nama customer, No. HP, telepon kantor, alamat) + "Perubahan data perusahaan: hubungi admin ISM".
2. Ganti foto: `expo-image-picker` (kamera/galeri) → potong persegi → resize 256×256 → JPEG 0,85 → data URL → `updateDoc(users/{username}, { photoURL, updatedAt, updatedBy })`. Ukuran sumber maks. 5 MB. Customer **tidak** boleh mengubah `name` (rules) — field nama baca saja.
3. Ganti password: password lama → `reauthenticateWithCredential` → `updatePassword` (syarat sama dengan daftar).
4. **Hapus akun**: layar penjelasan (akun login dihapus; data order, dokumen, dan data perusahaan tetap disimpan ISM sebagai arsip bisnis; untuk menghapus data perusahaan hubungi ISM) → ketik "HAPUS" + password → re-autentikasi → `updateDoc(users/{username}, { deletionRequestedAt, updatedAt, updatedBy })` **(butuh perubahan rules di repo CSMS — PRD §12 butir 2; bila belum tersedia, lewati langkah ini dan catat di PR)** → `user.delete()` → hapus cache → Welcome.
5. Tautan Kebijakan Privasi (URL dari env), Syarat Layanan, kontak ISM, versi aplikasi (`expo-application`).
6. Tombol Keluar dengan konfirmasi.

## Kriteria selesai
- [ ] Foto tersimpan dan tampil juga di portal web.
- [ ] Ganti password berhasil dan login ulang dengan password baru.
- [ ] Hapus akun di emulator: login dengan akun itu gagal setelahnya.
