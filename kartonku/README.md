# 📦 KartonKu

Aplikasi manajemen inventaris untuk usaha rumahan reseller tissue Laras — melacak stok karton dan pack tanpa spreadsheet manual.

## Latar Belakang

Sebagai seller tissue merk Laras yang menerima stok dalam bentuk karton, pendataan jumlah tissue dan karton yang tersedia sering jadi tantangan tersendiri untuk usaha rumahan. KartonKu dibangun untuk menyederhanakan proses ini: satu sumber kebenaran untuk stok, status stok yang jelas di sekilas pandang, dan riwayat transaksi yang bisa dilacak.

## Status Proyek

> Proyek dalam tahap pengembangan aktif. Bagian di bawah membedakan fitur yang **sudah berjalan** dan yang **masih direncanakan**, supaya README ini tetap akurat seiring progres.

### ✅ Sudah diimplementasikan
- Autentikasi login (Supabase Auth, email/password, single-user admin)
- Skema database inti: `products`, `stock_transactions`, view `product_stock`
- UI Dashboard (statis dengan data mock): ringkasan status Aman/Tipis/Habis, daftar produk dengan kartu stok

### 🚧 Dalam pengembangan
- Wiring Dashboard ke data real-time dari Supabase (saat ini masih pakai mock data)
- Tombol tambah/kurang stok → insert ke `stock_transactions`
- Upload & tampilkan foto produk (Supabase Storage)

### 📋 Direncanakan
- Scan karton dengan OCR untuk baca kode label & isi per karton otomatis
- Fitur tambah jenis tissue baru (manual & dibantu OCR)
- Riwayat pergerakan stok (halaman History)
- Halaman Settings
- Reset password
- Web dashboard untuk monitoring (fase lanjutan, di luar scope mobile app ini)

## Fitur Utama (Visi Produk)

- **Manajemen Inventaris** — lihat jumlah stok per jenis tissue dalam satuan karton & pack, update stok dengan cepat
- **Status Stok Otomatis** — badge Aman/Menipis/Habis dihitung dari threshold per produk, bukan angka statis
- **Tambah Jenis Tissue** — input manual atau dibantu OCR untuk baca kode label dari kemasan
- **Riwayat Transaksi** — setiap perubahan stok tercatat sebagai transaksi (bukan overwrite angka), sehingga stok yang tampil selalu bisa ditelusuri asalnya

## Tech Stack

| Layer | Teknologi |
|---|---|
| Frontend | Flutter (Dart) |
| Backend / Database | Supabase (PostgreSQL) |
| Auth | Supabase Auth |
| Storage (rencana) | Supabase Storage |

## Struktur Database

Stok **tidak disimpan sebagai angka tunggal**, melainkan dihitung dari akumulasi transaksi — ini mencegah data stok menyimpang dari riwayat aktualnya.

```
products
├── id (uuid, PK)
├── name (text)
├── label_code (text, unik)
├── packs_per_carton (int)      -- konversi: 1 karton = berapa pack
├── low_stock_threshold_ctn (int)
└── created_at (timestamptz)

stock_transactions
├── id (uuid, PK)
├── product_id (uuid, FK → products.id)
├── change_qty (int)             -- satuan pack; positif = masuk, negatif = keluar
├── reason (text)                -- 'restock' | 'sold' | 'adjustment'
└── created_at (timestamptz)

product_stock (view)
└── products + SUM(change_qty) per produk, dihitung on-the-fly
```

## Struktur Proyek

```
lib/
├── main.dart
├── config/
│   └── supabase_config.dart
├── features/
│   ├── auth/
│   │   └── login_page.dart
│   ├── dashboard/
│   │   ├── dashboard_page.dart
│   │   └── widgets/
│   │       └── stat_card.dart
│   └── inventory/
│       ├── models/
│       │   └── product.dart
│       └── widgets/
│           └── product_list_item.dart
└── shared/
    └── theme/
        └── app_colors.dart
```
Diorganisir **by-feature** (bukan by-type) — setiap folder fitur mengelompokkan semua file terkaitnya sendiri, memudahkan navigasi seiring bertambahnya modul (auth, inventory, dashboard, dan seterusnya).

## Setup Lokal

### Prasyarat
- Flutter SDK (channel stable)
- Akun & project Supabase

### Instalasi
```bash
git clone https://github.com/KartonKu/kartonku.git
cd kartonku
flutter pub get
```

### Konfigurasi environment
Buat file `.env` di root project (**jangan pernah commit file ini**):
```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=xxxxx
```

Jalankan migrasi skema database di Supabase SQL Editor (lihat `Struktur Database` di atas untuk definisi tabel), lalu pastikan Row Level Security aktif dengan policy untuk `authenticated` users pada tabel `products` dan `stock_transactions`.

### Jalankan aplikasi
```bash
flutter run
```

## Desain

Palet warna & komponen UI mengikuti gaya minimalis dengan sentuhan earth tone, warna primer hijau tua (`#0F5B33`) dan latar netral (`#F7F8F9`), disesuaikan dari identitas visual produk Laras.

## Catatan Keamanan

`SUPABASE_ANON_KEY` didesain aman untuk terekspos ke client — proteksi data sesungguhnya ada di Row Level Security policy, bukan kerahasiaan key ini. `service_role key` **tidak digunakan** di aplikasi client dan tidak boleh pernah ditaruh di `.env` yang sama.

---

*Dibangun untuk kebutuhan operasional harian usaha reseller tissue Laras.*