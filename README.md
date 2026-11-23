# ISM Customer — Aplikasi Mobile (Android & iOS)

Aplikasi mobile untuk **customer PT Indo Safety Marine** memantau order kalibrasi yang dibuat tim ISM di **ISM CSMS**: progres 7 tahap, dokumen resmi (Penawaran, Invoice, Sertifikat), dan notifikasi. Customer **tidak** membuat order dan tidak ada fitur chat.

Backend memakai Firebase project CSMS yang sudah ada (Authentication + Cloud Firestore, paket Spark) dan Security Rules yang sama dengan portal web.

## Dokumen

| Dokumen | Isi |
|---|---|
| [docs/01-BRD.md](docs/01-BRD.md) | Kebutuhan bisnis: tujuan & KPI, ruang lingkup, aturan bisnis, risiko, keputusan yang dibutuhkan |
| [docs/02-PRD.md](docs/02-PRD.md) | Kebutuhan produk: arsitektur, fitur & kriteria penerimaan, kontrak data Firestore, logika 7 tahap, dokumen PDF, desain |
| [docs/03-FLOWCHART.md](docs/03-FLOWCHART.md) | Diagram alur (Mermaid): aplikasi, daftar, masuk, aktivasi, siklus order, 7 tahap, PDF, notifikasi, hapus akun, tahapan pengembangan |
| [docs/03-FLOWCHART.pdf](docs/03-FLOWCHART.pdf) | Versi PDF flowchart (11 halaman, ±64 KB) untuk dibagikan / dicetak |

## Tahapan pengembangan & prompt

Setiap tahap punya `prompt.md` siap dipakai (developer atau AI coding agent). Kerjakan berurutan; satu tahap = satu PR.

| Tahap | Prompt | Hasil |
|---|---|---|
| 1 | [prompts/01-fondasi-proyek](prompts/01-fondasi-proyek/prompt.md) | Expo + TypeScript, navigasi, desain sistem, Firebase (produksi & emulator), CI |
| 2 | [prompts/02-autentikasi](prompts/02-autentikasi/prompt.md) | Daftar, verifikasi email, masuk, lupa password, sesi |
| 3 | [prompts/03-aktivasi-akun](prompts/03-aktivasi-akun/prompt.md) | Status akun & form data perusahaan |
| 4 | [prompts/04-beranda-daftar-order](prompts/04-beranda-daftar-order/prompt.md) | Beranda, ringkasan, order terbaru, offline cache |
| 5 | [prompts/05-lacak-order](prompts/05-lacak-order/prompt.md) | Daftar order & detail stepper 7 tahap + riwayat |
| 6 | [prompts/06-dokumen-pdf](prompts/06-dokumen-pdf/prompt.md) | Buka/simpan/bagikan PDF sesuai aturan pembayaran |
| 7 | [prompts/07-notifikasi](prompts/07-notifikasi/prompt.md) | Notifikasi in-app realtime, status baca, persiapan push |
| 8 | [prompts/08-profil-akun](prompts/08-profil-akun/prompt.md) | Profil, foto, ganti password, hapus akun |
| 9 | [prompts/09-quality-assurance](prompts/09-quality-assurance/prompt.md) | Unit, integrasi emulator, E2E Maestro, checklist perangkat |
| 10 | [prompts/10-rilis-store](prompts/10-rilis-store/prompt.md) | Build EAS, materi store, privasi, rilis bertahap |

**Cara memakai prompt:** buka prompt tahap yang dikerjakan, tempelkan ke agent/assistant di root repo ini (setelah Tahap 1 berisi kode), minta agent membaca `docs/` lebih dulu, lalu review hasil terhadap bagian **Kriteria selesai**.

## Keputusan yang masih terbuka

Lihat BRD §11: push notification (paket Blaze), metode masuk (Google/Apple), mekanisme hapus akun, pendaftaran mandiri, nama & akun developer store.

## Repo terkait

- **admin-indosafetymarine** — ISM CSMS (Admin Panel + portal web customer), sumber Security Rules, helper `orderTracking.js`, dan seed Firebase Emulator (`qa/automation`).
