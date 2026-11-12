import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_card.dart';
import '../../../core/widgets/p_states.dart';
import '../../auth/auth_provider.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});
  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selected = 0;
  bool _dark = false;

  static const List<(String, IconData)> _items = [
    ('Ringkasan Nasional', Icons.dashboard_rounded),
    ('Peta Panas', Icons.map_rounded),
    ('Monitoring Harga', Icons.attach_money_rounded),
    ('Early Warning', Icons.warning_amber_rounded),
    ('Intervensi', Icons.sync_alt_rounded),
    ('Supply-Demand', Icons.compare_arrows_rounded),
    ('Analitik', Icons.assessment_rounded),
    ('Pengguna', Icons.people_alt_rounded),
  ];

  // Warna mengikuti mode (komponen berbasis Theme otomatis ikut)
  Color get _surface => _dark ? AppTheme.darkSurface : AppTheme.surface;
  Color get _text => _dark ? AppTheme.darkText : AppTheme.textDark;
  Color get _muted => _dark ? AppTheme.darkMuted : AppTheme.neutral500;
  Color get _primary => _dark ? AppTheme.brandPrimaryLight : AppTheme.brandPrimary;
  Color get _border => _dark ? AppTheme.darkBorder : AppTheme.neutral200.withValues(alpha: 0.6);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 900;
    return AnimatedTheme(
      data: _dark ? AppTheme.darkTheme() : AppTheme.lightTheme(context),
      duration: const Duration(milliseconds: 350),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: wide ? null : Drawer(width: 280, backgroundColor: _surface, child: _sidebarBody(inDrawer: true)),
        body: Row(
          children: [
            if (wide)
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 264,
                decoration: BoxDecoration(
                  color: _surface,
                  border: Border(right: BorderSide(color: _border)),
                ),
                child: _sidebarBody(inDrawer: false),
              ),
            Expanded(
              child: Column(
                children: [
                  _topBar(wide),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(anim),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(key: ValueKey(_selected), child: _content()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sidebar ────────────────────────────────────────────────────────────
  Widget _sidebarBody({required bool inDrawer}) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: AppTheme.glow(AppTheme.brandPrimary),
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PanganKu', style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w700, color: _primary, height: 1.1)),
                    Text('Panel Nasional', style: AppTheme.inter(fontSize: 11, color: _muted)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [for (var i = 0; i < _items.length; i++) _item(i, inDrawer)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              decoration: BoxDecoration(
                color: _dark ? AppTheme.darkBg : AppTheme.neutral100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text('Mode Gelap', style: AppTheme.inter(fontSize: 13, weight: FontWeight.w600, color: _text)),
                value: _dark,
                onChanged: (v) => setState(() => _dark = v),
                secondary: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (c, a) => RotationTransition(turns: Tween<double>(begin: 0.75, end: 1).animate(a), child: FadeTransition(opacity: a, child: c)),
                  child: Icon(
                    _dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    key: ValueKey(_dark),
                    color: _dark ? AppTheme.brandSecondary : AppTheme.brandAccent,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (_) => false);
                },
                icon: Icon(Icons.logout_rounded, color: AppTheme.statusDanger),
                label: Text('Keluar Akun',
                    style: AppTheme.inter(
                        fontSize: 13,
                        weight: FontWeight.w600,
                        color: AppTheme.statusDanger)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppTheme.statusDanger.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(int i, bool inDrawer) {
    final sel = _selected == i;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() => _selected = i);
            if (inDrawer) Navigator.of(context).pop();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: sel ? _primary.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: 4,
                  height: sel ? 20 : 0,
                  decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(4)),
                ),
                SizedBox(width: sel ? 10 : 6),
                Icon(_items[i].$2, size: 22, color: sel ? _primary : _muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _items[i].$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.inter(
                      fontSize: 14,
                      weight: sel ? FontWeight.w600 : FontWeight.w500,
                      color: sel ? _primary : _text,
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

  // ── Top bar ────────────────────────────────────────────────────────────
  Widget _topBar(bool wide) {
    final showUpdated = MediaQuery.of(context).size.width > 600;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (!wide) ...[
              IconButton(
                icon: Icon(Icons.menu_rounded, color: _text),
                tooltip: 'Menu',
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              const SizedBox(width: 4),
            ],
            Icon(Icons.place_rounded, size: 18, color: _primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Nasional  ›  Jawa Barat  ›  Bandung',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.inter(fontSize: 14, weight: FontWeight.w500, color: _text),
              ),
            ),
            if (showUpdated) ...[
              Text('Diperbarui 2 menit lalu', style: AppTheme.inter(fontSize: 13, color: _muted)),
              const SizedBox(width: 6),
            ],
            const PulseDot(color: AppTheme.statusSuccess, size: 7),
          ],
        ),
      ),
    );
  }

  // ── Konten ─────────────────────────────────────────────────────────────
  Widget _content() {
    switch (_selected) {
      case 0:
        return _ringkasan();
      default:
        return _placeholder(_items[_selected].$1, 'Layar ${_items[_selected].$1} — siap diimplementasi.');
    }
  }

  Widget _ringkasan() {
    const stats = [
      ('Indeks Stabilitas', '78', '+3%', true, Icons.trending_up_rounded),
      ('Harga Strategis', 'Rp 14.200', '-1%', true, Icons.attach_money_rounded),
      ('Stok Nasional', '1.240 ton', '+5%', true, Icons.inventory_2_rounded),
      ('Wilayah Waspada', '3', '2 baru', false, Icons.warning_amber_rounded),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EntranceAnimation(
            child: Text('Ringkasan Nasional', style: AppTheme.poppins(fontSize: 24, weight: FontWeight.w700, color: _text)),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, c) {
              const gap = 16.0;
              final cols = c.maxWidth >= 1000 ? 4 : (c.maxWidth >= 560 ? 2 : 1);
              final w = (c.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var i = 0; i < stats.length; i++)
                    SizedBox(
                      width: w,
                      child: EntranceAnimation(
                        delay: Delay(100 + i * 90),
                        scaleFrom: 0.94,
                        child: PStatCard(
                          title: stats[i].$1,
                          value: stats[i].$2,
                          delta: stats[i].$3,
                          deltaPositive: stats[i].$4,
                          icon: stats[i].$5,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          EntranceAnimation(
            delay: const Delay(480),
            child: Text('Pembaruan Real-Time', style: AppTheme.poppins(fontSize: 17, weight: FontWeight.w600, color: _text)),
          ),
          const SizedBox(height: 12),
          EntranceAnimation(
            delay: const Delay(540),
            child: _SkeletonChartCard(
              surface: _surface,
              border: _border,
              text: _text,
              muted: _muted,
              title: 'Grafik tren harga akan ditampilkan di sini',
              subtitle: 'Integrasikan WebSocket/SSE.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(String title, String subtitle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EntranceAnimation(
            child: Text(title, style: AppTheme.poppins(fontSize: 22, weight: FontWeight.w700, color: _text)),
          ),
          const SizedBox(height: 16),
          EntranceAnimation(
            delay: const Delay(100),
            child: Container(
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _border),
              ),
              child: PEmptyState(icon: Icons.construction_rounded, title: title, subtitle: subtitle),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder grafik: kartu dengan skeleton shimmer + keterangan.
class _SkeletonChartCard extends StatelessWidget {
  final Color surface, border, text, muted;
  final String title, subtitle;

  const _SkeletonChartCard({
    required this.surface,
    required this.border,
    required this.text,
    required this.muted,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: PSkeleton(height: 90, borderRadius: BorderRadius.all(Radius.circular(10)))),
              SizedBox(width: 10),
              Expanded(child: PSkeleton(height: 140, borderRadius: BorderRadius.all(Radius.circular(10)))),
              SizedBox(width: 10),
              Expanded(child: PSkeleton(height: 70, borderRadius: BorderRadius.all(Radius.circular(10)))),
              SizedBox(width: 10),
              Expanded(child: PSkeleton(height: 120, borderRadius: BorderRadius.all(Radius.circular(10)))),
              SizedBox(width: 10),
              Expanded(child: PSkeleton(height: 100, borderRadius: BorderRadius.all(Radius.circular(10)))),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart_rounded, size: 20, color: muted),
              const SizedBox(width: 8),
              Flexible(
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: AppTheme.poppins(fontSize: 14, weight: FontWeight.w600, color: text)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTheme.inter(fontSize: 13, color: muted)),
        ],
      ),
    );
  }
}

/// Dipertahankan agar import lama tetap valid.
class PEmptyStateSimple extends StatelessWidget {
  final String title;
  final String subtitle;
  const PEmptyStateSimple({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) =>
      PEmptyState(icon: Icons.show_chart_rounded, title: title, subtitle: subtitle);
}
