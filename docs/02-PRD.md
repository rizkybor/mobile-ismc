# PRD — Aplikasi Mobile Customer ISM CSMS

**Product Requirements Document** · Versi 1.0 (24 November 2026)
Acuan bisnis: [01-BRD.md](01-BRD.md) · Alur: [03-FLOWCHART.md](03-FLOWCHART.md)

---

## 1. Ringkasan produk

| Item | Nilai |
|---|---|
| Nama kerja | ISM Customer |
| Platform | Android 8.0+ (API 26) dan iOS 15+ — satu codebase |
| Bahasa UI | Bahasa Indonesia |
| Pengguna | Customer ISM (role `customer`) dengan email terverifikasi |
| Backend | Firebase project CSMS yang sudah ada: Authentication + Cloud Firestore (paket Spark) |
| Sifat data | Baca saja untuk order & dokumen; tulis hanya data milik customer sendiri |

## 2. Arsitektur & teknologi

| Lapisan | Pilihan | Alasan |
|---|---|---|
| Framework | **Expo (React Native) + TypeScript**, Expo Router | Satu codebase Android & iOS; tim sudah memakai JavaScript; build cloud lewat EAS tanpa Mac fisik untuk Android |
| Firebase | **Firebase JS SDK v10+ (modular)** — `firebase/auth`, `firebase/firestore` | Sama dengan web CSMS; berjalan di Expo tanpa modul native |
| Sesi login | `initializeAuth` + `getReactNativePersistence(AsyncStorage)` | Sesi tetap setelah aplikasi ditutup |
| Cache offline | Persistensi Firestore (memory) + cache ringkas di AsyncStorage | Data terakhir tetap tampil saat sinyal buruk |
| State | Zustand (sesi, status akun) + hook per layar | Ringan |
| Form | React Hook Form + Zod | Validasi konsisten |
| PDF | `expo-file-system` (tulis file), `expo-sharing` (bagikan/buka), `react-native-pdf` atau WebView untuk pratinjau | PDF dirakit dari potongan base64 di Firestore |
| Notifikasi | Listener Firestore (in-app) + `expo-notifications` (Fase 2: push FCM/APNs) | Spark tidak punya Cloud Functions |
| UI | Komponen sendiri + `react-native-safe-area-context`, ikon Material Design (`@expo/vector-icons/MaterialCommunityIcons`) | Ikon sama dengan web (mdi-*) |
| Kualitas | ESLint, Prettier, Jest + React Native Testing Library, Maestro (E2E) | |
| Build & rilis | EAS Build & EAS Submit; versi OTA lewat EAS Update | |

Konfigurasi Firebase dibaca dari variabel `EXPO_PUBLIC_FIREBASE_*` (file `.env`, **tidak di-commit**). Mode pengembangan dapat diarahkan ke **Firebase Emulator** (`EXPO_PUBLIC_USE_EMULATOR=1`).

## 3. Struktur navigasi

```
(auth)                       (app) — butuh login + email terverifikasi
 ├─ welcome                   ├─ tabs
 ├─ login                     │   ├─ beranda        (Home)
 ├─ register                  │   ├─ lacak          (daftar order → detail)
 ├─ verify-email              │   ├─ notifikasi     (badge belum dibaca)
 └─ forgot-password           │   └─ profil
                              ├─ order/[orderId]    (detail + stepper + dokumen)
                              ├─ aktivasi           (lengkapi data perusahaan)
                              └─ pdf-viewer
```

Gerbang (guard) urutan: belum login → `(auth)`; login tapi email belum terverifikasi → `verify-email`; role bukan customer / akun nonaktif → keluar + pesan; status akun ≠ Aktif → Beranda menampilkan kartu aktivasi (tab Lacak disembunyikan).

## 4. Fitur & kriteria penerimaan

