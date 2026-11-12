import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_button.dart';
import '../../../core/widgets/p_card.dart';
import '../../../core/widgets/p_chip_badge.dart';
import '../../../core/widgets/p_connection_banner.dart';
import '../../auth/auth_provider.dart';
import 'ai_expert_screen.dart';
import 'production_screen.dart';
import 'planting_guide_screen.dart';
import 'report_screen.dart';
import 'sell_screen.dart';
import 'settings_screen.dart';

/// Beranda Petani — ikon besar, satu tujuan per layar, satu tangan.
class FarmerHome extends ConsumerWidget {
  const FarmerHome({super.key});

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  static void _soon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label — segera hadir')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.bgCream,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Stack(
            children: [
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 300,
                child: _HeaderBackground(),
              ),
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Sapaan + notifikasi + status koneksi ────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EntranceAnimation(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(),
                                    style: AppTheme.inter(
                                      fontSize: 14,
                                      weight: FontWeight.w500,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ref.watch(authProvider).user?.name ??
                                        'Bapak Sugianto',
                                    style: AppTheme.poppins(
                                      fontSize: 26,
                                      weight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.16,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.28,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.eco_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Musim Tanam 2026 — Cabai',
                                          style: AppTheme.inter(
                                            fontSize: 12,
                                            weight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                _NotificationButton(
                                  icon: Icons.notifications_none_rounded,
                                  label: 'Notifikasi',
                                  showDot: true,
                                  onTap: () => _soon(context, 'Notifikasi'),
                                ),
                                const SizedBox(width: 8),
                                _NotificationButton(
                                  icon: Icons.settings_rounded,
                                  label: 'Pengaturan',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: EntranceAnimation(
                        delay: Delay(80),
                        child: PConnectionBanner(state: PSyncState.synced),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Kartu laba/rugi (hero) ──────────────────────────────
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: EntranceAnimation(
                        delay: Delay(160),
                        scaleFrom: 0.96,
                        child: _ProfitHero(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Harga komoditas ─────────────────────────────────────
                    EntranceAnimation(
                      delay: const Delay(240),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _SectionHeader(
                          title: 'Harga Komoditas Hari Ini',
                          action: 'Lihat semua',
                          onAction: () => _soon(context, 'Daftar harga'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 188,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: _commodities.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final c = _commodities[i];
                          return SizedBox(
                            width: 166,
                            child: EntranceAnimation(
                              delay: Delay(300 + i * 90),
                              offset: const Offset(0.25, 0),
                              child: PCommodityCard(
                                name: c.name,
                                price: c.price,
                                stock: c.stock,
                                category: c.category,
                                icon: c.icon,
                                tint: c.tint,
                                onTap: () => _soon(context, c.name),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Peringatan hama ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EntranceAnimation(
                        delay: const Delay(380),
                        child: _PestAlert(
                          onTap: () => _soon(context, 'Detail peringatan'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Cepat akses ─────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EntranceAnimation(
                        delay: const Delay(440),
                        child: const _SectionHeader(title: 'Cepat Akses'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _bigButtonGrid(context),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _commodities = <_Commodity>[
    _Commodity(
      'Padi',
      'Rp 6.800 / kg',
      'Tersedia 1.200 kg',
      'Pangan Pokok',
      Icons.grain_rounded,
      Color(0xFFD4B44A),
    ),
    _Commodity(
      'Beras',
      'Rp 12.500 / kg',
      'Tersedia 500 kg',
      'Pangan Pokok',
      Icons.grain_rounded,
      Color(0xFFD99A1E),
    ),
    _Commodity(
      'Jagung',
      'Rp 8.500 / kg',
      'Tersedia 300 kg',
      'Pangan Pokok',
      Icons.grass_rounded,
      AppTheme.brandPrimary,
    ),
    _Commodity(
      'Singkong',
      'Rp 4.000 / kg',
      'Tersedia 400 kg',
      'Pangan Pokok',
      Icons.eco_rounded,
      Color(0xFFC9A86A),
    ),
  ];

  Widget _bigButtonGrid(BuildContext context) {
    final items = <(IconData, String, Color, VoidCallback)>[
      (
        Icons.payments_rounded,
        'Catat Biaya',
        AppTheme.brandPrimary,
        () => Navigator.pushNamed(context, '/finance'),
      ),
      (
        Icons.inventory_2_rounded,
        'Hasil Produksi',
        AppTheme.brandPrimary,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductionScreen()),
        ),
      ),
      (
        Icons.shopping_cart_rounded,
        'Jual',
        AppTheme.brandPrimary,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SellScreen()),
        ),
      ),
      (
        Icons.smart_toy_rounded,
        'Tanya Pakar AI',
        AppTheme.brandAccent,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiExpertScreen()),
        ),
      ),
      (
        Icons.menu_book_rounded,
        'Panduan Tanam',
        AppTheme.brandPrimary,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PlantingGuideScreen()),
        ),
      ),
      (
        Icons.description_rounded,
        'Laporan',
        AppTheme.brandPrimary,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportScreen()),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final w = (constraints.maxWidth - gap * 2) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < items.length; i++)
              SizedBox(
                width: w,
                child: EntranceAnimation(
                  delay: Delay(500 + i * 70),
                  offset: const Offset(0, 0.25),
                  scaleFrom: 0.88,
                  curve: Curves.easeOutBack,
                  child: PIconBigButton(
                    icon: items[i].$1,
                    label: items[i].$2,
                    color: items[i].$3,
                    onPressed: items[i].$4,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Commodity {
  final String name, price, stock, category;
  final IconData icon;
  final Color tint;
  const _Commodity(
    this.name,
    this.price,
    this.stock,
    this.category,
    this.icon,
    this.tint,
  );
}

// ── Latar header: gradient + lingkaran dekoratif + daun melayang ───────────
class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -40,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: 30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 28,
            top: 96,
            child: Floating(
              distance: 9,
              child: Icon(
                Icons.eco_rounded,
                size: 110,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final bool showDot;
  const _NotificationButton({
    required this.onTap,
    this.icon = Icons.notifications_none_rounded,
    this.label = 'Notifikasi',
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
          ),
          if (showDot)
            const Positioned(
              top: -2,
              right: -2,
              child: PulseDot(color: AppTheme.brandSecondary, size: 8),
            ),
        ],
      ),
    );
  }
}

// ── Kartu hero laba/rugi ───────────────────────────────────────────────────
class _ProfitHero extends StatelessWidget {
  const _ProfitHero();

  static const _data = [2.0, 2.6, 2.3, 3.1, 2.9, 3.8, 3.5, 4.4];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: AppTheme.cardDecoration(
        radius: 28,
        shadows: AppTheme.softShadow(0.12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Laba/Rugi Sementara',
                  style: AppTheme.inter(
                    fontSize: 13,
                    weight: FontWeight.w500,
                    color: AppTheme.neutral400,
                  ),
                ),
              ),
              const PStatusBadge(type: PStatusType.success, label: 'UNTUNG'),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedCounter(
              value: 1200000,
              prefix: 'Rp ',
              style: tabularNumber(
                fontSize: 36,
                weight: FontWeight.w800,
                color: AppTheme.statusSuccess,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.statusSuccess.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_upward_rounded,
                      size: 13,
                      color: AppTheme.statusSuccess,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+8%',
                      style: AppTheme.inter(
                        fontSize: 12,
                        weight: FontWeight.w700,
                        color: AppTheme.statusSuccess,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'vs musim lalu',
                style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral400),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 70,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1300),
              curve: Curves.easeOutCubic,
              builder: (_, t, __) => LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 5,
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < _data.length; i++)
                          FlSpot(i.toDouble(), _data[i] * t),
                      ],
                      isCurved: true,
                      color: AppTheme.statusSuccess,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.statusSuccess.withValues(alpha: 0.25),
                            AppTheme.statusSuccess.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: AppTheme.poppins(
              fontSize: 18,
              weight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.brandPrimary,
              minimumSize: const Size(48, 40),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  action!,
                  style: AppTheme.inter(
                    fontSize: 13,
                    weight: FontWeight.w600,
                    color: AppTheme.brandPrimary,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}

class _PestAlert extends StatelessWidget {
  final VoidCallback onTap;
  const _PestAlert({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const c = AppTheme.statusWarning;
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Peringatan hama',
      scale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c.withValues(alpha: 0.16), c.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: c,
                    size: 28,
                  ),
                ),
                const Positioned(
                  top: -7,
                  right: -7,
                  child: PulseDot(color: AppTheme.statusDanger, size: 7),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Peringatan Hama',
                    style: AppTheme.poppins(
                      fontSize: 14,
                      weight: FontWeight.w700,
                      color: const Color(0xFFB87A1F),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Hawar daun terdeteksi di kabupaten Anda. Segera periksa lahan.',
                    style: AppTheme.inter(
                      fontSize: 13,
                      color: AppTheme.textDark,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
          ],
        ),
      ),
    );
  }
}
