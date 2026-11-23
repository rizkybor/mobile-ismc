# Tahap 7 — Notifikasi

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
Notifikasi in-app realtime dengan status baca; persiapan push Fase 2 (PRD F-06, flowchart §8).

## Kerjakan
1. `src/services/notifications.ts`: listener `query(collection(db,"notifications"), where("customerEmail","==",email))` — **tanpa orderBy/limit** (rules); urutkan & batasi 100 terbaru di aplikasi; abaikan `audience !== "customer"`.
2. Belum dibaca: `!readBy.includes(uid)`. Tandai dibaca: `updateDoc(ref, { readBy: arrayUnion(uid) })` (rules hanya mengizinkan menambah uid sendiri ke `readBy`). "Tandai semua dibaca" memakai batch kecil.
3. Tab Notifikasi: daftar (ikon per `type`: order/approval/success/warning/error/info), waktu relatif ("5 mnt lalu", "Kemarin", tanggal), titik biru belum dibaca; tap → tandai dibaca → buka detail order bila `orderId`.
4. Badge jumlah belum dibaca di tab; `Notifications.setBadgeCountAsync` (iOS) opsional.
5. Fase 2 (siapkan, matikan lewat flag `EXPO_PUBLIC_PUSH_ENABLED`): minta izin, ambil token (`getDevicePushTokenAsync` untuk FCM/APNs), simpan `pushTokens/{token}` `{ uid, email, role: "customer", panel: false, platform, updatedAt }`, hapus saat keluar; handler tap push → deep link order. Catat di PR bahwa pengiriman butuh Cloud Function `sendPushOnNotification` (repo CSMS, paket Blaze) yang diperluas untuk token mobile.

## Kriteria selesai
- [ ] Admin Panel mengubah status order (emulator) → notifikasi muncul di aplikasi < 3 detik saat aplikasi terbuka.
- [ ] Status baca tersimpan dan sinkron dengan lonceng di portal web.
- [ ] Unit test pengurutan & hitung belum dibaca.