### F-01 Autentikasi
| ID | User story | Kriteria penerimaan |
|---|---|---|
| F-01.1 | Sebagai customer, saya bisa **mendaftar** dengan nama, username, email, password. | Username unik (cek `users/{username}` → ditolak/ada = dipakai); password ≥ 8 karakter, huruf besar & kecil, angka, simbol `!@#$%^&*`; setelah daftar: dokumen `users/{username}` (`role: "customer"`, `createdBy: "Customer"`), dokumen `roles/{uid}` (`role: "customer"`), email verifikasi terkirim, lalu keluar otomatis dan diarahkan ke layar "Cek email Anda". |
| F-01.2 | Saya bisa **masuk** dengan email & password. | Email belum diverifikasi → layar verifikasi + tombol "Kirim ulang"; tidak ada dokumen `users` → "Akun belum terdaftar"; role bukan customer → "Akun ini tidak terdaftar sebagai customer"; `isActive === false` → "Akun Anda dinonaktifkan. Hubungi admin."; pastikan `roles/{uid}` ada (buat bila belum). |
| F-01.3 | Saya bisa **mengatur ulang password**. | `sendPasswordResetEmail`; pesan selalu netral ("Bila email terdaftar, tautan dikirim") agar email tidak bisa ditebak. |
| F-01.4 | Saya tetap login setelah aplikasi ditutup, dan bisa **keluar**. | Persistensi AsyncStorage; keluar menghapus cache lokal & listener. |
| F-01.5 | Pesan error mudah dipahami. | Peta kode Firebase → teks Indonesia (salin dari `src/helper/authErrors.js` repo CSMS). |

### F-02 Aktivasi akun
| ID | User story | Kriteria penerimaan |
|---|---|---|
| F-02.1 | Saya melihat **status akun** saya. | Baca `customers where email == <email login>` (ambil yang `isDeleted == false`, terbaru). Status: tidak ada → **Belum lengkap**; `isRegistered && !isVerify && !isActive` → **Menunggu verifikasi**; `isRegistered && isVerify && !isActive` → **Nonaktif**; lainnya → **Aktif**. |
| F-02.2 | Saya bisa **melengkapi data perusahaan**. | Pilih Perusahaan/Perorangan; Perusahaan: nama perusahaan wajib; No. HP wajib (angka); telepon kantor opsional; alamat wajib. Tolak bila email sudah punya data customer. Simpan ke `customers` dengan `isActive:false, isVerify:false, isRegistered:true, isDeleted:false, createdBy:"Self"`. Kirim notifikasi ke tim (`audience:"panel", type:"account", title:"Customer baru menunggu verifikasi"`). |
| F-02.3 | Saya tahu langkah berikutnya. | Stepper 3 langkah: Daftar akun ✓ → Lengkapi data perusahaan → Verifikasi admin ("Biasanya 1×24 jam kerja"). Tarik-untuk-segarkan memeriksa ulang status. |

### F-03 Beranda
| ID | User story | Kriteria penerimaan |
|---|---|---|
| F-03.1 | Saya melihat ringkasan order. | Kartu: **Total order**, **Sedang diproses** (total − selesai − ditolak), **Selesai** — pengelompokan status di §7. |
| F-03.2 | Saya melihat order terbaru. | 5 order terbaru (No. order, tanggal, vessel, produk, chip status, mini-progress 7 segmen). Tap → detail order. Kosong: "Order yang dibuat tim Indo Safety Marine untuk perusahaan Anda akan muncul di sini." |
| F-03.3 | Data selalu terbaru. | Tarik-untuk-segarkan; muat ulang saat aplikasi kembali aktif (> 5 menit). |

