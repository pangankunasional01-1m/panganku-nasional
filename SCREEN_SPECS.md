# SCREEN SPECS — PANGAN KU NASIONAL
Ukuran acuan: Mobile 390×844 (petani & konsumen), Desktop 1440×900 (dashboard web).
Copy dalam Bahasa Indonesia. Setiap layar menyebutkan: layout, komponen, interaksi, dan state (loading/empty/error/offline).

## A. APLIKASI PETANI / PRODUSEN / UMKM (Mobile 390×844)

### A1. Onboarding (maksimal 4 langkah + ilustrasi)
**Langkah 1/4 — Pilih Peran**
- Ilustrasi besar petani di tengah.
- 3 kartu pilihan: "Petani", "Produsen / Pengolahan", "UMKM Pangan".
- Setiap kartu: ikon besar 48 px, nama peran, deskripsi satu baris.
- Tombol "Lanjutkan" di bawah (disabled sampai pilihan dipilih).
- Link kecil: "Mulai sebagai konsumen".

**Langkah 2/4 — Pilih Komoditas**
- Grid komoditas: Beras, Jagung, Cabai, Bawang Merah, Kedelai, dll.
- Setiap item: foto komoditas, nama, chip "Lahan saya" jika pernah dipilih.
- Pilihan ganda diizinkan (multi-select).

**Langkah 3/4 — Tentukan Lokasi Lahan**
- Peta kecil statis atau input provinsi/kabupaten/desa.
- Tombol "Gunakan lokasi saya" (GPS).
- Input teks desa/kecamatan.

**Langkah 4/4 — Selesai**
- Ringkasan pilihan: peran, komoditas, lokasi.
- Tombol "Mulai Beranda".
- State: loading saat menyimpan profil → toast "Profil tersimpan".

### A2. Beranda Petani
Header: sapaan dinamis "Selamat pagi, [Nama]".
Kartu 1 — Musim Tanam Aktif: "Musim Tanam 2026 — Cabai", tanggal tanam, estimasi panen, progres lingkaran 60%.
Kartu 2 — Laba/Rugi Sementara: indikator besar "UNTUNG Rp 1.200.000" (hijau) atau "RUGI Rp X" (merah).
Kartu 3 — Harga Komoditas Hari Ini (Daerahmu): daftar horizontal komoditas dengan harga & deviasi vs acuan.
Kartu 4 — Peringatan Cuaca/Hama: badge waspada/berbahaya + pesan singkat, misal "Hama hawar daun terdeteksi di kabupatenmu".

Tombol ikon besar (4–6, 2 baris × 3 kolom, ukuran ~80 px, label di bawah):

### A3. Pencatatan Keuangan (Laba/Rugi Otomatis)
Tab: "Pengeluaran" | "Pemasukan".

**Catat Pengeluaran Harian**
- Dropdown kategori ikon: Bibit, Pupuk, Pestisida, Upah Tenaga Kerja, Listrik/Air, Lain-lain.
- Input nominal: tombol mikrofon besar (voice-to-text) ATAU keypad angka besar.
- Contoh suara: "beli pupuk urea dua karung seratus empat puluh ribu" → terjemah jadi `Pupuk — Rp 140.000`.
- Tanggal otomatis hari ini, bisa diubah kalender.
- Tombol "Simpan" (hijau, lebar penuh).
- Toast: "Tersimpan di HP" / "Tersinkron".

**Laporan Laba/Rugi per Musim Tanam**
- Indikator besar: "UNTUNG Rp X" (hijau) / "RUGI Rp X" (merah), count-up.
- Grafik batang sederhana: pemasukan vs pengeluaran per bulan.
- Donut chart: rincian biaya per kategori.
- Bandingkan: chip "Musim ini" vs "Musim lalu".

**State:** skeleton loading saat memuat laporan, empty state "Belum ada pencatatan" dengan tombol "Catat Biaya Pertama".

