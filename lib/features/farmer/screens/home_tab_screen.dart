import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_connection_banner.dart';
import '../../../core/widgets/pangan_sliver_header.dart';
import '../../../features/auth/auth_provider.dart';

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
    Navigator.of(context).pushNamed('/production');
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

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final userName = auth.user?.name ?? 'Petani';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.brandPrimary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              PanganSliverHeaderSimple(
                expandedHeight: 140,
                collapsedTitle: userName,
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
                            const SizedBox(height: 4),
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
                                  Flexible(
                                    child: Text(
                                      'Musim Tanam 2026 — Cabai',
                                      style: AppTheme.inter(
                                        fontSize: 11,
                                        weight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
                          Navigator.of(context).pushNamed('/notifications');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: EntranceAnimation(
                                delay: Delay(40),
                                child: PConnectionBanner(state: PSyncState.synced),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: EntranceAnimation(
                                delay: Delay(80),
                                scaleFrom: 0.96,
                                child: _ProfitHero(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: EntranceAnimation(
                                delay: const Delay(60),
                                child: _SectionHeader(
                                  title: 'Harga Komoditas Hari Ini',
                                  action: 'Lihat semua',
                                  onAction: () => _navigateToPriceTab(context),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 170,
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
                                      top: 6,
                                      bottom: 6,
                                    ),
                                    child: EntranceAnimation(
                                      delay: Delay(150 + index * 50),
                                      offset: const Offset(0.15, 0),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: EntranceAnimation(
                                delay: const Delay(100),
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
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: EntranceAnimation(
                                delay: const Delay(100),
                                child: const _SectionHeader(title: 'Cepat Akses'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const _BigButtonGrid(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showDot;
  final VoidCallback onTap;

  const _NotificationButton({
    required this.icon,
    required this.label,
    required this.showDot,
    required this.onTap,
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
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withValues(alpha: 0.12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                if (showDot)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.brandAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
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

class _ProfitHero extends StatelessWidget {
  const _ProfitHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.brandPrimary, AppTheme.brandPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.glow(AppTheme.brandPrimary),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Laba Bulan Ini',
                  style: AppTheme.inter(
                    fontSize: 13,
                    weight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp 12.500.000',
                  style: AppTheme.poppins(
                    fontSize: 26,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '▲ +15.3% dari bulan lalu',
                        style: AppTheme.inter(
                          fontSize: 11,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _PestAlert extends StatelessWidget {
  final VoidCallback onTap;

  const _PestAlert({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Peringatan hama Ulat Grayak terdeteksi di area Cabai Merah',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppTheme.brandAccent.withValues(alpha: 0.12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.brandAccentSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.brandAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.brandAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bug_report_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Peringatan Hama: Ulat Grayak', style: AppTheme.poppins(fontSize: 13, weight: FontWeight.w600, color: AppTheme.textDark)),
                      const SizedBox(height: 2),
                      Text('Terdeteksi di area Cabai Merah lahan Utara', style: AppTheme.inter(fontSize: 11, color: AppTheme.neutral500)),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w700, color: AppTheme.textDark)),
        const Spacer(),
        if (action != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.brandPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(action!, style: AppTheme.inter(fontSize: 13, weight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _CommodityCard extends StatelessWidget {
  final String name;
  final String price;
  final String stock;
  final String category;
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
          borderRadius: BorderRadius.circular(16),
          splashColor: tint.withValues(alpha: 0.12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.neutral200),
              boxShadow: AppTheme.softShadow(0.03),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: tint.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: tint, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        style: AppTheme.poppins(fontSize: 14, weight: FontWeight.w600, color: AppTheme.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tint.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: AppTheme.inter(fontSize: 10, weight: FontWeight.w600, color: tint),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  price,
                  style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w700, color: AppTheme.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stok: $stock',
                  style: AppTheme.inter(fontSize: 11, color: AppTheme.neutral500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BigButtonGrid extends StatelessWidget {
  const _BigButtonGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      _BigButtonItem(
        icon: Icons.add_circle_outline_rounded,
        label: 'Catat Panen',
        color: AppTheme.brandPrimary,
        onTap: () => Navigator.pushNamed(context, '/production'),
      ),
      _BigButtonItem(
        icon: Icons.sell_outlined,
        label: 'Jual Hasil',
        color: AppTheme.brandSecondary,
        onTap: () => Navigator.pushNamed(context, '/sell'),
      ),
      _BigButtonItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Keuangan',
        color: AppTheme.brandAccent,
        onTap: () => Navigator.pushNamed(context, '/finance'),
      ),
      _BigButtonItem(
        icon: Icons.storefront_outlined,
        label: 'Pasar',
        color: const Color(0xFF2196F3),
        onTap: () => Navigator.pushNamed(context, '/market'),
      ),
      _BigButtonItem(
        icon: Icons.notifications_outlined,
        label: 'Pantauan',
        color: const Color(0xFF9C27B0),
        onTap: () => Navigator.pushNamed(context, '/monitoring'),
      ),
      _BigButtonItem(
        icon: Icons.menu_book_outlined,
        label: 'Panduan',
        color: const Color(0xFF00BCD4),
        onTap: () => Navigator.pushNamed(context, '/guide'),
      ),
      _BigButtonItem(
        icon: Icons.assessment_outlined,
        label: 'Laporan',
        color: const Color(0xFFE91E63),
        onTap: () => Navigator.pushNamed(context, '/report'),
      ),
      _BigButtonItem(
        icon: Icons.settings_outlined,
        label: 'Pengaturan',
        color: AppTheme.neutral400,
        onTap: () => Navigator.pushNamed(context, '/settings'),
      ),
    ];

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, index) => _BigButton(item: items[index]),
      ),
    );
  }
}

class _BigButtonItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BigButtonItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _BigButton extends StatelessWidget {
  final _BigButtonItem item;

  const _BigButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: item.label,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: item.color.withValues(alpha: 0.12),
          child: Container(
            width: 120,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.neutral200),
              boxShadow: AppTheme.softShadow(0.03),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: AppTheme.poppins(fontSize: 11, weight: FontWeight.w600, color: AppTheme.textDark),
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
  final String name;
  final String price;
  final String stock;
  final String category;
  final IconData icon;
  final Color tint;

  const _Commodity({
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.icon,
    required this.tint,
  });
}

final List<_Commodity> _commodities = [
  _Commodity(name: 'Cabai Merah', price: 'Rp 45.000/kg', stock: '120 kg', category: 'Sayuran', icon: Icons.local_fire_department_rounded, tint: AppTheme.brandAccent),
  _Commodity(name: 'Bawang Merah', price: 'Rp 32.000/kg', stock: '200 kg', category: 'Bumbu', icon: Icons.food_bank_rounded, tint: AppTheme.brandSecondary),
  _Commodity(name: 'Beras', price: 'Rp 12.500/kg', stock: '500 kg', category: 'Pangan Pokok', icon: Icons.grain_rounded, tint: AppTheme.brandPrimary),
  _Commodity(name: 'Jagung', price: 'Rp 6.500/kg', stock: '300 kg', category: 'Pangan Pokok', icon: Icons.grass_rounded, tint: const Color(0xFF2196F3)),
  _Commodity(name: 'Tomat', price: 'Rp 18.000/kg', stock: '80 kg', category: 'Sayuran', icon: Icons.apple_rounded, tint: const Color(0xFFE91E63)),
];