### F-04 Lacak Order
| ID | User story | Kriteria penerimaan |
|---|---|---|
| F-04.1 | Saya melihat **semua order** saya. | Query `orders where isDeleted == false && customerEmail == <email>`; urut `createdAt` terbaru; cari (No. order, vessel, status, produk); filter **Berjalan / Selesai** (selesai = semua 7 tahap selesai). |
| F-04.2 | Saya melihat **posisi order** di 7 tahap. | Stepper vertikal; status tiap tahap: selesai (hijau ✓), sedang berjalan (biru), tertunda (kuning ‖), ditolak (merah ✕), menunggu (abu). Catatan per tahap (No. penawaran, PO / "Dicetak tanpa PO", No. invoice · Lunas/Tempo/Belum Dibayar, No. DO). Logika lengkap §8. |
| F-04.3 | Saya melihat **riwayat** order. | Dari `statusHistory` (terbaru di atas, tanggal & jam WIB); order lama tanpa riwayat: disusun dari data dokumen + catatan "Riwayat disusun dari data yang tersedia". Label §8.3. |
| F-04.4 | Saya melihat **daftar alat** dalam order. | Per item `productsList`: produk, merk (`orderProductType`), tipe (`orderProductSeries`), S/N (`orderProductSN`). |
| F-04.5 | Saya bisa **membagikan** ringkasan order. | Share teks: No. order, vessel, tahap saat ini. |

### F-05 Dokumen PDF
| ID | User story | Kriteria penerimaan |
|---|---|---|
| F-05.1 | Saya melihat dokumen yang tersedia di order. | Daftar dari §9: Penawaran, Invoice, Sertifikat Gas/UTI/KAN. Terkunci → ikon gembok + teks "Bisa diunduh setelah pembayaran dikonfirmasi". Chip pembayaran: Lunas (hijau) / Tempo (biru) / Belum Dibayar (kuning). |
| F-05.2 | Saya bisa **membuka** PDF. | Ambil potongan → rakit → simpan di cache → pratinjau di aplikasi. Progres unduh ditampilkan. Gagal / tidak lengkap → pesan + "Coba lagi". |
| F-05.3 | Saya bisa **menyimpan / membagikan** PDF. | Tombol Bagikan (share sheet OS) dengan nama file asli. |
| F-05.4 | Dokumen yang sudah diunduh bisa dibuka tanpa sinyal. | Cache per `docId`; dibersihkan saat keluar akun. |

### F-06 Notifikasi
| ID | User story | Kriteria penerimaan |
|---|---|---|
| F-06.1 | Saya melihat daftar notifikasi. | Listener `notifications where customerEmail == <email>` (tanpa `orderBy` — urutkan di aplikasi berdasarkan `createdAt`); tampil judul, isi, waktu relatif. |
| F-06.2 | Saya tahu mana yang belum dibaca. | Belum dibaca = `uid` login tidak ada di `readBy`; badge di tab; "Tandai semua dibaca" → `arrayUnion(uid)` ke `readBy` (hanya field ini yang boleh diubah). |
| F-06.3 | Notifikasi membawa saya ke order terkait. | `orderId` ada → buka detail order. |
| F-06.4 | (Fase 2) Push saat aplikasi ditutup. | Token Expo/FCM disimpan di `pushTokens/{token}` (`uid, email, role:"customer", panel:false`); fungsi `sendPushOnNotification` (repo CSMS, folder `functions/`) diperluas untuk token mobile. Butuh paket Blaze. |

### F-07 Profil & akun
| ID | User story | Kriteria penerimaan |
|---|---|---|
| F-07.1 | Saya melihat data akun & perusahaan. | Nama, username, email (tidak bisa diubah), data perusahaan (nama, HP, telepon, alamat) baca saja. Perubahan data perusahaan → "Hubungi admin ISM". |
| F-07.2 | Saya bisa mengganti **foto profil**. | Kamera/galeri, potong persegi 256 px, JPEG 0,85 → `users/{username}.photoURL` (data URL). Customer **tidak** boleh mengubah nama (rules). |
| F-07.3 | Saya bisa **ganti password**. | Re-autentikasi dengan password lama, lalu `updatePassword` (syarat sama dengan daftar). |
| F-07.4 | Saya bisa **menghapus akun** (wajib store). | Konfirmasi ketik "HAPUS" + password → re-autentikasi → tandai permintaan hapus (lihat §12 butir 2) → `user.delete()` → keluar. Teks menjelaskan: data order & dokumen tetap disimpan ISM sebagai arsip bisnis. |
| F-07.5 | Saya bisa membaca kebijakan privasi & versi aplikasi. | Tautan kebijakan privasi (URL publik), versi & nomor build. |

