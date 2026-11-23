# BRD — Aplikasi Mobile Customer ISM CSMS

**Business Requirements Document**
Produk: ISM Customer (Android & iOS) · Pemilik: PT Indo Safety Marine · Versi dokumen: 1.0 (24 November 2026)

---

## 1. Ringkasan

PT Indo Safety Marine (ISM) melayani kalibrasi dan service alat keselamatan kapal (Gas Meter, UTI Meter, Pressure Gauge terakreditasi KAN). Seluruh proses kerja dikelola di **ISM CSMS** (Calibration Safety Management System), aplikasi web berbasis Vue + Firebase. Customer saat ini memantau order lewat **Portal Customer** di web.

Dokumen ini mendefinisikan kebutuhan bisnis untuk **aplikasi mobile khusus customer** (Android & iOS) yang:

- menampilkan progres order yang **dibuat oleh tim ISM** untuk perusahaan customer (customer **tidak** membuat order),
- memberi akses ke dokumen resmi (Penawaran, Invoice, Sertifikat) sesuai aturan pembayaran,
- mengabari customer setiap kali order bergerak ke tahap berikutnya.

Aplikasi mobile memakai **backend yang sama** dengan CSMS (Firebase project yang sama, Security Rules yang sama). Tidak ada backend baru.

## 2. Latar belakang & masalah

| Masalah saat ini | Dampak |
|---|---|
| Customer (operator kapal, superintendent) sering di lapangan / di kapal dan hanya memegang HP; portal web kurang nyaman dibuka berulang kali. | Customer menelepon / WhatsApp tim ISM untuk menanyakan status order. |
| Customer tidak tahu kapan penawaran, sertifikat, atau invoice siap. | Persetujuan penawaran & pembayaran tertunda, siklus order lebih panjang. |
| Dokumen resmi dikirim manual lewat email/WA. | Versi dokumen bisa tertukar; arsip customer tidak rapi. |
| Fitur Pesan dan Buat Order di portal sudah ditiadakan (keputusan ISM, Nov 2026). | Kanal mandiri customer kini hanya **melacak** — perlu dibuat semudah mungkin. |

## 3. Tujuan bisnis & ukuran keberhasilan

| Kode | Tujuan | KPI / target (6 bulan setelah rilis) |
|---|---|---|
| BG-1 | Mengurangi pertanyaan status order lewat telepon/WA | Turun ≥ 40% dibanding 3 bulan sebelum rilis (dicatat tim admin) |
| BG-2 | Mempercepat persetujuan penawaran oleh client | Median waktu "Rekomendasi dikirim → disetujui" turun ≥ 20% |
| BG-3 | Mempercepat pembayaran invoice | Rasio invoice lewat jatuh tempo turun ≥ 15% |
| BG-4 | Adopsi aplikasi | ≥ 60% customer aktif (akun terverifikasi) login di aplikasi mobile minimal 1× per bulan |
| BG-5 | Citra profesional | Rating store ≥ 4,5; tidak ada keluhan dokumen salah kirim |

## 4. Ruang lingkup

### 4.1 Dalam lingkup (MVP)

1. **Akun**: daftar akun (email & password), verifikasi email, masuk, lupa password, keluar.
2. **Aktivasi akun**: customer melengkapi data perusahaan → menunggu verifikasi admin ISM → akun aktif.
3. **Beranda**: ringkasan jumlah order (total, sedang diproses, selesai) + daftar order terbaru.
4. **Lacak Order**: daftar order + detail dengan **stepper 7 tahap** dan riwayat kejadian.
5. **Dokumen**: lihat, simpan, dan bagikan PDF Penawaran (selalu), Invoice & Sertifikat (setelah Lunas atau Tempo).
6. **Notifikasi**: daftar notifikasi di aplikasi (realtime), tanda belum dibaca, buka langsung ke order terkait.
7. **Profil**: lihat data akun & perusahaan, ganti nama/foto, ganti password, hapus akun (wajib store).
8. Bahasa **Indonesia**; tampilan terang (gelap opsional).

### 4.2 Di luar lingkup

- Membuat / mengubah / membatalkan order dari customer (order hanya dibuat tim ISM).
- Chat / Pesan dengan tim ISM (fitur Pesan khusus internal).
- Pembayaran online di dalam aplikasi.
- Fitur Admin Panel (Work Form, Service, Sertifikat, Invoice, Master Data, dsb.).
- Push notification **saat aplikasi ditutup** pada MVP — lihat Keputusan D-1.

