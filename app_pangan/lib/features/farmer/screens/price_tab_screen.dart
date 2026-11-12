import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_chip_badge.dart';
import '../../../core/widgets/pangan_sliver_header.dart';

/// Harga (Price Tab) — daftar komoditas beserta tren harga
class PriceTabScreen extends ConsumerStatefulWidget {
  const PriceTabScreen({super.key});

  @override
  ConsumerState<PriceTabScreen> createState() => _PriceTabScreenState();
}

class _PriceTabScreenState extends ConsumerState<PriceTabScreen> {
  _PriceCategory _selectedCategory = _PriceCategory.all;
  bool _isLoading = true;
  String? _error;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCommodities = _selectedCategory == _PriceCategory.all
        ? _commodities
        : _commodities.where((c) => c.category == _selectedCategory.label).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.brandPrimary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            PanganSliverHeader(
              expandedHeight: 120,
              collapsedTitle: 'Harga Komoditas',
              bottomHeight: 72,
              bottom: _FilterChips(
                selectedCategory: _selectedCategory,
                onCategoryChanged: (cat) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = cat);
                },
              ),
              expandedContent: SafeArea(
                bottom: false,
                child: Text(
                  'Harga Komoditas',
                  style: AppTheme.poppins(
                    fontSize: 24,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (_isOffline)
              SliverToBoxAdapter(
                child: _OfflineBanner(
                  onDismiss: () => setState(() => _isOffline = false),
                ),
              ),
            if (_isLoading)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList.separated(
                  itemCount: 5,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, __) => const _PriceCardSkeleton(),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(
                  message: _error!,
                  onRetry: _onRefresh,
                ),
              )
            else if (filteredCommodities.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  title: 'Tidak ada data',
                  message: 'Belum ada harga untuk kategori ini',
                  actionLabel: 'Muat Ulang',
                  onAction: _onRefresh,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList.separated(
                  itemCount: filteredCommodities.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = filteredCommodities[index];
                    return EntranceAnimation(
                      delay: Delay(100 + index * 60),
                      offset: const Offset(0, 0.15),
                      child: _PriceCard(
                        commodity: c,
                        onTap: () => _navigateToDetail(context, c),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, _CommodityPrice commodity) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to CommodityDetailScreen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detail ${commodity.name} — segera hadir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

enum _PriceCategory {
  all('Semua'),
  panganPokok('Pangan Pokok'),
  sayuran('Sayuran'),
  protein('Protein'),
  bahanPokok('Bahan Pokok');

  final String label;
  const _PriceCategory(this.label);

  Color get color {
    switch (this) {
      case _PriceCategory.panganPokok:
        return AppTheme.brandPrimary;
      case _PriceCategory.sayuran:
        return AppTheme.brandAccent;
      case _PriceCategory.protein:
        return const Color(0xFF2196F3); // Blue
      case _PriceCategory.bahanPokok:
        return const Color(0xFF9C27B0); // Purple
      default:
        return AppTheme.neutral400;
    }
  }

  IconData get icon {
    switch (this) {
      case _PriceCategory.panganPokok:
        return Icons.grain_rounded;
      case _PriceCategory.sayuran:
        return Icons.eco_rounded;
      case _PriceCategory.protein:
        return Icons.egg_rounded;
      case _PriceCategory.bahanPokok:
        return Icons.local_grocery_store_rounded;
      default:
        return Icons.apps_rounded;
    }
  }
}

class _FilterChips extends StatelessWidget {
  final _PriceCategory selectedCategory;
  final ValueChanged<_PriceCategory> onCategoryChanged;

  const _FilterChips({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = _PriceCategory.values;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          return _FilterChip(
            label: cat.label,
            icon: cat.icon,
            color: cat.color,
            isSelected: isSelected,
            onTap: () => onCategoryChanged(cat),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label, ${isSelected ? "dipilih" : "tidak dipilih"}',
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.white.withValues(alpha: 0.2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? color : Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTheme.inter(
                    fontSize: 13,
                    weight: FontWeight.w600,
                    color: isSelected ? color : Colors.white.withValues(alpha: 0.9),
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

class _OfflineBanner extends StatelessWidget {
  final VoidCallback onDismiss;

  const _OfflineBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.statusWarning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.statusWarning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 18, color: AppTheme.statusWarning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mode offline — menampilkan data tersimpan',
              style: AppTheme.inter(
                fontSize: 13,
                weight: FontWeight.w500,
                color: AppTheme.statusWarning,
              ),
            ),
          ),
          TextButton(
            onPressed: onDismiss,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.statusWarning,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text('Tutup', style: AppTheme.inter(fontSize: 12, weight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _PriceCardSkeleton extends StatelessWidget {
  const _PriceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(
        radius: 16,
        shadows: AppTheme.softShadow(0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerBox(44, 44, 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(120, 20, 4),
                    const SizedBox(height: 4),
                    _shimmerBox(80, 14, 4),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _shimmerBox(80, 24, 4),
                  const SizedBox(height: 4),
                  _shimmerBox(60, 16, 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _shimmerBox(double.infinity, 40, 4),
          const SizedBox(height: 8),
          _shimmerBox(80, 20, 16),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height, double radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.neutral100,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.statusDanger.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 40, color: AppTheme.statusDanger),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat',
              style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w700, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral400),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text('Coba Lagi', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.brandPrimarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded, size: 48, color: AppTheme.brandPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w700, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral400),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(actionLabel, style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.brandPrimary,
                side: const BorderSide(color: AppTheme.brandPrimary, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommodityPrice {
  final String name;
  final String category;
  final String currentPrice;
  final String change;
  final bool isUp;
  final String unit;
  final String trend; // 'naik', 'turun', 'stabil'
  final List<double> sparkline;

  const _CommodityPrice({
    required this.name,
    required this.category,
    required this.currentPrice,
    required this.change,
    required this.isUp,
    required this.unit,
    required this.trend,
    required this.sparkline,
  });
}

const _commodities = <_CommodityPrice>[
  _CommodityPrice(
    name: 'Beras Premium',
    category: 'Pangan Pokok',
    currentPrice: 'Rp 12.500',
    change: '+2.4%',
    isUp: true,
    unit: '/kg',
    trend: 'naik',
    sparkline: [12000, 12100, 12200, 12300, 12400, 12500],
  ),
  _CommodityPrice(
    name: 'Beras Medium',
    category: 'Pangan Pokok',
    currentPrice: 'Rp 10.800',
    change: '+1.1%',
    isUp: true,
    unit: '/kg',
    trend: 'naik',
    sparkline: [10600, 10700, 10750, 10780, 10800, 10800],
  ),
  _CommodityPrice(
    name: 'Cabai Merah',
    category: 'Sayuran',
    currentPrice: 'Rp 45.000',
    change: '-5.1%',
    isUp: false,
    unit: '/kg',
    trend: 'turun',
    sparkline: [48000, 47500, 47000, 46500, 45500, 45000],
  ),
  _CommodityPrice(
    name: 'Cabai Rawit',
    category: 'Sayuran',
    currentPrice: 'Rp 55.000',
    change: '-3.2%',
    isUp: false,
    unit: '/kg',
    trend: 'turun',
    sparkline: [58000, 57500, 57000, 56500, 55500, 55000],
  ),
  _CommodityPrice(
    name: 'Bawang Merah',
    category: 'Sayuran',
    currentPrice: 'Rp 28.000',
    change: '+1.2%',
    isUp: true,
    unit: '/kg',
    trend: 'naik',
    sparkline: [27500, 27700, 27800, 27900, 28000, 28000],
  ),
  _CommodityPrice(
    name: 'Bawang Putih',
    category: 'Sayuran',
    currentPrice: 'Rp 32.000',
    change: '+0.8%',
    isUp: true,
    unit: '/kg',
    trend: 'naik',
    sparkline: [31500, 31700, 31800, 31900, 32000, 32000],
  ),
  _CommodityPrice(
    name: 'Jagung',
    category: 'Pangan Pokok',
    currentPrice: 'Rp 8.500',
    change: '+0.0%',
    isUp: true,
    unit: '/kg',
    trend: 'stabil',
    sparkline: [8400, 8450, 8480, 8500, 8500, 8500],
  ),
  _CommodityPrice(
    name: 'Tomat',
    category: 'Sayuran',
    currentPrice: 'Rp 15.000',
    change: '-3.2%',
    isUp: false,
    unit: '/kg',
    trend: 'turun',
    sparkline: [16000, 15800, 15500, 15300, 15100, 15000],
  ),
  _CommodityPrice(
    name: 'Telur Ayam',
    category: 'Protein',
    currentPrice: 'Rp 26.000',
    change: '+4.0%',
    isUp: true,
    unit: '/kg',
    trend: 'naik',
    sparkline: [25000, 25200, 25400, 25600, 25800, 26000],
  ),
  _CommodityPrice(
    name: 'Daging Ayam',
    category: 'Protein',
    currentPrice: 'Rp 38.000',
    change: '+2.1%',
    isUp: true,
    unit: '/kg',
    trend: 'naik',
    sparkline: [37000, 37200, 37500, 37700, 37900, 38000],
  ),
  _CommodityPrice(
    name: 'Minyak Goreng',
    category: 'Bahan Pokok',
    currentPrice: 'Rp 18.500',
    change: '+0.5%',
    isUp: true,
    unit: '/liter',
    trend: 'stabil',
    sparkline: [18200, 18300, 18400, 18450, 18480, 18500],
  ),
  _CommodityPrice(
    name: 'Gula Pasir',
    category: 'Bahan Pokok',
    currentPrice: 'Rp 14.000',
    change: '-1.0%',
    isUp: false,
    unit: '/kg',
    trend: 'turun',
    sparkline: [14200, 14150, 14100, 14050, 14020, 14000],
  ),
];

class _PriceCard extends StatelessWidget {
  final _CommodityPrice commodity;
  final VoidCallback? onTap;

  const _PriceCard({
    required this.commodity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = commodity.isUp ? AppTheme.statusDanger : AppTheme.statusSuccess;
    final trendIcon = commodity.isUp
        ? Icons.arrow_upward_rounded
        : (commodity.trend == 'stabil' ? Icons.trending_flat_rounded : Icons.arrow_downward_rounded);

    return Semantics(
      label: '${commodity.name}, harga ${commodity.currentPrice}, ${commodity.trend} ${commodity.change}',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.brandPrimary.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(
              radius: 16,
              shadows: AppTheme.softShadow(0.06),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(commodity.category).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(commodity.category),
                        color: _getCategoryColor(commodity.category),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            commodity.name,
                            style: AppTheme.poppins(
                              fontSize: 16,
                              weight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          _CategoryChip(category: commodity.category),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          commodity.currentPrice,
                          style: tabularNumber(
                            fontSize: 20,
                            weight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _TrendBadge(
                          trend: commodity.trend,
                          change: commodity.change,
                          isUp: commodity.isUp,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SparklineChart(
                  points: commodity.sparkline,
                  color: color,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _TrendChip(trend: commodity.trend, isUp: commodity.isUp),
                    const Spacer(),
                    Text(
                      'Per ${commodity.unit}',
                      style: AppTheme.inter(
                        fontSize: 11,
                        color: AppTheme.neutral400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pangan Pokok':
        return AppTheme.brandPrimary;
      case 'Sayuran':
        return AppTheme.brandAccent;
      case 'Protein':
        return const Color(0xFF2196F3);
      case 'Bahan Pokok':
        return const Color(0xFF9C27B0);
      default:
        return AppTheme.neutral400;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pangan Pokok':
        return Icons.grain_rounded;
      case 'Sayuran':
        return Icons.eco_rounded;
      case 'Protein':
        return Icons.egg_rounded;
      case 'Bahan Pokok':
        return Icons.local_grocery_store_rounded;
      default:
        return Icons.category_rounded;
    }
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
      case 'Protein':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        break;
      case 'Bahan Pokok':
        bgColor = const Color(0xFFF3E5F5);
        textColor = const Color(0xFF7B1FA2);
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

class _TrendBadge extends StatelessWidget {
  final String trend;
  final String change;
  final bool isUp;

  const _TrendBadge({
    required this.trend,
    required this.change,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color iconColor;
    IconData icon;

    if (trend == 'stabil') {
      bgColor = AppTheme.statusWarning.withValues(alpha: 0.12);
      textColor = AppTheme.statusWarning;
      iconColor = AppTheme.statusWarning;
      icon = Icons.trending_flat_rounded;
    } else if (isUp) {
      bgColor = AppTheme.statusDanger.withValues(alpha: 0.12);
      textColor = AppTheme.statusDanger;
      iconColor = AppTheme.statusDanger;
      icon = Icons.arrow_upward_rounded;
    } else {
      bgColor = AppTheme.statusSuccess.withValues(alpha: 0.12);
      textColor = AppTheme.statusSuccess;
      iconColor = AppTheme.statusSuccess;
      icon = Icons.arrow_downward_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: iconColor),
          const SizedBox(width: 3),
          Text(
            change,
            style: AppTheme.inter(
              fontSize: 11,
              weight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  final String trend;
  final bool isUp;

  const _TrendChip({required this.trend, required this.isUp});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    if (trend == 'stabil') {
      bgColor = AppTheme.statusWarning.withValues(alpha: 0.12);
      textColor = AppTheme.statusWarning;
      icon = Icons.trending_flat_rounded;
    } else if (isUp) {
      bgColor = AppTheme.statusDanger.withValues(alpha: 0.12);
      textColor = AppTheme.statusDanger;
      icon = Icons.trending_up_rounded;
    } else {
      bgColor = AppTheme.statusSuccess.withValues(alpha: 0.12);
      textColor = AppTheme.statusSuccess;
      icon = Icons.trending_down_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            trend.toUpperCase(),
            style: AppTheme.inter(
              fontSize: 11,
              weight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklineChart extends StatelessWidget {
  final List<double> points;
  final Color color;

  const _SparklineChart({required this.points, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: CustomPaint(
        painter: _SparklinePainter(points: points, color: color),
        size: const Size(double.infinity, 56),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _SparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;

    final path = Path();
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Area gradient
    final areaPath = Path();
    final areaPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.2),
          color.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final normalized = range > 0 ? (points[i] - minVal) / range : 0.5;
      final y = size.height - (normalized * size.height * 0.75 + size.height * 0.125);

      if (i == 0) {
        path.moveTo(x, y);
        areaPath.moveTo(x, size.height);
        areaPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        areaPath.lineTo(x, y);
      }
    }

    // Close area path
    areaPath.lineTo(size.width, size.height);
    areaPath.close();

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(path, paint);

    // Draw last point dot
    final lastX = size.width;
    final lastNormalized = range > 0 ? (points.last - minVal) / range : 0.5;
    final lastY = size.height - (lastNormalized * size.height * 0.75 + size.height * 0.125);
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(lastX, lastY), 4, dotPaint);
    // White inner dot
    canvas.drawCircle(Offset(lastX, lastY), 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}