## 5. Persyaratan non-fungsional

| Kode | Kebutuhan |
|---|---|
| NF-1 Kinerja | Cold start < 3 dtk di perangkat menengah; daftar order tampil < 2 dtk di 4G; daftar memakai FlatList virtualisasi. |
| NF-2 Offline | Data terakhir (order, notifikasi, dokumen yang pernah diunduh) tetap tampil; banner "Offline". Tidak ada penulisan saat offline kecuali status baca notifikasi (antre). |
| NF-3 Keamanan | Semua akses data ditegakkan **Firestore Security Rules** CSMS; aplikasi tidak menyimpan password; `.env` tidak di-commit; tidak ada log data pribadi di produksi. |
| NF-4 Privasi | Kebijakan privasi & Data Safety (Play) / Privacy Nutrition Label (App Store): email, nama, nomor telepon, foto (opsional); tujuan: fungsi aplikasi; tidak dijual/dibagikan. |
| NF-5 Aksesibilitas | Target sentuh ≥ 44×44 pt, kontras teks ≥ 4.5:1, label aksesibilitas pada ikon, mendukung ukuran huruf sistem. |
| NF-6 Kuota | Rata-rata ≤ 60 baca dokumen per sesi; listener hanya untuk notifikasi & status akun; order dimuat ulang manual/periodik. |
| NF-7 Zona waktu | Tanggal ditampilkan WIB (`Asia/Jakarta`), format `22 Nov 2026, 14.30 WIB`. |
| NF-8 Kualitas | Lint bersih, unit test untuk logika (status akun, 7 tahap, hak unduh, rakit PDF), E2E Maestro untuk alur utama, dijalankan ke Firebase Emulator. |

## 6. Kontrak data (Firestore, dibaca/ditulis aplikasi)

> Sumber kebenaran: repo `admin-indosafetymarine` (`firestore.rules`, `src/helper/*`). Query **harus** sama persis bentuknya agar lolos rules.

| Koleksi | Operasi customer | Field yang dipakai |
|---|---|---|
| `users/{username}` | create (daftar), read (milik sendiri), update `photoURL, updatedAt, updatedBy` | `userId, username, name, email, role ("customer"), isActive, photoURL, createdAt, createdBy` |
| `roles/{uid}` | create bila belum ada, read milik sendiri | `role: "customer", email, username: "", active: true, updatedAt` |
| `customers` | read `where email == <email terverifikasi>`; create (aktivasi) | `customerName, statusCustomer (true = perusahaan), address, email, phone, telp, isActive, isVerify, isRegistered, isDeleted, createdAt, createdBy` |
| `orders` | read `where isDeleted == false && customerEmail == <email>` | lihat tabel di bawah |
| `orders/{id}/documents/{docId}` (+ `/chunks/{n}`) | read bila `customerMayDownload` | `type, title, fileName, size, chunks, createdAt, revision`; chunk: `{ n, data (base64) }` |
| `invoices/{id}` (+ `/documents/...`) | read bila `customerInvoice` (Lunas/Tempo) | `no, status ("unpaid"/"paid"), tempo, totals.total, currency, dueDate` |
| `notifications` | read `where customerEmail == <email>`; update hanya `readBy` (tambah uid sendiri); create untuk diri sendiri / "Customer baru menunggu verifikasi" | `audience, type, title, body, orderId, ordersNo, link, readBy[], customerEmail, createdAt, createdByUid` |
| `pushTokens/{token}` (Fase 2) | create/update milik sendiri, delete | `uid, email, role: "customer", panel: false, platform, updatedAt` |

**Field order yang dipakai aplikasi:**

