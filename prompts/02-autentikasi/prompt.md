# Tahap 2 — Autentikasi

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
Customer bisa daftar, verifikasi email, masuk, lupa password, tetap login, dan keluar — perilaku sama dengan portal web CSMS (PRD F-01, flowchart §2–3).

## Kerjakan
1. Layar `welcome`, `login`, `register`, `verify-email`, `forgot-password`.
2. **Daftar**: field nama, username (`/^[A-Za-z0-9._-]+$/`), email, password + ulangi. Indikator syarat password (8+ karakter, huruf besar & kecil, angka, simbol `!@#$%^&*`). Alur:
   - `getDoc(users/{username})` → ada **atau** error `permission-denied` = username dipakai.
   - `createUserWithEmailAndPassword` → `setDoc(users/{username}, { userId, email, username, name, role: "customer", isActive: true, createdAt, createdBy: "Customer", updatedBy: "", updatedAt: "" })`.
   - `roles/{uid}` bila belum ada: `{ role: "customer", email, username: "", active: true, updatedAt }`.
   - `sendEmailVerification` → `signOut` → layar "Cek email Anda".
3. **Masuk**: `signInWithEmailAndPassword` → cek `emailVerified` (tidak → layar verifikasi dengan "Kirim ulang" & "Saya sudah verifikasi" yang memanggil `user.reload()`) → query `users where userId == uid limit 1` → validasi role `customer`/`Customer` & `isActive !== false` → pastikan `roles/{uid}` → simpan sesi di store.
4. **Lupa password**: `sendPasswordResetEmail`; pesan netral.
5. Peta error Firebase → Indonesia (salin dari CSMS `src/helper/authErrors.js`): wrong-password/invalid-credential, user-not-found, too-many-requests, network-request-failed, email-already-in-use, weak-password, invalid-email.
6. Store sesi (Zustand): `user { uid, username, name, email, role, photoURL }`, `status: loading | signedOut | needsVerification | ready`. Listener `onAuthStateChanged` + validasi ulang dokumen `users` saat aplikasi dibuka.
7. Guard Expo Router: `(app)` hanya untuk `ready`.
8. Keluar: `signOut`, hapus store & cache.

## Logika murni + unit test
`src/lib/auth.ts`: `validatePassword`, `validateUsername`, `isCustomerRole`, `authErrorMessage`.

## Kriteria selesai
- [ ] Akun seed `ops@samudra.example.com` / `Cust#2026!` bisa masuk ke emulator; akun Staff ditolak "bukan akun customer".
- [ ] Daftar akun baru menghasilkan dokumen `users` & `roles` yang benar dan email verifikasi (terlihat di Emulator UI → Authentication).
- [ ] Sesi bertahan setelah aplikasi ditutup; keluar membersihkan sesi.
- [ ] Semua pesan error berbahasa Indonesia.
