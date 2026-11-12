import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_card.dart';
import '../../../core/widgets/p_chip_badge.dart';
import '../../../core/widgets/p_states.dart';
import '../../farmer/screens/settings_screen.dart';

class ConsumerHome extends ConsumerStatefulWidget {
  const ConsumerHome({super.key});

  @override
  ConsumerState<ConsumerHome> createState() => _ConsumerHomeState();
}

class _ConsumerHomeState extends ConsumerState<ConsumerHome> {
  int _cat = 0;

  static const _categories = [
    ('Beras', Icons.grain_rounded),
    ('Sayuran', Icons.eco_rounded),
    ('Buah', Icons.apple),
    ('Daging', Icons.kebab_dining),
    ('Ikan', Icons.set_meal),
  ];

  static const _items = [
    ('Cabai Merah', 'Rp 45.000 / kg', 'Sisa 25 kg', 'Sayuran', Icons.local_fire_department_rounded, AppTheme.statusDanger),
    ('Bawang Merah', 'Rp 32.000 / kg', 'Sisa 60 kg', 'Bumbu', Icons.spa_rounded, Color(0xFFB0539A)),
    ('Beras Premium', 'Rp 12.500 / kg', 'Sisa 200 kg', 'Pangan Pokok', Icons.grain_rounded, Color(0xFFD99A1E)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            // ── Judul + pencarian ──────────────────────────────────────
            EntranceAnimation(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.brandPrimary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('Pangan segar dari petani lokal',
                            style: AppTheme.inter(fontSize: 13, weight: FontWeight.w500, color: AppTheme.neutral400)),
                      ),
                      IconButton(
                        tooltip: 'Pengaturan',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                        icon: const Icon(Icons.settings_rounded, color: AppTheme.brandPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Mau masak apa\nhari ini?',
                      style: AppTheme.poppins(fontSize: 28, weight: FontWeight.w700, color: AppTheme.textDark, height: 1.2)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            EntranceAnimation(
              delay: const Delay(80),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppTheme.softShadow(0.07),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari pangan pokok...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.tune_rounded, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Kategori ───────────────────────────────────────────────
            const SizedBox(height: 22),
            EntranceAnimation(delay: const Delay(140), child: _title('Kategori')),
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => EntranceAnimation(
                  delay: Delay(180 + i * 60),
                  offset: const Offset(0.3, 0),
                  child: PFilterChip(
                    label: _categories[i].$1,
                    icon: _categories[i].$2,
                    selected: _cat == i,
                    onTap: () => setState(() => _cat = i),
                  ),
                ),
              ),
            ),

            // ── Tersedia dekat kamu ────────────────────────────────────
            const SizedBox(height: 26),
            EntranceAnimation(delay: const Delay(300), child: _title('Tersedia dekat kamu')),
            const SizedBox(height: 12),
            for (var i = 0; i < _items.length; i++) ...[
              EntranceAnimation(
                delay: Delay(340 + i * 90),
                child: PCommodityCard(
                  horizontal: true,
                  name: _items[i].$1,
                  price: _items[i].$2,
                  stock: _items[i].$3,
                  category: _items[i].$4,
                  icon: _items[i].$5,
                  tint: _items[i].$6,
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Hemat ──────────────────────────────────────────────────
            const SizedBox(height: 8),
            const EntranceAnimation(delay: Delay(620), scaleFrom: 0.96, child: _SavingsCard()),

            // ── Resep ──────────────────────────────────────────────────
            const SizedBox(height: 28),
            EntranceAnimation(delay: const Delay(700), child: _title('Rekomendasi Resep')),
            const SizedBox(height: 4),
            Container(
              decoration: AppTheme.cardDecoration(radius: 24),
              child: const PEmptyState(
                icon: Icons.restaurant_menu_rounded,
                title: 'Belum ada rekomendasi resep',
                subtitle: 'Tambah bahan di Stok Dapur untuk dapat saran resep.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String t) => Text(
        t,
        style: AppTheme.poppins(fontSize: 17, weight: FontWeight.w700, color: AppTheme.textDark),
      );
}

class _SavingsCard extends StatelessWidget {
  const _SavingsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppTheme.glow(AppTheme.brandPrimary),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Floating(
              child: Icon(Icons.savings_rounded, size: 96, color: Colors.white.withValues(alpha: 0.14)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hemat vs Pasar Konvensional',
                  style: AppTheme.inter(fontSize: 13, weight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.85))),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedCounter(
                    value: 12,
                    suffix: '%',
                    style: tabularNumber(fontSize: 44, weight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_down_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('lebih murah',
                            style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