| Field | Arti |
|---|---|
| `ordersNo` | Nomor order, mis. `OR/20261121/006` |
| `createdAt` | ISO datetime order dibuat |
| `customerName, customerEmail, vesselName, products` | Identitas order (`products` = daftar produk dipisah koma) |
| `productsList[]` | Alat: `orderProduct, orderProductType, orderProductSeries, orderProductSN` |
| `statusDesc` | Status proses (lihat §7) |
| `statusHistory[]` | `{ status, note, at, by }` |
| `quotationNo` | Nomor penawaran |
| `poNumber` | Nomor PO client ("" = belum) |
| `pdfFiles.{type}` | Penanda PDF: `{ docId, fileName, revision, createdAt }`, `type ∈ quotation, certificateGas, certificateUti, certificateKan, inspectionReport, deliveryOrder` |
| `invoiceId, invoiceNo, invoiceDate, invoiceTotal, invoiceStatus ("Belum Dibayar"/"Lunas"), invoiceTempo, invoicePdf { docId, fileName }` | Cermin invoice |
| `deliveryOrderNumber` | Nomor DO |

## 7. Status order & pengelompokan Beranda

| Kelompok | `statusDesc` |
|---|---|
| Draft | `Entry`, `-` |
| Dalam proses | `Waiting for Inspection process`, `Progress for Inspection`, `Inspection is Pending`, `Inspection is Completed`, `Waiting for Certificate process`, `PO not finished yet` (status tak dikenal → kelompok ini) |
| Menunggu persetujuan client | `Waiting for Client to approve Inspection`, `Waiting for Approval Client`, `Waiting for PO Client` |
| Selesai | `Final Order`, `Done` |
| Ditolak | `Rejected`, `Inspection Rejected`, `Reject` |

Label tampilan dipendekkan: `Waiting for Client to approve Inspection` → "Waiting for Approval"; `Waiting for Certificate process` → "Waiting for Certificate".

## 8. Logika Lacak Order 7 tahap

Port langsung dari `src/helper/orderTracking.js` (repo CSMS). Tahap & kunci:

| # | Kunci | Label | Selesai bila |
|---|---|---|---|
| 0 | `order` | Order diterima | selalu |
| 1 | `workform` | Rekomendasi pekerjaan | status ∈ menunggu client, `Inspection Rejected`, atau tahap 2 selesai |
| 2 | `quotation` | Penawaran & persetujuan | status ∈ `Inspection is Completed`, `Inspection is Pending`, atau tahap 3 selesai |
| 3 | `service` | Service & kalibrasi | status ∈ `Final Order`, `PO not finished yet`, `Waiting for Certificate process`, `Done`, `Rejected`, **atau** ada PDF sertifikat |
| 4 | `certificate` | Sertifikat | ada `pdfFiles.certificateGas/Uti/Kan` |
| 5 | `invoice` | Invoice | `invoiceStatus == "Lunas"` atau `invoiceTempo` |
| 6 | `delivery` | Delivery Order | `deliveryOrderNumber` terisi |

### 8.1 Status tahap
- Tahap pertama yang belum selesai = **sedang berjalan**; setelahnya **menunggu**.
- Tahap 2: `Inspection Rejected` → **ditolak**; `Inspection is Pending` → **tertunda**.
- Tahap 4: `Rejected` → **ditolak**; belum ada sertifikat & `PO not finished yet` → **tertunda**.
- Tahap 5: Tempo → **tertunda** ("Tempo"); invoice sudah terbit tapi belum dibayar → **tertunda** ("Menunggu pembayaran").
- Order **selesai** bila ketujuh tahap selesai (Tempo belum dihitung selesai).

### 8.2 Catatan per tahap
Rekomendasi: "Work Form sedang diisi" (status `Entry`) · Penawaran: "Penawaran <quotationNo>" · Service: "Service selesai, menunggu PO" · Sertifikat: "Dicetak tanpa PO" / "PO <poNumber>" · Invoice: "<invoiceNo> · Lunas/Tempo/Belum Dibayar" atau "Invoice belum terbit" · DO: nomor DO.

