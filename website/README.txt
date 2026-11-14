# PANGANKU NASIONAL - WEBSITE DOCUMENTATION
# =========================================
# Dokumentasi file website untuk menampilkan aplikasi PanganKu Nasional

## STRUKTUR DIREKTORI WEBSITE
# ---------------------------
C:\laragon\www\PANGAN\website\
├── index.html              # Halaman utama landing page
├── assets/
│   ├── css/
│   │   └── style.css       # Stylesheet utama
│   ├── js/
│   │   └── main.js         # JavaScript utama
│   └── images/             # Folder gambar (logo, screenshot, ilustrasi)
│       ├── logo.png
│       ├── hero-banner.jpg
│       ├── screenshot-home.png
│       ├── screenshot-price.png
│       ├── screenshot-market.png
│       ├── screenshot-monitoring.png
│       └── screenshot-profile.png

## DESAIN & TEMA WARNA (SESUAI APP FLUTTER)
# ----------------------------------------
Primary Green:   #2E7D32  (Green 700 - WCAG AA on cream)
Primary Light:   #4CAF50  (Green 500)
Primary Dark:    #1B5E20  (Green 900)
Accent Yellow:   #F2B84B  (Amber 500)
Accent Orange:   #F26B3A  (Deep Orange 500)
Background Cream: #FBF7EF
Text Dark:       #2B2118
Surface White:   #FFFFFF
Border Light:    #E2D5C3

Typography:
- Heading: Poppins (700 weight)
- Body: Inter (400/500/600 weight)

## KOMPONEN HALAMAN (index.html)
# ------------------------------
1. NAVIGATION BAR
   - Logo PanganKu Nasional
   - Menu: Beranda, Fitur, Tentang, Unduh, Login
   - CTA Button: "Unduh Aplikasi"

2. HERO SECTION
   - Headline: "Intelijen Pangan Nasional di Genggaman Tangan"
   - Subheadline: "Harga komoditas real-time, pantauan pasar, dan panduan tanam untuk petani Indonesia"
   - Dual CTA: "Unduh di Play Store" + "Lihat Demo"
   - Hero illustration: Phone mockup dengan screenshot app

3. FEATURES GRID (6 fitur utama)
   - Harga Komoditas Real-time
   - Pasar Terdekat & Lokasi
   - Pantauan Harga & Alert
   - Panduan Tanam & AI Pakar
   - Catatan Keuangan & Panen
   - Profil & Multi-peran

4. SCREENSHOTS CAROUSEL
   - 5 tab screenshots: Beranda, Harga, Pasar, Pantauan, Profil
   - Interactive carousel dengan dots navigation

5. TARGET USERS
   - Petani (Produksi, Harga, Jual)
   - Konsumen (Beli, Cek Harga)
   - Admin/Pemerintah (Monitoring Nasional)

6. TECH STACK
   - Flutter 3.24+ / Dart 3.5+
   - Riverpod State Management
   - Material Design 3
   - Offline-first Architecture

7. FOOTER
   - Links: GitHub, Dokumentasi, Privacy, Terms
   - Social media icons
   - Copyright 2024 PanganKu Nasional

## RESPONSIVE BREAKPOINTS
# -----------------------
- Mobile:    ≤ 640px
- Tablet:    641px - 1024px
- Desktop:   ≥ 1025px

## FILE YANG PERLU DIBUAT
# -----------------------
1. index.html     - Structure HTML semantic
2. style.css      - CSS custom properties, grid/flex, animations
3. main.js        - Carousel, smooth scroll, mobile menu toggle
4. Gambar assets  - Logo, hero banner, 5 screenshots

## CARA MENJALANKAN
# ----------------
1. Buka terminal di folder website:
   cd C:\laragon\www\PANGAN\website

2. Jalankan server lokal (Python):
   python -m http.server 8080

3. Atau gunakan Live Server di VS Code:
   - Klik kanan index.html → "Open with Live Server"

4. Akses di browser: http://localhost:8080

## CATATAN UNTUK DEVELOPER
# -----------------------
- Semua warna menggunakan CSS custom properties (--color-primary, dll)
- Font di-load dari Google Fonts (Poppins + Inter)
- Animasi menggunakan CSS @keyframes (reduce-motion respected)
- Semantic HTML5 untuk accessibility
- Meta tags untuk SEO & social sharing (Open Graph, Twitter Card)
- Favicon & PWA manifest ready
- Screenshots placeholder - ganti dengan screenshot real dari app

## INTEGRASI DENGAN APK
# ---------------------
- Link "Unduh" di hero & nav mengarah ke: /app_pangan-debug.apk
- Atau nanti ke Play Store URL
- QR code untuk download mobile bisa ditambahkan