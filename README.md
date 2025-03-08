# 🚚 Aplikasi Pelacakan & Manajemen Pengiriman Driver

## Gambaran Umum

Aplikasi mobile berbasis Flutter ini menyediakan pelacakan real-time dan manajemen untuk driver pengiriman yang menangani surat jalan. Aplikasi ini mengoptimalkan proses pengiriman dengan memantau lokasi driver, mendokumentasikan tonggak penting dengan gambar, dan menyediakan antarmuka yang mulus antara driver dan sistem pusat.

## 🎯 Tujuan

Tujuan utama aplikasi ini adalah untuk meningkatkan visibilitas dan akuntabilitas dalam proses pengiriman dengan:

- Melacak posisi driver secara real-time
- Mendokumentasikan pembacaan odometer kendaraan di awal pengiriman
- Mengambil bukti fotografis pengiriman yang berhasil atau gagal
- Mencatat pembacaan odometer kendaraan saat kembali ke gudang
- Menyediakan jejak digital dari seluruh proses pengiriman

## 🔧 Teknologi yang Digunakan

### Frontend
- **Flutter** - Framework lintas platform untuk aplikasi mobile
- **OpenStreetMaps** dengan Polylines - Untuk visualisasi rute real-time
- **Integrasi Kamera** - Untuk mengambil bukti pengiriman dan pembacaan odometer
- **SharedPreferences** - Penyimpanan lokal untuk data autentikasi pengguna

### Integrasi Backend
- **API Epicor** - Untuk mengambil data surat jalan
- **API GPS** - Untuk pelacakan lokasi yang akurat
- **Backend Kustom** - Mengelola integrasi antar sistem

## ✨ Fitur Utama

### 1. Pelacakan Lokasi Real-time
- Pemantauan berkelanjutan posisi driver
- Visualisasi rute dengan polylines di OpenStreetMaps
- Pencatatan jalur historis

### 2. Dokumentasi Pengiriman
- Integrasi kamera untuk mengambil pembacaan odometer
- Bukti pengiriman melalui foto
- Dokumentasi alasan untuk pengiriman yang gagal

### 3. Integrasi Mulus
- Koneksi langsung dengan sistem ERP Epicor
- Sinkronisasi data yang efisien
- Kemampuan offline untuk area dengan konektivitas buruk

### 4. Pengalaman Pengguna
- Antarmuka intuitif yang dirancang untuk driver dalam perjalanan
- Interaksi minimal yang diperlukan untuk tugas-tugas umum
- Indikator visual yang jelas tentang status pengiriman

## 🧩 Alur Aplikasi

1. **Login**
   - Autentikasi aman untuk driver
   - Kontrol akses berbasis peran

2. **Pengecekan Odometer Awal**
   - Sistem memverifikasi apakah pembacaan odometer awal telah dicatat untuk hari ini
   - Jika belum dicatat, driver diarahkan untuk mengambil pembacaan odometer
   - Jika sudah dicatat, driver melanjutkan ke daftar pengiriman

3. **Layar Manajemen Pengiriman**
   - Tampilan peta interaktif dengan OpenStreetMaps
   - Pelacakan lokasi real-time dengan visualisasi rute polyline
   - Daftar surat jalan untuk hari ini
   - Kemampuan untuk melihat informasi detail untuk setiap pengiriman

4. **Layar Status Pengiriman**
   - Integrasi kamera untuk mendokumentasikan pengiriman
   - Pemilihan status (Berhasil/Gagal)
   - Pemilihan dropdown untuk alasan kegagalan bila diperlukan
   - Bidang catatan untuk informasi tambahan

5. **Kembali ke Daftar Pengiriman**
   - Setelah mendokumentasikan pengiriman, driver kembali ke daftar pengiriman utama
   - Indikator status yang diperbarui untuk pengiriman yang selesai

6. **Pembacaan Odometer Akhir Hari**
   - Pembacaan odometer final diambil saat kembali ke gudang
   - Perhitungan dan pelaporan statistik perjalanan

