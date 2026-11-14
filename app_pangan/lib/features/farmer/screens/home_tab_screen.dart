import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/go_pay_theme.dart';
import '../../../core/widgets/favorite_slot.dart';
import '../../../core/widgets/menu_grid_item.dart';
import '../../../core/widgets/menu_panel.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../core/widgets/promo_card.dart';
import '../../../features/auth/auth_provider.dart';

/// Beranda (Home Tab) — GoPay style redesign dengan struktur anti-overflow
class HomeTabScreen extends ConsumerStatefulWidget {
  const HomeTabScreen({super.key});

  @override
  ConsumerState<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends ConsumerState<HomeTabScreen> {
  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final userName = auth.user?.name ?? 'Bapak Sugianto';
    final greeting = _greeting();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaler.scale(1.0).clamp(1.0, 1.15),
        ),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: GoPayColors().bgCream,
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            color: GoPayColors().brandPrimary,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header section - Container tanpa height, hanya padding
                  _headerSection(userName: userName, greeting: greeting),

                  // MenuPanel overlapping header
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: _buildMenuPanel(),
                  ),

                  // Pill Chips horizontal scroll - tinggi mengikuti konten
                  _buildPillChips(),

                  // Favorite Slots bar
                  _buildFavoriteSlots(),

                  // "Spesial buat petani" section - tinggi mengikuti konten
                  _buildSpecialSection(),

                  // Bottom nav clearance
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// HeaderSection: Container gradient tanpa height, hanya padding
  Widget _headerSection({required String userName, required String greeting}) {
    final color = GoPayColors();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.brandPrimary, color.brandSecondary],
          stops: const [0.0, 0.6],
        ),
      ),
      child: Stack(
        children: [
          // Subtle texture overlay
          Positioned.fill(
            child: CustomPaint(painter: _HeaderPatternPainter()),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top row: Greeting + Help/Notification buttons
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$greeting,',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // Season chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.eco_rounded, size: 13, color: Colors.white),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          'Musim Tanam 2026 — Cabai',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Help & Notification buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _HeaderActionButton(
                                icon: Icons.help_outline_rounded,
                                onTap: () => Navigator.pushNamed(context, '/guide'),
                              ),
                              const SizedBox(width: 8),
                              _HeaderActionButton(
                                icon: Icons.notifications_none_rounded,
                                showDot: true,
                                onTap: () => Navigator.pushNamed(context, '/notifications'),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Profit Summary
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total Laba Bulan Ini',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // Angka dengan FittedBox supaya tidak overflow
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Rp 12.500.000',
                                    style: GoogleFonts.inter(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color.statusSuccess.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.arrow_upward_rounded, size: 12, color: color.statusSuccess),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                '+15.3% dari bulan lalu',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: color.statusSuccess,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Decorative icon - use Flexible to prevent overflow
                          Flexible(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.trending_up_rounded,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Expense row (tappable -> Keuangan)
                      _ExpenseRow(
                        amount: 'Rp 9.750.000',
                        label: 'pengeluaran bulan ini',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pushNamed(context, '/finance');
                        },
                      ),

                      const SizedBox(height: 20),

                      // Action buttons: Catat Panen & Jual Hasil - use Flexible with flex: 1
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: _HeaderActionButtonLarge(
                              label: 'Catat Panen',
                              icon: Icons.add_rounded,
                              color: Colors.white,
                              textColor: color.brandPrimary,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pushNamed(context, '/production');
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            flex: 1,
                            child: _HeaderActionButtonLarge(
                              label: 'Jual Hasil',
                              icon: Icons.sell_rounded,
                              color: Colors.white.withValues(alpha: 0.15),
                              textColor: Colors.white,
                              borderColor: Colors.white.withValues(alpha: 0.3),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pushNamed(context, '/sell');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Menu Panel - GoPay style dengan GridView rapi (4 kolom)
  Widget _buildMenuPanel() {
    final color = GoPayColors();

    // 8 item menu cepat akses dengan warna pastel masing-masing
    final items = [
      _MenuItemData(
        icon: Icons.add_circle_outline_rounded,
        label: 'Catat Panen',
        iconBgColor: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF2E7D32),
        badge: 'BARU',
        badgeColor: color.statusSuccess,
        onTap: () => Navigator.pushNamed(context, '/production'),
      ),
      _MenuItemData(
        icon: Icons.sell_outlined,
        label: 'Jual Hasil',
        iconBgColor: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFE65100),
        onTap: () => Navigator.pushNamed(context, '/sell'),
      ),
      _MenuItemData(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Keuangan',
        iconBgColor: const Color(0xFFFFE0B2),
        iconColor: const Color(0xFFEF6C00),
        onTap: () => Navigator.pushNamed(context, '/finance'),
      ),
      _MenuItemData(
        icon: Icons.menu_book_outlined,
        label: 'Panduan',
        iconBgColor: const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF1565C0),
        onTap: () => Navigator.pushNamed(context, '/guide'),
      ),
      _MenuItemData(
        icon: Icons.assessment_outlined,
        label: 'Laporan',
        iconBgColor: const Color(0xFFFCE4EC),
        iconColor: const Color(0xFFC2185B),
        onTap: () => Navigator.pushNamed(context, '/report'),
      ),
      _MenuItemData(
        icon: Icons.bar_chart_outlined,
        label: 'Harga',
        iconBgColor: const Color(0xFFF3E5F5),
        iconColor: const Color(0xFF7B1FA2),
        onTap: () => Navigator.pushNamed(context, '/market'),
      ),
      _MenuItemData(
        icon: Icons.storefront_outlined,
        label: 'Pasar',
        iconBgColor: const Color(0xFFE0F2F1),
        iconColor: const Color(0xFF00695C),
        onTap: () => Navigator.pushNamed(context, '/market'),
      ),
      _MenuItemData(
        icon: Icons.grid_view_rounded,
        label: 'Lainnya',
        iconBgColor: const Color(0xFFF5F5F5),
        iconColor: const Color(0xFF757575),
        onTap: () {},
      ),
    ];

    return MenuPanel(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      borderRadius: 28,
      children: [
        // Grid 4x2 rapi dengan GridView (bukan Wrap)
        SizedBox(
          height: 250,
          child: GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 14,
            childAspectRatio: 0.82,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: items.map((item) {
              return MenuGridItem(
                icon: item.icon,
                label: item.label,
                iconBgColor: item.iconBgColor,
                iconColor: item.iconColor,
                badge: item.badge,
                badgeColor: item.badgeColor,
                onTap: item.onTap,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Horizontal pill chips - butuh SizedBox height untuk horizontal ListView di SingleChildScrollView
  Widget _buildPillChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 56,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: [
            PillChip(
              label: 'Tersinkron',
              icon: Icons.cloud_done_rounded,
              trailing: 'ONLINE',
              isOnline: true,
              iconColor: GoPayColors().statusSuccess,
              onTap: () {},
            ),
            PillChip(
              label: 'Peringatan Hama',
              icon: Icons.bug_report_rounded,
              trailing: '1 aktif >',
              iconColor: GoPayColors().statusWarning,
              onTap: () {},
            ),
            PillChip(
              label: 'Harga naik hari ini',
              icon: Icons.trending_up_rounded,
              trailing: 'Lihat >',
              iconColor: GoPayColors().brandPrimary,
              onTap: () => Navigator.pushNamed(context, '/market'),
            ),
          ],
        ),
      ),
    );
  }

  /// Favorite slots bar
  Widget _buildFavoriteSlots() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GoPayColors().surfaceWhite,
        borderRadius: BorderRadius.circular(GoPayRadius.pill),
        border: Border.all(color: GoPayColors().dividerLight, width: 0.5),
        boxShadow: [GoPayShadows.cardShadow()],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FavoriteSlot(
            icon: Icons.grass_rounded,
            label: 'Cabai Merah',
            onTap: () {},
          ),
          FavoriteSlot(
            icon: Icons.grain_rounded,
            label: 'Lahan Utara',
            onTap: () {},
          ),
          FavoriteSlot(
            icon: Icons.add_circle_outline_rounded,
            label: '',
            hasPlus: true,
            onTap: () {},
          ),
          FavoriteSlot(
            icon: Icons.more_horiz_rounded,
            label: 'Lainnya',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// "Spesial buat petani" horizontal scroll - tinggi auto
  Widget _buildSpecialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Spesial buat petani',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: GoPayColors().textDark,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              PromoCard(
                title: 'Cabai Merah',
                subtitle: 'Rp 45.000/kg • Stok 120 kg',
                icon: Icons.local_fire_department_rounded,
                badgeColor: GoPayColors().brandAccent,
                onTap: () {},
              ),
              PromoCard(
                title: 'Peringatan Hama',
                subtitle: 'Ulat Grayak • Lahan Utara',
                icon: Icons.bug_report_rounded,
                badgeColor: GoPayColors().statusWarning,
                onTap: () {},
              ),
              PromoCard(
                title: 'Tips Budidaya',
                subtitle: 'Cara panen cabai optimal',
                icon: Icons.lightbulb_outline_rounded,
                badgeColor: GoPayColors().brandSecondary,
                onTap: () => Navigator.pushNamed(context, '/guide'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Data untuk item menu dengan warna pastel
class _MenuItemData {
  final IconData icon;
  final String label;
  final Color iconBgColor;
  final Color iconColor;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.iconBgColor,
    required this.iconColor,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });
}

/// Header action button (help, notification)
class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final bool showDot;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    this.showDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              if (showDot)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: GoPayColors().brandSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
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

/// Large action button in header (Catat Panen, Jual Hasil)
class _HeaderActionButtonLarge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _HeaderActionButtonLarge({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: textColor.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
            boxShadow: [
              BoxShadow(
                color: textColor.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expense row (tappable to Keuangan)
class _ExpenseRow extends StatelessWidget {
  final String amount;
  final String label;
  final VoidCallback onTap;

  const _ExpenseRow({
    required this.amount,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.wallet_outlined, size: 20, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      amount,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.6), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// Subtle pattern painter for header
class _HeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    const double spacing = 36;
    const double dotSize = 2;

    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        final offsetX = (y ~/ spacing) % 2 == 0 ? 0 : spacing / 2;
        canvas.drawCircle(Offset(x + offsetX, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}