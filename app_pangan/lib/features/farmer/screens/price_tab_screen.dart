import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pangan_sliver_header.dart';

/// Harga (Price Tab) — daftar komoditas beserta tren harga
class PriceTabScreen extends ConsumerStatefulWidget {
  const PriceTabScreen({super.key});

  @override
  ConsumerState<PriceTabScreen> createState() => _PriceTabScreenState();
}

class _PriceTabScreenState extends ConsumerState<PriceTabScreen> {
  _PriceCategory _selectedCategory = _PriceCategory.all;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filteredCommodities = _selectedCategory == _PriceCategory.all
        ? _commodities
        : _commodities.where((c) => c.category == _selectedCategory.label).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.brandPrimary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              PanganSliverHeader(
                expandedHeight: 110,
                collapsedTitle: 'Harga Komoditas',
                expandedContent: EntranceAnimation(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harga Komoditas Hari Ini',
                        style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pantau harga pasar komoditas pertanian',
                        style: AppTheme.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // White rounded content panel overlapping header
              SliverPersistentHeader(
                pinned: false,
                delegate: _ContentHeaderDelegate(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.bgCream,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList.separated(
                  itemCount: filteredCommodities.isEmpty ? 1 : filteredCommodities.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (filteredCommodities.isEmpty) {
                      return _EmptyState(
                        title: 'Tidak ada data',
                        message: 'Belum ada harga untuk kategori ini',
                        actionLabel: 'Muat Ulang',
                        onAction: _onRefresh,
                      );
                    }
                    if (index == 0) {
                      return _FilterChips(
                        selectedCategory: _selectedCategory,
                        onCategoryChanged: (cat) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = cat);
                        },
                      );
                    }
                    final c = filteredCommodities[index - 1];
                    return EntranceAnimation(
                      delay: Delay(100 + (index - 1) * 60),
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
      ),
    );
  }

  void _navigateToDetail(BuildContext context, _CommodityPrice commodity) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detail ${commodity.name} — segera hadir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Persistent header delegate for the white content panel
class _ContentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _ContentHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 0;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
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
        return const Color(0xFF2196F3);
      case _PriceCategory.bahanPokok:
        return const Color(0xFF9C27B0);
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
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: _PriceCategory.values.map((cat) {
          final isSelected = cat == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat.label, style: AppTheme.inter(fontSize: 13, weight: FontWeight.w600)),
              selected: isSelected,
              onSelected: (_) => onCategoryChanged(cat),
              selectedColor: cat.color.withValues(alpha: 0.18),
              backgroundColor: Colors.white,
              labelStyle: AppTheme.inter(
                fontSize: 13,
                weight: FontWeight.w600,
                color: isSelected ? cat.color : AppTheme.neutral500,
              ),
              side: BorderSide(color: isSelected ? cat.color : AppTheme.neutral200, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final _CommodityPrice commodity;
  final VoidCallback onTap;

  const _PriceCard({required this.commodity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final change = commodity.changePercent;
    final isPositive = change >= 0;
    final changeColor = isPositive ? AppTheme.statusSuccess : AppTheme.statusDanger;
    final catColor = _PriceCategory.values.firstWhere((e) => e.label == commodity.category, orElse: () => _PriceCategory.all).color;

    return Semantics(
      label: '${commodity.name}, harga ${commodity.formattedPrice}, perubahan ${change.toStringAsFixed(1)}%',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: catColor.withValues(alpha: 0.12),
          child: Container(
            padding: const EdgeInsets.all(16),
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _PriceCategory.values.firstWhere((e) => e.label == commodity.category, orElse: () => _PriceCategory.all).icon,
                        color: catColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(commodity.name, style: AppTheme.poppins(fontSize: 16, weight: FontWeight.w700, color: AppTheme.textDark)),
                          const SizedBox(height: 2),
                          Text(commodity.unit, style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral500)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: changeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 14, color: changeColor),
                          const SizedBox(width: 4),
                          Text('${change.toStringAsFixed(1)}%', style: AppTheme.inter(fontSize: 12, weight: FontWeight.w600, color: changeColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Harga Pasar', style: AppTheme.inter(fontSize: 11, color: AppTheme.neutral500)),
                          const SizedBox(height: 2),
                          Text(commodity.formattedPrice, style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w700, color: AppTheme.textDark)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Harga Petani', style: AppTheme.inter(fontSize: 11, color: AppTheme.neutral500)),
                          const SizedBox(height: 2),
                          Text('Rp ${commodity.farmerPrice.toStringAsFixed(0)}/${commodity.unit}', style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w600, color: AppTheme.brandPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SparklineChart(points: commodity.history, color: catColor),
              ],
            ),
          ),
        ),
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

    areaPath.lineTo(size.width, size.height);
    areaPath.close();

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(path, paint);

    final lastX = size.width;
    final lastNormalized = range > 0 ? (points.last - minVal) / range : 0.5;
    final lastY = size.height - (lastNormalized * size.height * 0.75 + size.height * 0.125);
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(lastX, lastY), 4, dotPaint);
    canvas.drawCircle(Offset(lastX, lastY), 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({required this.title, required this.message, required this.actionLabel, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppTheme.neutral300),
            const SizedBox(height: 16),
            Text(title, style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w600, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            Text(message, style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel, style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.brandPrimary, side: const BorderSide(color: AppTheme.brandPrimary, width: 1.5), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
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
  final String unit;
  final double price;
  final double farmerPrice;
  final List<double> history;
  final double changePercent;

  const _CommodityPrice({
    required this.name,
    required this.category,
    required this.unit,
    required this.price,
    required this.farmerPrice,
    required this.history,
    required this.changePercent,
  });

  String get formattedPrice => 'Rp ${price.toStringAsFixed(0)}/$unit';
}

final List<_CommodityPrice> _commodities = [
  _CommodityPrice(name: 'Cabai Merah', category: 'Sayuran', unit: 'kg', price: 45000, farmerPrice: 38000, history: [38000, 40000, 42000, 43000, 45000, 46000, 45000], changePercent: 5.2),
  _CommodityPrice(name: 'Bawang Merah', category: 'Bumbu', unit: 'kg', price: 32000, farmerPrice: 26000, history: [28000, 29000, 30000, 31000, 32000, 33000, 32000], changePercent: -2.1),
  _CommodityPrice(name: 'Beras Premium', category: 'Pangan Pokok', unit: 'kg', price: 14500, farmerPrice: 11500, history: [13000, 13500, 14000, 14200, 14500, 14500, 14500], changePercent: 1.8),
  _CommodityPrice(name: 'Jagung', category: 'Pangan Pokok', unit: 'kg', price: 6500, farmerPrice: 5200, history: [6000, 6200, 6300, 6400, 6500, 6500, 6500], changePercent: 0.0),
  _CommodityPrice(name: 'Tomat', category: 'Sayuran', unit: 'kg', price: 18000, farmerPrice: 14000, history: [15000, 16000, 17000, 17500, 18000, 18500, 18000], changePercent: -3.4),
  _CommodityPrice(name: 'Kentang', category: 'Sayuran', unit: 'kg', price: 16000, farmerPrice: 12000, history: [14000, 14500, 15000, 15500, 16000, 16000, 16000], changePercent: 2.3),
  _CommodityPrice(name: 'Ayam Broiler', category: 'Protein', unit: 'kg', price: 28000, farmerPrice: 22000, history: [26000, 27000, 27500, 28000, 28500, 28000, 28000], changePercent: -1.2),
  _CommodityPrice(name: 'Telur Ayam', category: 'Protein', unit: 'kg', price: 26000, farmerPrice: 21000, history: [24000, 25000, 25500, 26000, 26000, 26000, 26000], changePercent: 0.0),
  _CommodityPrice(name: 'Gula Pasir', category: 'Bahan Pokok', unit: 'kg', price: 14000, farmerPrice: 11000, history: [13000, 13500, 13800, 14000, 14000, 14000, 14000], changePercent: 1.1),
  _CommodityPrice(name: 'Minyak Goreng', category: 'Bahan Pokok', unit: 'lt', price: 18000, farmerPrice: 15000, history: [17000, 17500, 17800, 18000, 18000, 18000, 18000], changePercent: 0.6),
];