### A4. Agri-Advisor AI
Tab: "Rekomendasi Budidaya" | "Diagnosis Tanaman".

**Rekomendasi Budidaya**
- Kartu langkah bergambar: waktu tanam terbaik (berdasarkan cuaca & tanah), takaran pupuk efisien, pencegahan hama organik.
- Setiap langkah: gambar 48 px, judul, deskripsi 1-2 baris.

**Diagnosis Tanaman**
- Tombol besar: "Ambil Foto" / "Unggah Galeri".
- Setelah foto: loading AI.
- Hasil: nama penyakit, tingkat keyakinan (persen besar), ikon status (hijau/kuning).
- Solusi bertahap (daftar langkah dengan nomor besar).
- Tombol "Tanya Penyuluh" (oranye) jika keyakinan rendah.
- Tombol "Simpan ke Riwayat Lahan" (hijau).

### A5. Manajemen Panen & Pre-Order
- Form rencanakan kuota panen: komoditas (dropdown), jumlah (kg), perkiraan tanggal (kalender).
- Indikator risiko overproduksi: banner kuning "Daerahmu sudah ada 80% kuota cabai bulan ini, pertimbangkan tanam komoditas lain atau jual ke industri olahan."
- Daftar pre-order masuk: kartu setiap pembeli dengan jumlah, tanggal target, status (Menunggu / Dikonfirmasi / Dikirim), tombol "Tandai Terkirim".

### A6. Penjualan
- Form pasang produk: foto (unggah), nama komoditas, jumlah, harga.
- Harga acuan Bapanas (garis referensi) + harga pasar sekitar sebagai pembanding.
- Saran harga wajar ditampilkan otomatis.
- Pratinjau listing sebelum publikasi.

### A7. Supply-Demand Matching
- Kartu tawaran penyaluran kelebihan panen ke industri pengolahan terdekat.
- Kondisi: saat pasar segar jenuh (deteksi sistem).
- Tombol "Ajukan Penyaluran" → bottom sheet detail industri, estimasi ongkir, volume.

### A8. Pesanan & Pengiriman
- Daftar pesanan dengan status warna (Menunggu / Diproses / Dikirim / Selesai).
- Titik kumpul (Drop Point): nama lokasi, alamat, jadwal pengambilan.
- Pencairan pembayaran: status "Dicairkan" / "Menunggu verifikasi", tombol "Ajukan Pencairan".
1. Catat Biaya (ikon uang)
2. Catat Panen (ikon padi)

## B. APLIKASI KONSUMEN & MARKETPLACE (Mobile 390×844)

### B1. Beranda Konsumen
- Search bar di atas.
- Kategori pangan pokok (beras, sayuran, daging, dll.) scroll horizontal dengan ikon + label.
- "Tersedia dekat kamu": kartu komoditas live stok dengan jarak.
- Perbandingan harga hari ini vs pasar konvensional (badge hijau "Lebih murah 12%").
- Rekomendasi resep (kartu resep dengan foto dan waktu masak).

### B2. Peta Harga & Ketersediaan
- Penuh layar peta.
- Pin komoditas terdekat dengan warna kategori.
- Filter bawah: jarak, harga, organik (chip).
- Popup pin: nama petani, komoditas, stok ("Sisa 25 kg"), "diperbarui 2 menit lalu", tombol "Beli".
- Indikator stok live di dalam pin (badge kecil hijau = tersedia, merah = habis).

### B3. Detail Produk
- Foto besar (carousel).
- Harga per satuan (angka besar tabular).
- Badge "lebih murah X% dari pasar".
- Profil dan lokasi petani (foto kecil, nama, desa).
- Tanggal panen, asal daerah, kandungan gizi, ulasan (bintang + komentar).
- Garansi Kualitas: teks "Klaim jika tidak sesuai dengan deskripsi".
- Tombol "Beli Sekarang" / "Pre-Order".

