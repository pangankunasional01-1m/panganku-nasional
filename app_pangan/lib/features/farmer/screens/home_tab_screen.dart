import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_button.dart';
import '../../../core/widgets/p_chip_badge.dart';
import '../../../core/widgets/p_connection_banner.dart';
import '../../../core/widgets/pangan_sliver_header.dart';
import 'ai_expert_screen.dart';
import 'planting_guide_screen.dart';
import 'production_screen.dart';
import 'report_screen.dart';
import 'finance_screen.dart';

/// Beranda (Home Tab) — ringkasan harga hari ini, laba/rugi, dan akses cepat
class HomeTabScreen extends ConsumerStatefulWidget {
  const HomeTabScreen({super.key});

  @override
  ConsumerState<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends ConsumerState<HomeTabScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  void _navigateToPriceTab(BuildContext context) {
    HapticFeedback.lightImpact();
    // Navigate to PriceTabScreen (index 1 in MainNavScreen)
    // This would require a callback or using a global navigator key
    // For now, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Buka tab Harga untuk melihat semua komoditas'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _onCommodityTap(BuildContext context, _Commodity commodity) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detail ${commodity.name} — segera hadir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.bgCream,
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.brandPrimary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              PanganSliverHeaderSimple(
                expandedHeight: 190,
                collapsedTitle: 'Bapak Sugianto',
                expandedContent: EntranceAnimation(
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
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
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
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.28),
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
                      _NotificationButton(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notifikasi',
                        showDot: true,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifikasi — segera hadir'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: EntranceAnimation(
                        delay: Delay(80),
                        child: PConnectionBanner(state: PSyncState.synced),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: EntranceAnimation(
                        delay: Delay(160),
                        scaleFrom: 0.96,
                        child: _ProfitHero(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    EntranceAnimation(
                      delay: const Delay(240),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _SectionHeader(
                          title: 'Harga Komoditas Hari Ini',
                          action: 'Lihat semua',
                          onAction: () => _navigateToPriceTab(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // PageView with snap for horizontal scroll
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const PageScrollPhysics(),
                        onPageChanged: (page) {
                          setState(() => _currentPage = page);
                          HapticFeedback.selectionClick();
                        },
                        itemCount: _commodities.length,
                        itemBuilder: (context, index) {
                          final c = _commodities[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 ? 20 : 6,
                              right: index == _commodities.length - 1 ? 20 : 6,
                              top: 10,
                              bottom: 10,
                            ),
                            child: EntranceAnimation(
                              delay: Delay(300 + index * 90),
                              offset: const Offset(0.25, 0),
                              child: _CommodityCard(
                                name: c.name,
                                price: c.price,
                                stock: c.stock,
                                category: c.category,
                                icon: c.icon,
                                tint: c.tint,
                                onTap: () => _onCommodityTap(context, c),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Page indicator dots
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_commodities.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppTheme.brandPrimary
                                  : AppTheme.neutral300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Peringatan hama ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EntranceAnimation(
                        delay: const Delay(380),
                        child: _PestAlert(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Detail peringatan — segera hadir'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
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
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    // Simulate refresh
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() {});
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
    _Commodity(
      'Cabai',
      'Rp 45.000 / kg',
      'Tersedia 50 kg',
      'Sayuran',
      Icons.local_fire_department_rounded,
      AppTheme.brandAccent,
    ),
  ];

  Widget _bigButtonGrid(BuildContext context) {
    final items = <_QuickAction>[
      _QuickAction(
        icon: Icons.payments_rounded,
        label: 'Catat Biaya',
        color: AppTheme.brandPrimary,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, '/finance');
        },
      ),
      _QuickAction(
        icon: Icons.inventory_2_rounded,
        label: 'Hasil Produksi',
        color: AppTheme.brandPrimary,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductionScreen()),
          );
        },
      ),
      _QuickAction(
        icon: Icons.shopping_cart_rounded,
        label: 'Jual',
        color: AppTheme.brandPrimary,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, '/sell');
        },
      ),
      _QuickAction(
        icon: Icons.smart_toy_rounded,
        label: 'Tanya Pakar AI',
        color: AppTheme.brandAccent,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiExpertScreen()),
          );
        },
      ),
      _QuickAction(
        icon: Icons.menu_book_rounded,
        label: 'Panduan Tanam',
        color: AppTheme.brandPrimary,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlantingGuideScreen()),
          );
        },
      ),
      _QuickAction(
        icon: Icons.description_rounded,
        label: 'Laporan',
        color: AppTheme.brandPrimary,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportScreen()),
          );
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        // 2 columns instead of 3 for larger touch targets
        final w = (constraints.maxWidth - gap) / 2;
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
                  child: _QuickActionButton(action: items[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: action.label,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: action.color.withValues(alpha: 0.12),
          highlightColor: action.color.withValues(alpha: 0.08),
          child: Container(
            // Minimum 112dp height for better touch target
            constraints: const BoxConstraints(minHeight: 112),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
            decoration: AppTheme.cardDecoration(radius: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        action.color.withValues(alpha: 0.20),
                        action.color.withValues(alpha: 0.07),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(action.icon, size: 28, color: action.color),
                ),
                const SizedBox(height: 12),
                Text(
                  action.label,
                  style: AppTheme.inter(
                    fontSize: 13,
                    weight: FontWeight.w600,
                    color: AppTheme.textDark,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
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
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.2),
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
        ),
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
    return Semantics(
      label: 'Peringatan hama, Hawar daun terdeteksi di kabupaten Anda',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: c.withValues(alpha: 0.12),
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
        ),
      ),
    );
  }
}

// ── Kartu komoditas ─────────────────────────────────────────────────────────
class _CommodityCard extends StatelessWidget {
  final String name, price, stock, category;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  const _CommodityCard({
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$name, harga $price, stok $stock',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: tint.withValues(alpha: 0.12),
          child: Container(
            width: 166,
            padding: const EdgeInsets.all(14),
            decoration: AppTheme.cardDecoration(
              radius: 20,
              shadows: AppTheme.softShadow(0.08),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: tint, size: 22),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTheme.poppins(
                              fontSize: 15,
                              weight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          _CategoryChip(category: category),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  price,
                  style: tabularNumber(
                    fontSize: 18,
                    weight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stock,
                  style: AppTheme.inter(
                    fontSize: 11,
                    color: AppTheme.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    switch (category) {
      case 'Pangan Pokok':
        bgColor = AppTheme.brandPrimarySoft;
        textColor = AppTheme.brandPrimary;
        break;
      case 'Sayuran':
        bgColor = AppTheme.brandAccentSoft;
        textColor = AppTheme.brandAccent;
        break;
      default:
        bgColor = AppTheme.neutral100;
        textColor = AppTheme.neutral500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: AppTheme.inter(
          fontSize: 10,
          weight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}