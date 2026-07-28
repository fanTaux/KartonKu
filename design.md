# Design Guidelines: Laras Tissue Inventory App

## 1. Konsep Desain Utama
Desain aplikasi kita akan mengusung gaya **minimalist, clean, dan professional** dengan sentuhan **earth tone** agar nyaman dipandang selama operasional sehari-hari. Tata letak difokuskan pada fungsionalitas dan kemudahan pemindaian informasi.

## 2. Palet Warna
Palet warna diambil dari identitas produk Laras pada gambar, dikombinasikan dengan warna netral untuk menjaga kebersihan UI.

*   **Primary Green (Deep Forest Green):** `#006837`
*   **Secondary Green (Light Leaf Green):** `#39B54A`
*   **Accent Orange:** `#F7931E` 
*   **Background (Off-White/Light Earth Tone):** `#FAF8F5`
*   **Surface (White):** `#FFFFFF`
*   **Text/Typography:** `#333333` untuk teks utama, `#757575` untuk teks sekunder.

## 3. Tipografi
*   **Primary Font:** `Inter` atau `Roboto`.
*   **Heading:** Bold, untuk nama varian produk tissue.
*   **Body:** Regular, untuk detail jumlah stok, isi, dan Qty/Ctn.

## 4. Komponen UI
*   **Cards:** Menggunakan sudut yang sedikit membulat (border-radius: 12px) dengan bayangan yang sangat tipis untuk memisahkan daftar inventaris tanpa terlihat penuh.
*   **Floating Action Button (FAB):** FAB di sudut kanan bawah dengan warna Primary Green untuk memicu fitur kamera/scan.
*   **Status Badges:** Kapsul indikator warna (hijau untuk stok aman, oranye/merah untuk peringatan stok menipis).
*   **Data Grid/List:** Menampilkan thumbnail kemasan tissue di sebelah kiri, nama varian di atas, dan jumlah karton/pack di sebelah kanan.