## 5. Pemangku kepentingan

| Pihak | Peran | Kepentingan |
|---|---|---|
| Owner / Direktur ISM | Sponsor, pemegang akun Admin | Arus kas (pembayaran lebih cepat), citra perusahaan |
| Admin & Staff ISM | Membuat order, memverifikasi akun customer | Lebih sedikit pertanyaan status, verifikasi akun tetap terkendali |
| Engineer ISM | Mengisi Work Form & Service | Tidak ada pekerjaan tambahan |
| Customer (PIC perusahaan pelayaran) | Pengguna utama aplikasi | Tahu status order, dokumen cepat & resmi |
| Tim developer | Membangun & merawat aplikasi | Kebutuhan jelas, backend tidak berubah besar |

## 6. Persona

**Pak Hendra — Superintendent armada (pengguna utama)**
Mengelola 10–30 kapal. Sering di pelabuhan, jaringan tidak stabil. Butuh: status semua alat yang sedang dikalibrasi, sertifikat untuk inspeksi port state control, invoice untuk diteruskan ke bagian keuangan.

**Bu Sari — Staf pengadaan / keuangan customer**
Menyetujui penawaran dan membayar invoice. Butuh: notifikasi saat penawaran & invoice terbit, PDF yang bisa diteruskan ke atasan.

## 7. Kebutuhan bisnis

