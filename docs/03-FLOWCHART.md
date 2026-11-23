# Flowchart — Aplikasi Mobile Customer ISM CSMS

Diagram ditulis dalam Mermaid (tampil otomatis di GitHub). Acuan: [01-BRD.md](01-BRD.md), [02-PRD.md](02-PRD.md).

## 1. Alur besar aplikasi

```mermaid
flowchart TD
    A([Buka aplikasi]) --> B{Sesi login tersimpan?}
    B -- Tidak --> W[Welcome] --> L[Masuk]
    W --> R[Daftar akun]
    B -- Ya --> V{Email terverifikasi?}
    L --> V
    V -- Tidak --> VE[Layar verifikasi email<br/>Kirim ulang · Saya sudah verifikasi]
    VE --> V
    V -- Ya --> U{Dokumen users ada,<br/>role customer, isActive?}
    U -- Tidak --> X[Keluar + pesan error] --> L
    U -- Ya --> S{Status akun<br/>koleksi customers}
    S -- Belum lengkap --> AK[Form aktivasi<br/>data perusahaan]
    S -- Menunggu verifikasi --> WT[Kartu: menunggu admin ISM]
    S -- Nonaktif --> NA[Kartu: akun nonaktif,<br/>hubungi admin]
    S -- Aktif --> HOME[Beranda]
    AK --> WT
    HOME --> TR[Lacak Order] --> DT[Detail order<br/>7 tahap + riwayat + dokumen]
    HOME --> NO[Notifikasi] --> DT
    HOME --> PR[Profil]
```

## 2. Daftar akun & verifikasi email

```mermaid
flowchart TD
    A[Isi nama, username, email, password] --> B{Validasi form}
    B -- Gagal --> A
    B -- OK --> C{users/username sudah ada?<br/>get: ada atau permission-denied}
    C -- Ya --> E1[Username sudah dipakai] --> A
    C -- Tidak --> D[createUserWithEmailAndPassword]
    D -- email-already-in-use --> E2[Email sudah terdaftar] --> A
    D -- OK --> F[set users/username<br/>role customer, createdBy Customer]
    F --> G[set roles/uid bila belum ada]
    G --> H[sendEmailVerification]
    H --> I[signOut]
    I --> J[Layar: cek email Anda]
    J --> K[Customer klik tautan di email] --> L[Masuk]
```

## 3. Masuk (login)

```mermaid
flowchart TD
    A[Email + password] --> B[signInWithEmailAndPassword]
    B -- Gagal --> E[Pesan error Indonesia] --> A
    B -- OK --> C{emailVerified?}
    C -- Tidak --> V[Layar verifikasi<br/>Kirim ulang email] 
    C -- Ya --> D[Query users where userId == uid]
    D --> F{Ada?}
    F -- Tidak --> X1[Akun belum terdaftar] --> SO[signOut]
    F -- Ya --> G{role customer?}
    G -- Tidak --> X2[Bukan akun customer] --> SO
    G -- Ya --> H{isActive != false?}
    H -- Tidak --> X3[Akun dinonaktifkan] --> SO
    H -- Ya --> I[Pastikan roles/uid ada] --> J[Simpan sesi] --> K[Cek status akun]
```

## 4. Aktivasi akun

```mermaid
flowchart TD
    A[Query customers where email == email login] --> B{Ada data<br/>isDeleted false?}
    B -- Tidak --> C[Status: Belum lengkap]
    C --> D[Form: Perusahaan/Perorangan,<br/>nama perusahaan, No. HP, telepon, alamat]
    D --> E{Email sudah punya data customer?}
    E -- Ya --> E1[Hubungi admin] 
    E -- Tidak --> F[add customers<br/>isRegistered true, isVerify false, isActive false]
    F --> G[Notifikasi ke tim:<br/>Customer baru menunggu verifikasi]
    G --> H[Status: Menunggu verifikasi]
    B -- Ya --> I{"isRegistered && !isVerify && !isActive"}
    I -- Ya --> H
    I -- Tidak --> J{"isRegistered && isVerify && !isActive"}
    J -- Ya --> K[Status: Nonaktif]
    J -- Tidak --> L[Status: Aktif → Beranda & Lacak]
    H -. Admin ISM memverifikasi di Admin Panel .-> L
```

## 5. Siklus order (dikerjakan tim ISM, dilihat customer)

