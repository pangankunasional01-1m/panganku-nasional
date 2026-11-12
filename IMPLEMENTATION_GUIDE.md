# CATATAN IMPLEMENTASI — PANGAN KU NASIONAL
Referensi untuk Figma, Flutter, React Native, dan Next.js. Disesuaikan dengan arsitektur Central Intelligence Engine yang melayani 3 antarmuka.

## 1. FIGMA (Desain)

### 1.1 Variabel & Style
- **Color Variables:** brand-primary (#2E7D4F), brand-secondary (#F2B84B), brand-accent (#F26B3A), bg-cream (#FBF7EF), text-dark (#2B2118), status-success/warning/danger, neutral-100..500, dark-mode variants.
- **Typography Styles:** H1/H2/H3 (Poppins), Body (Inter), Body-Small (Inter), BigNumber (Inter, tabular-nums), Button (Poppins SemiBold).
- **Effect Styles:** Shadow lembut (0 4px 12px rgba(43,33,24,0.06)), Shadow aktif (0 8px 20px rgba(46,125,79,0.10)).
- **Border:** 1.5 px outline #E2D5C3.
- **Radius:** 16 / 20 / 24 px.

### 1.2 Komponen (Component + Variants)
- `PButton`: Primary / Secondary / Ghost / Danger / IconBesar, states Default/Hover/Pressed/Disabled.
- `PStatCard`: judul, angka, indikator trending.
- `PCommodityCard`: foto, nama, harga, badge stok, chip kategori.
- `PFilterChip`: default / active.
- `PStatusBadge`: success / warning / danger / info (setiap variant selalu pakai ikon + teks).
- `PLineChart` / `PDonutChart`: animasi draw state.
- `PTimeline`: selesai / belum.
- `PMapPin`: default / aktif / clustered.
- `PToast`: sukses / peringatan / error.
- `PBottomSheet`: handle + konten.
- `PEmptyState` / `PErrorState` / `PSkeleton`.
- `PConnectionBanner` + `PSyncIndicator`: online / offline / menunggu sinkron / tersinkron.
- `PVoiceInput`: tombol mikrofon besar + transkrip hasil suara.
- `PBigNumber`: count-up angka.

### 1.3 Auto Layout & Constraints
- Semua komponen gunakan Auto Layout, spacing kelipatan 8 px.
- Min width tombol petani 56 px, height 56 px.
- Frame layar: Mobile 390×844, Desktop 1440×900.
- Gunakan "Dev Mode" untuk inspeksi nilai CSS/Dart langsung oleh developer.

## 2. FLUTTER (Mobile Petani & Konsumen + Web Admin)

Proyek ada di: `c:\laragon\www\PANGAN\app_pangan` (Flutter 3.47.7).

### 2.1 Dependensi yang direkomendasikan (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.5.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.3
  connectivity_plus: ^6.0.5
  web_socket_channel: ^2.4.0
  speech_to_text: ^7.0.0
  intl: ^0.19.0
  fl_chart: ^0.69.0
  flutter_map: ^7.0.2
  latlong2: ^0.9.0
  pdf: ^3.11.0
  excel: ^4.0.6
```

### 2.2 Tema (lib/core/theme/app_theme.dart)
- Gunakan `ColorScheme` dengan seed `#2E7D4F` dan overrides untuk status warna.
- `TextTheme`: Poppins untuk judul, Inter untuk body.
- Tabular figures via `GoogleFonts.inter(textStyle: TextStyle(fontFeatures: [FontFeature.tabularFigures()]))`.

### 2.3 Pola Offline-First (penting)
- **Lokal:** Hive untuk menyimpan pencatatan biaya, panen, riwayat diagnosis, pesanan, profil petani.
- **Antrean sinkron:** setiap aksi tulis ke Hive dulu + tambahkan entri ke `sync_queue` (status: pending/uploaded/failed).
- **Koneksi:** `connectivity_plus` memantau sinyal. Saat online → worker background meng-upload antrean ke API.
- **Indikator UI:** `PConnectionBanner` di atas layar petani; `PSyncIndicator` ("Tersimpan di HP" → "Menunggu sinkron" → "Tersinkron").
- **Conflict resolution:** timestamp `updated_at` di setiap catatan; yang lebih baru menang saat sinkron.

### 2.4 Real-time Update
- Central Intelligence Engine expose **WebSocket** atau **SSE** untuk topik: harga komoditas, stok, peringatan dini.
- Flutter: `web_socket_channel` atau paket `sse_client`.
- Saat data berubah: update Riverpod provider → animasi count-up + badge "baru" + timestamp "diperbarui X menit lalu".

### 2.5 Struktur folder
```
lib/
  core/
    theme/app_theme.dart
    constants/app_constants.dart
    localizations/app_localizations.dart
    widgets/ (PButton, PStatCard, PCommodityCard, ...)
  features/
    farmer/
      onboarding, home, finance, agri_advisor, harvest, sales, supply_demand, orders
    consumer/
      home, map, product_detail, pre_order, cart, checkout, tracking, pantry
    admin/ (web)
      dashboard, heatmap, price_monitoring, early_warning, intervention, analytics, users
```

## 3. REACT NATIVE (Alternatif Mobile)
- **UI:** `react-native-paper` atau komponen custom dengan `TouchableOpacity` (min 56 px petani / 48 px konsumen).
- **Offline:** `@react-native-async-storage/async-storage` + `react-native-netinfo` untuk antrean sinkron.
- **Real-time:** `react-native-websocket` atau EventSource (SSE).
- **Voice:** `@react-native-voice/voice` atau `react-native-speech-to-text`.
- **Grafik:** `react-native-chart-kit` atau `victory-native`.
- **Peta:** `react-native-maps`.
- **Ikon:** `react-native-vector-icons` (gaya outline).
- Lokalisasi: `i18next` dengan namespace `id_ID`, `jv_ID`, `su_ID`.

## 4. NEXT.JS (Dashboard Admin Web)
- **Framework:** Next.js 14 (App Router), React Server Components untuk data awal, Client Components untuk interaksi real-time.
- **Styling:** Tailwind CSS dengan token warna dari DESIGN_SYSTEM (konfigurasi `tailwind.config.js`).
- **Tema:** `next-themes` untuk light/dark mode.
- **Tabel & Grafik:** `tanstack-table` + `recharts` / `chart.js`.
- **Peta:** `react-leaflet` atau `maplibre-gl`.
- **Real-time:** `EventSource` (SSE) atau Socket.io client di sisi klien.
- **Ekspor:** `jspdf` (PDF) + `exceljs` (Excel).
- **Responsif:** sidebar collapsible pada tablet, grid kartu menyesuaikan lebar layar.
- **Aksesibilitas:** ARIA label pada semua ikon status, kontras WCAG AA, keyboard navigation.

## 5. ARSITEKTUR DATA REAL-TIME (Central Intelligence Engine)
- API REST untuk CRUD (profil, pencatatan, pesanan).
- WebSocket/SSE untuk update stok & harga tiap detik dari hub distribusi.
- Setiap payload sertakan `updated_at` dan `source`.
- Frontend tampilkan `diperbarui X menit lalu` dengan rounded menit.
- Animasi count-up hanya saat nilai berubah lebih dari ambang (misal >1%).

## 6. CHECKLIST SEBELUM HANDOFF KE DEV
- [ ] Semua warna status has ikon + teks label (tidak hanya warna).
- [ ] Tombol petani min 56×56 px, konsumen 48×48 px.
- [ ] Setiap layar punya state: loading, empty, error, offline.
- [ ] Angka uang & statistik pakai tabular figures.
- [ ] Copy dalam Bahasa Indonesia, siap kunci lokalisasi bahasa daerah.
- [ ] Dark mode siap untuk dashboard admin.
- [ ] Antrean sinkron & indikator "Tersimpan di HP / Menunggu sinkron / Tersinkron" terdefinisi.