## 🚧 Tantangan Pengembangan

### 1. Kompleksitas Integrasi Backend
- Mengatasi keterbatasan lisensi Epicor sambil memastikan akses data yang andal
- Membuat solusi middleware yang secara efisien menjembatani sistem Epicor dan GPS
- Menerapkan protokol transfer data yang aman

### 2. Presisi Geolokasi
- Mendapatkan koordinat yang akurat untuk setiap lokasi pelanggan
- Mengatasi inkonsistensi dalam data peta
- Menangani kualitas sinyal GPS yang bervariasi di berbagai area pengiriman

### 3. Implementasi Peta
- Implementasi kompleks OpenStreetMaps dengan polylines untuk pelacakan rute
- Mengoptimalkan rendering peta untuk kinerja pada berbagai perangkat
- Menyeimbangkan detail visual dengan performa aplikasi

### 4. Fungsionalitas Offline
- Memastikan fitur-fitur penting berfungsi di area dengan konektivitas buruk
- Menerapkan sinkronisasi data yang andal saat koneksi dipulihkan
- Mengelola batasan penyimpanan lokal

### 5. Optimasi Baterai
- Menyeimbangkan pelacakan GPS yang akurat dengan konsumsi baterai
- Menerapkan interval polling lokasi yang cerdas
- Menyediakan opsi hemat daya sambil mempertahankan fungsionalitas

## 📱 Layar & Fungsionalitas

### Layar Login
- Autentikasi username dan password
- Fungsi "Ingat saya"
- Manajemen kredensial yang aman

### Pembacaan Odometer Awal
- Antarmuka kamera untuk mengambil gambar odometer yang jelas
- Bantuan OCR untuk pengenalan digit (peningkatan opsional)
- Langkah konfirmasi untuk memverifikasi akurasi pembacaan

### Daftar Pengiriman & Peta
- Antarmuka layar terpisah dengan peta di atas dan daftar pengiriman yang dapat digulir di bawah
- Indikator status pengiriman dengan kode warna
- Peta interaktif dengan kemampuan zoom dan pan
- Integrasi petunjuk arah belokan demi belokan (peningkatan opsional)

### Detail Pengiriman
- Tampilan informasi surat jalan
- Detail pelanggan dan instruksi khusus
- Perkiraan waktu kedatangan berdasarkan lokasi saat ini
- Inisiasi navigasi dengan satu sentuhan

### Dokumentasi Status Pengiriman
- Antarmuka kamera untuk bukti pengiriman
- Antarmuka pemilihan status
- Pemilihan alasan terstruktur untuk pengiriman yang gagal
- Pengambilan tanda tangan digital untuk pengiriman yang berhasil (peningkatan opsional)

### Pembacaan Odometer Akhir
- Antarmuka serupa dengan pembacaan awal
- Tampilan ringkasan perjalanan
- Ikhtisar statistik harian

## 🚀 Peningkatan Masa Depan

### Peningkatan yang Direncanakan
- **Dasbor Analitik Lanjutan** untuk manajer armada
- **Optimasi Rute** algoritma untuk menyarankan urutan pengiriman yang efisien
- Integrasi **Navigasi Berbantuan Suara**
- **Sistem Notifikasi Pelanggan** untuk pembaruan pengiriman real-time
- **Pengiriman dengan AR yang Ditingkatkan** untuk pengiriman gudang atau kantor yang kompleks
- **Pembelajaran Mesin** untuk memprediksi tantangan pengiriman berdasarkan data historis

### Persyaratan
- Android 6.0+ atau iOS 12.0+
- Layanan lokasi diaktifkan
- Izin kamera diberikan
- Konektivitas jaringan (4G direkomendasikan)
- Minimum 2GB RAM

---

*Aplikasi ini merepresentasikan kemajuan signifikan dalam operasi pengiriman kami, menggabungkan teknologi mobile modern dengan sistem perusahaan untuk menciptakan proses pengiriman yang mulus, akuntabel, dan efisien.*