### B4. Pre-Order
- Pilih jadwal panen (daftar tanggal tersedia).
- Pilih jumlah.
- Opsi pembayaran: "Bayar di muka" / "Bayar saat tiba".
- Ringkasan: total, tanggal estimasi tiba.

### B5. Keranjang & Checkout (maksimal 3 langkah)
Langkah 1: Ringkasan item.
Langkah 2: Pengiriman — pilih "Kirim ke alamat" atau "Kirim kolektif ke Drop Point RT". Jika Drop Point: tampilkan penghematan ongkir + jumlah tetangga bergabung.
Langkah 3: Pembayaran & konfirmasi.
- Tombol "Bayar Sekarang" lebar penuh.

### B6. Transparansi Transaksi & Pelacakan
- Rincian harga: harga petani, ongkir, biaya layanan, total.
- Timeline pelacakan: Diproses → Dikemas → Dikirim → Sampai.
- Setiap milestone: waktu, status, catatan.

### B7. Stok Dapur & Resep
- Daftar bahan stok di rumah dengan pengingat beli ulang.
- Resep dari bahan yang tersedia (kartu resep).
3. Jual (ikon keranjang)
4. Tanya Pakar AI (ikon bot)
5. Panduan Tanam (ikon buku)
6. Laporan (ikon dokumen)

## C. DASHBOARD PEMERINTAH / ADMIN (Web 1440×900)

Layout: Sidebar kiri (navigasi), Top bar (filter wilayah nasional > provinsi > kabupaten + rentang waktu + toggle dark mode), Area konten (kartu & grafik padat).

### C1. Ringkasan Nasional
- KPI bar: Indeks Stabilitas Harga, Rata-rata Harga Komoditas Strategis, Stok Nasional, Jumlah Wilayah Waspada.
- Setiap KPI: angka besar count-up + indikator naik/turun + "diperbarui X menit lalu".
- Tombol ekspor data.

### C2. Peta Panas (Heatmap) Harga & Stok
- Peta Indonesia dengan heatmap per wilayah (merah = defisit/tinggi, hijau = surplus/aman).
- Drill-down: klik provinsi → lihat kabupaten.
- Filter komoditas di atas peta.

### C3. Monitoring Harga Makro
- Grafik tren harian/mingguan.
- Dua garis: harga lokal vs harga acuan Bapanas.
- Deviasi ditandai warna (hijau = stabil, merah = lonjakan).
- Tabel di bawah: komoditas, harga lokal, acuan, deviasi %.

### C4. Early Warning System
- Daftar peringatan: kartu per peringatan dengan tingkat keparahan (badge hijau/kuning/merah), penyebab terduga, prediksi 7–30 hari, rekomendasi tindakan.
- Tombol "Lihat Detail" → arahkan ke intervensi.

### C5. Intervensi Pasar
- Form mobilisasi stok: pilih asal (surplus), tujuan (defisit), volume, estimasi biaya dan waktu.
- Tabel pelacakan status intervensi: Diajukan → Disetujui → Dikirim → Diterima.

### C6. Supply-Demand Matching
- Daftar kelebihan panen terdeteksi per daerah.
- Industri pengolahan terdekat dengan jarak.
- Estimasi food loss yang dicegah (kg dan nilai uang).

### C7. Analitik & Laporan
- Filter periode & wilayah.
- Tabel data lengkap dengan pagination.
- Tombol "Ekspor PDF" / "Ekspor Excel".

### C8. Manajemen Pengguna
- Daftar petani/UMKM dengan status verifikasi (Belum diverifikasi / Terverifikasi / Ditolak).
- Tombol verifikasi per user.
- Log aktivitas (tabel: user, aksi, waktu, IP).

**Dark mode:** toggle di top bar mengubah latar ke gelap (lihat DESIGN_SYSTEM 2.4).

Footer: indikator sinkron (ikon awan + teks "Tersinkron") + notifikasi sinyal.

**State offline:** banner atas merah "Tidak ada sinyal — mencatat di HP", semua tombol tetap bisa ditekan.