```mermaid
flowchart LR
    O[1 Order diterima] --> W[2 Rekomendasi pekerjaan<br/>Work Form]
    W --> Q[3 Penawaran & persetujuan client]
    Q -- Disetujui --> S[4 Service & kalibrasi]
    Q -- Pending --> QP[Tertunda]
    Q -- Ditolak --> QR[Ditolak]
    S --> C[5 Sertifikat<br/>boleh tanpa PO]
    S -- PO belum ada --> SP[Tertunda: menunggu PO]
    C --> I[6 Invoice<br/>terbit otomatis: Belum Dibayar]
    I -- Lunas --> D[7 Delivery Order]
    I -- Tempo --> IT[Tertunda: Tempo] --> D
    D --> F([Selesai])
```

## 6. Penentuan status 7 tahap (logika aplikasi)

```mermaid
flowchart TD
    A[Data order] --> B[done = flag tiap tahap<br/>lihat PRD §8]
    B --> C[cur = tahap pertama yang belum done]
    C --> D{Untuk tiap tahap i}
    D --> E{done i?}
    E -- Ya --> F[selesai]
    E -- Tidak --> G{i == cur?}
    G -- Ya --> H[sedang berjalan]
    G -- Tidak --> I[menunggu]
    F & H & I --> J{Aturan khusus}
    J -- tahap 2 + Inspection Rejected --> K[ditolak]
    J -- tahap 2 + Inspection is Pending --> L[tertunda]
    J -- tahap 4 + Rejected --> K
    J -- tahap 4 belum + PO not finished yet --> L
    J -- tahap 5 + Tempo --> L
    J -- tahap 5 berjalan + invoice terbit --> L
```

## 7. Membuka dokumen PDF

```mermaid
flowchart TD
    A[Tap dokumen] --> B{Jenis}
    B -- Penawaran --> OK[Boleh]
    B -- Invoice / Sertifikat --> C{invoiceStatus Lunas<br/>atau invoiceTempo?}
    C -- Tidak --> LK[Terkunci:<br/>bisa diunduh setelah pembayaran dikonfirmasi]
    C -- Ya --> OK
    OK --> D{Ada di cache lokal?}
    D -- Ya --> V[Pratinjau PDF]
    D -- Tidak --> E[get dokumen arsip<br/>docId dari pdfFiles / invoicePdf]
    E --> F{punya chunks?}
    F -- Tidak, format lama --> OLD[Buka lewat portal web]
    F -- Ya --> G[query chunks orderBy n]
    G --> H{jumlah == chunks?}
    H -- Tidak --> ER[Error tidak lengkap · Coba lagi]
    H -- Ya --> I[Gabung base64 → tulis file cache] --> V
    V --> S[Bagikan / Simpan]
```

## 8. Notifikasi

```mermaid
flowchart TD
    A[Login aktif] --> B[Listener notifications<br/>where customerEmail == email]
    B --> C[Urutkan createdAt terbaru di aplikasi]
    C --> D[Hitung belum dibaca:<br/>uid tidak ada di readBy]
    D --> E[Badge tab Notifikasi]
    E --> F[Tap notifikasi] --> G[update readBy arrayUnion uid]
    G --> H{orderId ada?}
    H -- Ya --> I[Detail order]
    H -- Tidak --> J[Tetap di daftar]
    K[Fase 2: Admin Panel membuat notifikasi] -.-> L[Cloud Function sendPushOnNotification] -.-> M[Push FCM/APNs ke token mobile]
```

## 9. Hapus akun (wajib store)

```mermaid
flowchart TD
    A[Profil → Hapus akun] --> B[Penjelasan: data order & dokumen<br/>tetap disimpan ISM]
    B --> C[Ketik HAPUS + password]
    C --> D[reauthenticateWithCredential]
    D -- Gagal --> E[Password salah] --> C
    D -- OK --> F[Tandai users: deletionRequestedAt<br/>butuh perubahan rules CSMS]
    F --> G[user.delete di Firebase Auth]
    G --> H[Hapus cache & sesi] --> I[Layar Welcome]
```

## 10. Alur pengembangan & rilis

```mermaid
flowchart LR
    T1[1 Fondasi] --> T2[2 Autentikasi] --> T3[3 Aktivasi] --> T4[4 Beranda]
    T4 --> T5[5 Lacak Order] --> T6[6 Dokumen PDF] --> T7[7 Notifikasi]
    T7 --> T8[8 Profil & hapus akun] --> T9[9 QA] --> T10[10 Rilis store]
    T9 -. bug .-> T4
```