### 8.3 Label riwayat (`statusHistory.status` → teks)
`Waiting for Inspection process` Order dibuat · `Entry` Work Form mulai diisi · `Waiting for Client to approve Inspection` Rekomendasi pekerjaan dikirim ke client · `Inspection is Completed` Client menyetujui rekomendasi pekerjaan · `Inspection is Pending` Rekomendasi pekerjaan ditandai pending · `Inspection Rejected` Client menolak rekomendasi pekerjaan · `PO not finished yet` Service selesai, menunggu PO · `Final Order` Service selesai, masuk tahap sertifikat (catatan "PO dikonfirmasi" → "PO dikonfirmasi, sertifikat siap diterbitkan") · `Quotation` Penawaran dibuat · `PO Number` Nomor PO dicatat · `Certificate` Sertifikat diterbitkan · `Invoice` Invoice diterbitkan · `Invoice Paid` Pembayaran invoice lunas · `Delivery Order` Delivery Order diterbitkan · `Reverted` Proses dimundurkan untuk revisi. Status lain ditampilkan apa adanya.

Tanggal tahap: tahap selesai memakai kejadian pertama yang menandainya; tahap berjalan memakai waktu selesai tahap sebelumnya.

## 9. Dokumen untuk customer

| Dokumen | Sumber | Bisa dibuka bila |
|---|---|---|
| Penawaran (Quotation) | `orders/{id}/documents/{pdfFiles.quotation.docId}` | selalu (pemilik order) |
| Invoice | `invoices/{invoiceId}/documents/{invoicePdf.docId}` | invoice `paid` atau `tempo` |
| Sertifikat Gas / UTI / KAN | `orders/{id}/documents/{pdfFiles.certificate*.docId}` | `invoiceStatus == "Lunas"` atau `invoiceTempo == true` |

**Merakit PDF:** baca dokumen arsip → `chunks` (jumlah potongan) → query `chunks` `orderBy("n")` → pastikan jumlah = `chunks` (bila tidak: error "incomplete") → gabungkan `data` → tulis base64 ke `FileSystem.cacheDirectory/<docId>.pdf`. Arsip lama berformat Cloud Storage (`path` tanpa `chunks`) → tampilkan "Dokumen lama, buka lewat portal web".

## 10. Desain

- Warna: primer `#0A488F`, primer gelap `#083567`, primer muda `#E6EEF8`, navy `#0B1E3A`, aksen merah `#8E1028`, sukses `#1E9E6A`, peringatan `#D98E04`, error `#B3122E`.
- Huruf: Inter (atau sistem); ukuran dasar 15–16 pt.
- Logo: `logo-ism.png` dari repo CSMS (`src/assets/images`).
- Ikon: Material Design Icons (nama sama dengan web, mis. `certificate-outline`, `receipt`, `truck-delivery-outline`).
- Tab bawah: Beranda, Lacak, Notifikasi (badge), Profil.
- Status chip & stepper mengikuti warna di atas; mode gelap opsional (token warna terpusat).

## 11. Analitik & pemantauan (opsional)

Firebase Analytics (event: `login`, `view_order`, `open_document`, `share_document`) dan Crashlytics/Sentry — butuh persetujuan di kebijakan privasi.

## 12. Ketergantungan pada repo CSMS (`admin-indosafetymarine`)

1. **Rules `pushTokens`** (Fase 2) — izinkan `platform` dan token Expo; perluas `functions/push.js` untuk token mobile.
2. **Hapus akun**: rules saat ini tidak mengizinkan customer menghapus `users`/`roles` miliknya. Tambahkan salah satu:
   a. izinkan customer meng-update `users/{username}` dengan `deletionRequestedAt` (lalu Admin menghapus dari User Management), **atau**
   b. izinkan customer menghapus `users/{username}` & `roles/{uid}` miliknya.
   Rekomendasi: (a) + `user.delete()` di Auth; data perusahaan & order tetap sebagai arsip.
3. Tidak ada perubahan pada data order/dokumen — aplikasi mobile hanya membaca.

## 13. Di luar lingkup

Membuat/mengubah order, Pesan/chat, pembayaran online, fitur Admin Panel, multi-bahasa (EN menyusul), tablet layout khusus.