| Kode | Kebutuhan | Prioritas |
|---|---|---|
| BR-01 | Customer hanya bisa melihat order milik perusahaannya (dicocokkan dengan **email login yang sudah terverifikasi**). | Wajib |
| BR-02 | Customer tidak dapat membuat, mengubah, atau menghapus order. | Wajib |
| BR-03 | Akun baru harus diverifikasi admin ISM sebelum bisa melihat order (alur: daftar → verifikasi email → lengkapi data perusahaan → verifikasi admin). | Wajib |
| BR-04 | Progres order ditampilkan dalam **7 tahap** yang sama dengan Admin Panel & portal web. | Wajib |
| BR-05 | **Penawaran** dapat diunduh kapan saja oleh pemilik order. **Invoice & Sertifikat** hanya setelah invoice **Lunas**, atau bila ISM memberi status **Tempo**. | Wajib |
| BR-06 | Customer diberi tahu saat: order diterima, rekomendasi & penawaran dikirim, service selesai/menunggu PO, sertifikat siap, Delivery Order terbit. | Wajib |
| BR-07 | Data, aturan akses, dan dokumen **sama persis** dengan portal web (satu sumber kebenaran). | Wajib |
| BR-08 | Akun yang dinonaktifkan admin tidak bisa masuk. | Wajib |
| BR-09 | Aplikasi memenuhi kebijakan Google Play & App Store (hapus akun, kebijakan privasi, data safety). | Wajib |
| BR-10 | Biaya operasional tidak naik signifikan (tetap paket Firebase Spark bila memungkinkan). | Penting |
| BR-11 | Tampilan memakai identitas ISM (logo, biru #0A488F, merah #8E1028). | Penting |
| BR-12 | Aplikasi tetap bisa dibuka & menampilkan data terakhir saat jaringan buruk (baca saja). | Penting |

## 8. Aturan bisnis (berlaku di web & mobile)

1. **Order dibuat tim ISM** di Admin Panel; field `customerEmail` order = email akun portal customer.
2. **Alur kerja 7 tahap**: Order → Work Form (rekomendasi pekerjaan) → Penawaran & persetujuan client → Service & kalibrasi → Sertifikat → Invoice → Delivery Order.
3. **Sertifikat bisa dicetak tanpa PO** (ditandai "Dicetak tanpa PO").
4. **Invoice** terbit otomatis "Belum Dibayar" setelah sertifikat dibuat; Admin menandai **Lunas** atau memberi **Tempo**.
5. **Hak unduh**: Penawaran bebas; Invoice & Sertifikat terkunci sampai Lunas/Tempo (ditegakkan Firestore Security Rules, bukan hanya UI).
6. **Status akun customer** (dokumen `customers`): belum ada → *Belum lengkap*; `isRegistered` & belum `isVerify` → *Menunggu verifikasi*; `isVerify` tapi tidak `isActive` → *Nonaktif*; selain itu → *Aktif*.

## 9. Asumsi & batasan

- Backend tetap **Firebase project yang sama** dengan CSMS (Auth + Firestore). Aplikasi mobile hanya **membaca** data order/dokumen dan menulis data milik customer sendiri (profil, aktivasi, status baca notifikasi).
- Paket Firebase **Spark**: tidak ada Cloud Functions & Cloud Storage. PDF tersimpan di Firestore (dipotong per ±800 KB base64).
- Portal web customer tetap berjalan; aplikasi mobile adalah kanal tambahan, bukan pengganti.
- Perubahan pada Security Rules / Admin Panel yang dibutuhkan aplikasi mobile dikerjakan di repo `admin-indosafetymarine` (lihat PRD §12).

## 10. Risiko & mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Push notification saat aplikasi tertutup butuh server (Cloud Functions = paket Blaze). | Customer tidak dapat kabar real-time di luar aplikasi. | MVP: notifikasi realtime saat aplikasi dibuka + badge. Fase 2: upgrade Blaze & aktifkan fungsi `sendPushOnNotification` yang sudah ada (D-1). |
| Login Google di iOS mewajibkan opsi **Sign in with Apple** (App Store 4.8); email "Hide My Email" Apple tidak cocok dengan `customerEmail` order. | Customer tidak melihat order. | MVP hanya email & password (D-2). |
| Store mewajibkan **hapus akun di dalam aplikasi** (App Store 5.1.1(v), Google Play). | Aplikasi ditolak review. | Fitur Hapus Akun di Profil (D-3) + penyesuaian rules. |
| PDF besar di jaringan lambat. | Unduhan gagal / lama. | Unduh per bagian dengan progres, simpan cache lokal, tombol coba lagi. PDF sistem kini ±90–200 KB per halaman. |
| Perubahan skema data di CSMS. | Aplikasi mobile salah tampil. | Kontrak data (PRD §6) menjadi acuan; perubahan field wajib diumumkan ke tim mobile. |
| Kuota baca Firestore (Spark: 50.000 baca/hari). | Layanan terhenti sementara. | Query terbatas per email, cache lokal, listener hanya untuk notifikasi & order yang dibuka. |

## 11. Keputusan yang dibutuhkan dari ISM

| Kode | Keputusan | Rekomendasi |
|---|---|---|
| D-1 | Push notification saat aplikasi ditutup (butuh paket Blaze, biaya pemakaian kecil). | Rilis MVP tanpa push; aktifkan di Fase 2 setelah adopsi terlihat. |
| D-2 | Metode masuk: email & password saja, atau + Google (+ Apple). | Email & password saja di MVP. |
| D-3 | Hapus akun: hapus langsung (Auth) + tandai data, atau kirim permintaan ke admin. | Hapus akun login langsung; data perusahaan & order tetap disimpan ISM sebagai arsip bisnis (dijelaskan di kebijakan privasi). |
| D-4 | Pendaftaran akun dari aplikasi, atau akun hanya dibuat Admin. | Izinkan daftar mandiri (sama dengan portal web), tetap diverifikasi admin. |
| D-5 | Nama aplikasi di store & akun developer (Google Play Console, Apple Developer Program atas nama PT). | "ISM Customer" — akun developer atas nama PT Indo Safety Marine. |

## 12. Rencana rilis (ringkas)

| Tahap | Isi | Perkiraan |
|---|---|---|
| 1 | Fondasi proyek, desain sistem, koneksi Firebase | 1 minggu |
| 2 | Autentikasi | 1 minggu |
| 3 | Aktivasi akun | 0,5 minggu |
| 4 | Beranda & daftar order | 1 minggu |
| 5 | Lacak Order (7 tahap) | 1 minggu |
| 6 | Dokumen PDF | 1 minggu |
| 7 | Notifikasi | 0,5–1 minggu |
| 8 | Profil & hapus akun | 0,5 minggu |
| 9 | QA & uji di perangkat | 1 minggu |
| 10 | Rilis ke Google Play & App Store | 1–2 minggu (termasuk review store) |

Total ±9–10 minggu untuk 1 developer. Detail per tahap ada di folder `prompts/`.

## 13. Kriteria penerimaan bisnis

- Customer uji (minimal 3 perusahaan) dapat: daftar → aktivasi → melihat order → mengunduh penawaran tanpa bantuan.
- Invoice & sertifikat **tidak bisa** diunduh sebelum Lunas/Tempo, dan **langsung bisa** setelah Admin menandai Lunas.
- Data di aplikasi sama dengan portal web untuk order yang sama.
- Lolos review Google Play & App Store.
