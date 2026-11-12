# DESIGN SYSTEM — PANGAN KU NASIONAL

## 2. PALET WARNA (TOKEN)

### 2.1 Warna Merek
| Token | Hex | RGBA | Penggunaan | Kontras vs Teks (#2B2118) |
|-------|-----|------|------------|---------------------------|
| `--color-brand-primary` | `#2E7D4F` | 46,125,79 | Tombol CTA primer, ikon utama, header | ~5.2:1 (AA) |
| `--color-brand-secondary` | `#F2B84B` | 242,184,75 | Aksen sekunder, highlights, ilustrasi padi | ~2.6:1 (jangan untuk teks kecil) |
| `--color-brand-accent` | `#F26B3A` | 242,107,58 | Tombol aksi penting, notifikasi, "penting" | ~3.9:1 |
| `--color-bg-cream` | `#FBF7EF` | 251,247,239 | Latar belakang aplikasi | — |
| `--color-text-dark` | `#2B2118` | 43,33,24 | Teks utama, judul | — |
| `--color-surface` | `#FFFFFF` | 255,255,255 | Kartu, modal, bottom sheet | — |

### 2.2 Warna Status Data (HARUS selalu + ikon + label teks)
| Token | Hex | Arti | Ikon | Label contoh |
|-------|-----|------|------|--------------|
| `--color-status-success` | `#1B9E56` | Aman / Untung / Normal | `check_circle` | "AMAN", "UNTUNG" |
| `--color-status-warning` | `#E8A33D` | Waspada / Perlu perhatian | `warning` | "WASPADA" |
| `--color-status-danger` | `#D94436` | Kritis / Rugi / Gagal | `error` | "KRITIS", "RUGI" |
| `--color-status-info` | `#2E7D4F` | Informasi / Sinkron | `sync` | "TERSYNC" |

> **Aturan:** Tidak pernah menggunakan warna sebagai pengenal tunggal. Setiap status harus dilengkapi ikon outline 1.5px dan label teks.

### 2.3 Warna Netral & Latar
| Token | Hex | Penggunaan |
|-------|-----|------------|
| `--color-neutral-100` | `#F7F3E9` | Latar sekunder, divider lembut |
| `--color-neutral-200` | `#E2D5C3` | Border input, garis pemisah |
| `--color-neutral-300` | `#C9B7A1` | Border hover/focus |
| `--color-neutral-400` | `#8E7C68` | Teks sekunder, caption |
| `--color-neutral-500` | `#5A4A3A` | Teks body ringan |
| `--color-text-body` | `#2B2118` | Teks utama |
| `--color-on-primary` | `#FFFFFF` | Teks di atas warna primer |

### 2.4 Dark Mode (Dashboard Pemerintah)
| Token | Hex (Light) | Hex (Dark) |
|-------|-------------|------------|
| `--color-bg-cream` | `#FBF7EF` | `#1E1912` |
| `--color-surface` | `#FFFFFF` | `#2A231B` |
| `--color-text-dark` | `#2B2118` | `#F5F0E5` |
| `--color-brand-primary` | `#2E7D4F` | `#4CAF7A` |
Ekosistem Intelijen Pangan (Smart Food Ecosystem)
Versi: 1.0 | Bahasa: Bahasa Indonesia (utama), siap bahasa daerah

## 3. TIPOGRAFI

| Elemen | Font | Berat | Ukuran | Line Height | Catatan |
|--------|------|-------|--------|-------------|---------|
| Judul layar (Display) | Poppins | 700 Bold | 32–40 px | 1.2 | H1 judul halaman |
| Judul section (Heading) | Poppins | 600 SemiBold | 20–24 px | 1.3 | H2 |
| Subjudul | Poppins | 500 Medium | 16–18 px | 1.4 | H3 |
| Body utama | Inter | 400 Regular | 14–16 px | 1.5 | Teks pembaca |
| Body kecil / caption | Inter | 400 Regular | 12–14 px | 1.4 | Label, keterangan |
| Angka besar (KPI) | Inter (tabular) | 700 Bold | 24–36 px | 1.1 | `font-variant-numeric: tabular-nums` |
| Angka harga / mata uang | Inter (tabular) | 500 Medium | 14–16 px | 1.3 | `tabular-nums` |
| Tombol | Poppins | 600 SemiBold | 14–16 px | 1.2 | Uppercase opsional, huruf pertama besar |

- **Tabular figures:** semua angka uang & statistik harus lebar serupa agar tidak "loncat" saat count-up.
- **Skala teks:** mendukung perbesar hingga 200% tanpa kerusakan layout (WCAG AA).
- Bahasa Indonesia sebagai default; siapkan kunci terjemahan untuk bahasa daerah (Jawa, Sunda, dll.) melalui file lokalisasi terpisah.

## 4. SPASI, GRID & BENTUK

| Token | Nilai | Penggunaan |
|-------|-------|------------|
| Grid dasar | 8 px | Semua padding/margin harus kelipatan 8 |
| `--space-xs` | 4 px | |
| `--space-sm` | 8 px | |
| `--space-md` | 16 px | Default kartu |
| `--space-lg` | 24 px | Antar section |
| `--space-xl` | 32 px | Section besar |
| `--space-2xl` | 40 px | |
| `--space-3xl` | 48 px | |
| `--space-4xl` | 56 px | Target sentuh petani minimum |
| Radius kartu kecil | 16 px | Kartu statistik kecil |
| Radius kartu standar | 20 px | Kartu default |
| Radius kartu besar / bottom sheet | 24 px | Modal, bottom sheet |
| Border outline | 1.5 px | Warna `#E2D5C3` (neutral-200) |
| Bayangan (shadow) | `0 4px 12px rgba(43,33,24,0.06)` | Kartu mengambang lembut |
| Bayangan aktif/hover | `0 8px 20px rgba(46,125,79,0.10)` | Saat interaksi |

**Target sentuh:**
- Aplikasi konsumen: minimum 48 px × 48 px.
- Aplikasi petani: minimum **56 px × 56 px** (satu tangan, sarung tangan tipis/kotoran).

## 1. FILOSOFI & KARAKTER
- **Terpercaya:** data transparan, label teks selalu menyertai warna, status koneksi terlihat.
- **Hangat:** nuansa pertanian Indonesia, ilustrasi organis, nuansa krem & daun, bukan korporat dingin.

## 5. IKOGRAFI

- Gaya: **Outline 1.5 px**, satu keluarga (sebut: "Pangan Icons").
- Ukuran: 24 px (default), 32 px (tombol besar petani), 48 px (ikon layar kosong/onboarding).
- Warna ikon: menyesuaikan warna konteks (primer untuk navigasi, status-color untuk status).
- Selalu disertai label teks di bawah ikon untuk petani (tidak hanya ikon).

## 6. KOMPONEN (SPEK)

### 6.1 Tombol
| Jenis | Latar | Teks | Border | Penggunaan |
|-------|-------|------|--------|------------|
| Primary | `#2E7D4F` | Putih | — | Aksi utama (Simpan, Kirim, Bayar) |
| Secondary | `#FFFFFF` | `#2E7D4F` | 1.5 px `#2E7D4F` | Aksi sekunder |
| Ghost | Transparan | `#2B2118` | — | Teks aksi ringan |
| Danger / CTA | `#F26B3A` | Putih | — | Hapus, keluar, peringatan tinggi |
| Icon Besar (Petani) | `#FBF7EF` | Ikon `#2E7D4F` + label | — | 4–6 tombol beranda, ukuran 80–100 px |

- Semua tombol: radius 16 px, padding 16–24 px, state hover/pressed/disabled, haptic pada aksi penting.

### 6.2 Kartu Statistik (Stat Card)
- Latar `#FFFFFF`, radius 20 px, shadow lembut.
- Judul kecil (caption, 12 px), angka besar count-up (24–32 px, tabular), indikator arah trending (↑↓ hijau/merah) + label.
- Contoh: "Indeks Stabilitas Harga: 78 ▲ 3% dari kemarin".

### 6.3 Kartu Komoditas
- Foto komoditas (lingkar atau persegi panjang radius 16 px), nama komoditas, harga per satuan (tabular), badge stok ("Tersedia 120 kg"), chip kategori.
- Sentuh: membuka detail produk.

### 6.4 Chip Filter
- Radius 12 px (pil)
- Tidak aktif: latar `#FFFFFF`, border `#E2D5C3`, teks `#5A4A3A`.
- Aktif: latar `#2E7D4F` (atau `#F2B84B` untuk sekunder), teks putih.

### 6.5 Badge Status
- Bundar / radius 8 px, padding horizontal 8 px, vertikal 4 px.
- Warna sesuai status (hijau/kuning/merah) selalu + teks + ikon kecil.

### 6.6 Grafik Tren (Line / Bar)
- Garis utama warna primer `#2E7D4F`, area di bawah transparan 10%.
- Sumbu Y label ringan, titik data berbentuk lingkaran 6 px.
- Animasi gambar garis (draw) 600–800 ms saat masuk layar.
- Label nilai saat disentuh (tooltip).

### 6.7 Donut Chart (Rincian Biaya)
- Warna segmen sesuai kategori biaya (bibit, pupuk, pestisida, upah, listrik/air, lain-lain).
- Pusat: total nominal besar. Sekeliling: legenda kategori + persentase.
- Animasi menggambar lengkok 800 ms.

### 6.8 Timeline (Pelacakan Pesanan)
- Garis vertikal di tengah (atau kiri pada mobile), titik lingkaran pada setiap milestone.
- Status selesai: lingkaran terisi hijau + centang. Belum: lingkaran abu-abu + garis putus-putus.
- Label waktu di sebelah kanan/kiri bergantian.

### 6.9 Peta (Map)
- Pin komoditas: lingkaran berwarna primer dengan ikon komoditas di tengah, efek kedip halus saat stok berubah.
- Cluster pin saat zoom out.
- Popup saat pin disentuh: nama petani, komoditas, stok, jarak, "diperbarui X menit lalu".


## 7. MIKRO-INTERAKSI & ANIMASI

| Interaksi | Durasi | Easing | Catatan |
|-----------|--------|--------|---------|
| Transisi layar | 200–300 ms | Ease-out | |
| Tambah ke keranjang | 300 ms | Ease-out | Animasi iklon ke ikon keranjang + haptic |
| Angka berubah (count-up) | 600–1000 ms | Ease-out-cubic | Dashboard & laba/rugi |
| Gambar garis grafik | 600–800 ms | Linear | Saat masuk layar |
| Sinkronisasi | 400 ms | Ease | Ikaran putar halus |
| Tombol ditekan | 100 ms | Ease-in | Skala 0.96 |
| Haptic | — | — | Aksi penting: bayar, simpan, kirim, diagnosis |

## 8. ANTARAN DATA REAL-TIME (VISUALISASI)

- Setiap angka stok/harga yang berubah: **badge kecil "baru"** + animasi count-up halus + penanda waktu `"diperbarui X menit lalu"`.
- Saat transaksi terjadi: toast konfirmasi + perbarui kartu terkait tanpa muat ulang layar.
- Status koneksi: iklan awan/sinyal di kanan atas aplikasi petani; teks "Online" / "Offline" / "Menunggu sinkron".
- Peta: pin berkedip saat ada update stok baru di lokasi tersebut.

## 9. BAHASA & LOKALISASI

- Utama: **Bahasa Indonesia**.
- Struktur siap bahasa daerah: kunci terjemahan terpisah per wilayah (contoh namespace `id_ID`, `jv_ID`, `su_ID`).
- Format mata uang: `Rp 1.200.000` (titik pemisah ribuan, koma desimal).
- Format tanggal: `7 Nov 2026`, waktu `14:30 WIB`.

## 10. AKSESIBILITAS (WCAG AA)

- Kontras teks pada latar minimal 4.5:1 (normal), 3:1 (besar/tebal).
- Target sentuh 48 px (konsumen) / 56 px (petani).
- Semua ikon berfungsi dengan label teks (AccessibilityLabel).
- Warna status selalu + ikon + teks (tidakandalkan warna saja).
- Dukungan teks sistem diperbesar hingga 200%.
- Navigasi dapat dilakukan hanya dengan layar sentuh satu jari (petani).

## 11. NAMA KOMPONEN UNTUK IMPLEMENTASI (Figma / Flutter / RN / Next.js)

```
PButton, PIconButton, PStatCard, PCommodityCard,
PFilterChip, PStatusBadge, PLineChart, PDonutChart,
PTimeline, PMapPin, PToast, PBottomSheet,
PEmptyState, PErrorState, PSkeleton, PConnectionBanner,
PSyncIndicator, PVoiceInput, PBigNumber
```
### 6.10 Toast
- Latar `#2B2118`, teks putih, radius 12 px, muncul bawah, hilang otomatis 4 detik.
- Varian sukses (iklan hijau), peringatan (iklan kuning), error (iklan merah).

### 6.11 Bottom Sheet
- Radius atas 24 px, handle grabber di atas, latar `#FFFFFF`.
- Tinggi menyesuaikan konten, maksimal 90% layar.

### 6.12 Empty / Error / Loading State
- **Skeleton:** bar abu-abu lembut `#E2D5C3` beranimasi gelombang, tinggi sesuai konten.
- **Empty:** ilustrasi besar (48–64 px), judul, subtitle, tombol aksi satu.
- **Error:** iklan peringatan, judul "Terjadi gangguan", subtitle, tombol "Coba lagi".
- **Offline (petani):** banner atas "Tidak ada sinyal — mencatat di HP", indikator "Tersimpan di HP / Menunggu sinkron / Tersinkron".
- **Modern:** tipografi bersih, bayangan lembut, animasi halus, count-up angka.
- **Inklusif:** untuk petani dengan literasi digital rendah — ikon besar, satu tujuan per layar, minim teks, input suara, target sentuh 56px.