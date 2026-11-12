import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pangan_sliver_header.dart';

/// Pasar (Market Tab) — pasar/toko terdekat
class MarketTabScreen extends ConsumerStatefulWidget {
  const MarketTabScreen({super.key});

  @override
  ConsumerState<MarketTabScreen> createState() => _MarketTabScreenState();
}

class _MarketTabScreenState extends ConsumerState<MarketTabScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  _MarketFilter _filter = _MarketFilter.defaultFilter();
  _SortOption _sortOption = _SortOption.distance;
  bool _isLoading = true;
  String? _error;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<_Market> get _filteredMarkets {
    var markets = _markets.where((m) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!m.name.toLowerCase().contains(query) &&
            !m.type.toLowerCase().contains(query) &&
            !m.commodities.any((c) => c.toLowerCase().contains(query))) {
          return false;
        }
      }
      // Category filter
      if (_filter.category != null && m.type != _filter.category) {
        return false;
      }
      // Open status filter
      if (_filter.openOnly && !m.isOpen) {
        return false;
      }
      // Radius filter (simplified - in real app would use GPS distance)
      // if (_filter.radiusKm != null && m.distance > _filter.radiusKm!) return false;
      return true;
    }).toList();

    // Sort
    switch (_sortOption) {
      case _SortOption.distance:
        // Already sorted by distance in mock data
        break;
      case _SortOption.rating:
        markets.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _SortOption.openNow:
        markets.sort((a, b) {
          if (a.isOpen == b.isOpen) return 0;
          return a.isOpen ? -1 : 1;
        });
        break;
    }

    return markets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.brandPrimary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            PanganSliverHeader(
              expandedHeight: 140,
              collapsedTitle: 'Pasar Terdekat',
              bottomHeight: 160,
              bottom: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Bar
                    _SearchBar(
                      controller: _searchController,
                      onChanged: (v) {
                        setState(() => _searchQuery = v);
                      },
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                    const SizedBox(height: 12),
                    // Filter & Sort Chips
                    Row(
                      children: [
                        Expanded(
                          child: _FilterChip(
                            label: 'Filter',
                            icon: Icons.tune_rounded,
                            count: _filter.hasActiveFilters ? 1 : 0,
                            onTap: () => _showFilterBottomSheet(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FilterChip(
                            label: 'Urutkan',
                            icon: Icons.sort_rounded,
                            onTap: () => _showSortBottomSheet(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              expandedContent: SafeArea(
                bottom: false,
                child: Text(
                  'Pasar Terdekat',
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
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, __) => const _MarketCardSkeleton(),
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
            else if (_filteredMarkets.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  title: _searchQuery.isNotEmpty || _filter.hasActiveFilters
                      ? 'Tidak Ada Hasil'
                      : 'Belum Ada Data Pasar',
                  message: _searchQuery.isNotEmpty || _filter.hasActiveFilters
                      ? 'Coba ubah pencarian atau filter'
                      : 'Data pasar akan segera tersedia',
                  actionLabel: _searchQuery.isNotEmpty || _filter.hasActiveFilters
                      ? 'Reset Filter'
                      : 'Muat Ulang',
                  onAction: () {
                    if (_searchQuery.isNotEmpty || _filter.hasActiveFilters) {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _filter = _MarketFilter.defaultFilter();
                      });
                    } else {
                      _onRefresh();
                    }
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList.separated(
                  itemCount: _filteredMarkets.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final m = _filteredMarkets[index];
                    return EntranceAnimation(
                      delay: Delay(100 + index * 60),
                      offset: const Offset(0, 0.15),
                      child: _MarketCard(market: m),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        currentFilter: _filter,
        onApply: (newFilter) {
          setState(() => _filter = newFilter);
        },
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SortBottomSheet(
        currentSort: _sortOption,
        onSelect: (sort) {
          setState(() => _sortOption = sort);
        },
      ),
    );
  }
}

class _MarketFilter {
  final String? category; // null = all
  final bool openOnly;
  final double? radiusKm;

  const _MarketFilter({
    this.category,
    this.openOnly = false,
    this.radiusKm,
  });

  bool get hasActiveFilters => category != null || openOnly || radiusKm != null;

  factory _MarketFilter.defaultFilter() => const _MarketFilter();

  _MarketFilter copyWith({
    String? category,
    bool? openOnly,
    double? radiusKm,
  }) {
    return _MarketFilter(
      category: category ?? this.category,
      openOnly: openOnly ?? this.openOnly,
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }
}

enum _SortOption {
  distance('Jarak Terdekat'),
  rating('Rating Tertinggi'),
  openNow('Buka Sekarang');

  final String label;
  const _SortOption(this.label);
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTheme.inter(fontSize: 14, color: AppTheme.textDark),
        decoration: InputDecoration(
          hintText: 'Cari pasar, toko, atau komoditas...',
          hintStyle: AppTheme.inter(fontSize: 14, color: AppTheme.neutral400),
          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.neutral400, size: 22),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: AppTheme.neutral400, size: 22),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    this.count = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCount = count > 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppTheme.brandPrimary.withValues(alpha: 0.12),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.neutral200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppTheme.textDark),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTheme.inter(
                  fontSize: 13,
                  weight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              if (hasCount) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: AppTheme.inter(
                      fontSize: 10,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
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

class _MarketCardSkeleton extends StatelessWidget {
  const _MarketCardSkeleton();

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
              _shimmerBox(48, 48, 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(140, 20, 4),
                    const SizedBox(height: 4),
                    _shimmerBox(80, 14, 10),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _shimmerBox(60, 18, 4),
                  const SizedBox(height: 4),
                  _shimmerBox(50, 14, 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _shimmerBox(20, 14, 4),
              const SizedBox(width: 8),
              Expanded(child: _shimmerBox(double.infinity, 14, 4)),
              const SizedBox(width: 8),
              _shimmerBox(60, 14, 12),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _shimmerBox(20, 14, 4),
              const SizedBox(width: 8),
              _shimmerBox(100, 14, 4),
            ],
          ),
          const SizedBox(height: 12),
          _shimmerBox(double.infinity, 32, 4),
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
              child: Icon(Icons.storefront_outlined, size: 48, color: AppTheme.brandPrimary),
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
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(actionLabel, style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
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

class _Market {
  final String name;
  final String type; // 'Pasar Tradisional', 'Toko Modern', 'Kios', 'Kolektor'
  final String address;
  final String distance; // e.g., '1.2 km'
  final String openHours;
  final bool isOpen;
  final double rating;
  final List<String> commodities;
  final IconData icon;

  const _Market({
    required this.name,
    required this.type,
    required this.address,
    required this.distance,
    required this.openHours,
    required this.isOpen,
    required this.rating,
    required this.commodities,
    required this.icon,
  });
}

const _markets = <_Market>[
  _Market(
    name: 'Pasar Induk Kramat Jati',
    type: 'Pasar Tradisional',
    address: 'Jl. Raya Bogor KM 19, Kramat Jati, Jakarta Timur',
    distance: '2.3 km',
    openHours: '04:00 - 18:00',
    isOpen: true,
    rating: 4.5,
    commodities: ['Beras', 'Cabai', 'Bawang', 'Tomat', 'Telur'],
    icon: Icons.store_rounded,
  ),
  _Market(
    name: 'Tani Jaya Modern Market',
    type: 'Toko Modern',
    address: 'Jl. Raya Condet No. 45, Pasar Rebo, Jakarta Timur',
    distance: '1.8 km',
    openHours: '07:00 - 21:00',
    isOpen: true,
    rating: 4.7,
    commodities: ['Beras Premium', 'Minyak', 'Gula', 'Tepung', 'Bumbu'],
    icon: Icons.shopping_cart_rounded,
  ),
  _Market(
    name: 'Kios Bapak Surya',
    type: 'Kios',
    address: 'Jl. Kalimalang Raya No. 12, Duren Sawit, Jakarta Timur',
    distance: '0.5 km',
    openHours: '06:00 - 20:00',
    isOpen: true,
    rating: 4.3,
    commodities: ['Pupuk', 'Bibit', 'Pestisida', 'Alat Pertanian'],
    icon: Icons.storefront_rounded,
  ),
  _Market(
    name: 'Kolektor Pak Budi',
    type: 'Kolektor',
    address: 'Ds. Cibuntu, Kec. Cileungsi, Bogor',
    distance: '5.2 km',
    openHours: '07:00 - 17:00',
    isOpen: false,
    rating: 4.2,
    commodities: ['Padi', 'Jagung', 'Singkong', 'Kedelai'],
    icon: Icons.agriculture_rounded,
  ),
  _Market(
    name: 'Pasar Minggu Modern',
    type: 'Pasar Tradisional',
    address: 'Jl. Raya Pasar Minggu No. 89, Pancoran, Jakarta Selatan',
    distance: '8.1 km',
    openHours: '05:00 - 19:00',
    isOpen: true,
    rating: 4.4,
    commodities: ['Sayur Mayur', 'Buah-buahan', 'Ikan', 'Daging', 'Telur'],
    icon: Icons.store_rounded,
  ),
  _Market(
    name: 'Green Fresh Supermarket',
    type: 'Toko Modern',
    address: 'Jl. M.T. Haryono No. 123, Tebet, Jakarta Selatan',
    distance: '6.7 km',
    openHours: '08:00 - 22:00',
    isOpen: true,
    rating: 4.6,
    commodities: ['Organik', 'Hydroponik', 'Import', 'Siap Saji'],
    icon: Icons.local_grocery_store_rounded,
  ),
];

class _MarketCard extends StatelessWidget {
  final _Market market;

  const _MarketCard({required this.market});

  @override
  Widget build(BuildContext context) {
    final statusColor = market.isOpen ? AppTheme.statusSuccess : AppTheme.neutral400;
    final statusText = market.isOpen ? 'BUKA' : 'TUTUP';

    return Semantics(
      label: '${market.name}, ${market.type}, ${market.distance}, ${statusText}, rating ${market.rating}',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showMarketDetailBottomSheet(context);
          },
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(market.icon, color: AppTheme.brandPrimary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            market.name,
                            style: AppTheme.poppins(
                              fontSize: 16,
                              weight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              market.type,
                              style: AppTheme.inter(
                                fontSize: 10,
                                weight: FontWeight.w600,
                                color: AppTheme.brandPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: 14, color: AppTheme.brandSecondary),
                            const SizedBox(width: 3),
                            Text(
                              market.rating.toString(),
                              style: AppTheme.inter(
                                fontSize: 13,
                                weight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            statusText,
                            style: AppTheme.inter(
                              fontSize: 10,
                              weight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14, color: AppTheme.neutral400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        market.address,
                        style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.neutral100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        market.distance,
                        style: AppTheme.inter(
                          fontSize: 11,
                          weight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: AppTheme.neutral400),
                    const SizedBox(width: 4),
                    Text(
                      market.openHours,
                      style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: market.commodities.map((c) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.brandPrimary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        c,
                        style: AppTheme.inter(
                          fontSize: 11,
                          weight: FontWeight.w500,
                          color: AppTheme.brandPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMarketDetailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MarketDetailBottomSheet(market: market),
    );
  }
}

class _MarketDetailBottomSheet extends StatelessWidget {
  final _Market market;

  const _MarketDetailBottomSheet({required this.market});

  @override
  Widget build(BuildContext context) {
    final statusColor = market.isOpen ? AppTheme.statusSuccess : AppTheme.neutral400;
    final statusText = market.isOpen ? 'BUKA' : 'TUTUP';

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(market.icon, color: AppTheme.brandPrimary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.name,
                      style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w700, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            market.type,
                            style: AppTheme.inter(fontSize: 11, weight: FontWeight.w600, color: AppTheme.brandPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            statusText,
                            style: AppTheme.inter(fontSize: 11, weight: FontWeight.w700, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppTheme.neutral200),
          const SizedBox(height: 16),
          _DetailRow(icon: Icons.location_on_rounded, label: 'Alamat', value: market.address),
          const SizedBox(height: 12),
          _DetailRow(icon: Icons.straighten_rounded, label: 'Jarak', value: market.distance),
          const SizedBox(height: 12),
          _DetailRow(icon: Icons.access_time_rounded, label: 'Jam Buka', value: market.openHours),
          const SizedBox(height: 12),
          _DetailRow(icon: Icons.star_rounded, label: 'Rating', value: '${market.rating} / 5.0'),
          const SizedBox(height: 16),
          Divider(color: AppTheme.neutral200),
          const SizedBox(height: 16),
          Text('Komoditas Tersedia', style: AppTheme.poppins(fontSize: 16, weight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: market.commodities.map((c) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.brandPrimarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(c, style: AppTheme.inter(fontSize: 12, weight: FontWeight.w500, color: AppTheme.brandPrimary)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Buka Maps ke ${market.name} — segera hadir'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions_rounded, size: 20),
                  label: Text('Arahkan', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.brandPrimary,
                    side: const BorderSide(color: AppTheme.brandPrimary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lapor harga di ${market.name} — segera hadir'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_alert_rounded, size: 20),
                  label: Text('Lapor Harga', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.neutral400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral400)),
              const SizedBox(height: 2),
              Text(value, style: AppTheme.inter(fontSize: 13, weight: FontWeight.w500, color: AppTheme.textDark)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Filter Bottom Sheet ────────────────────────────────────────────────

class _FilterBottomSheet extends ConsumerStatefulWidget {
  final _MarketFilter currentFilter;
  final ValueChanged<_MarketFilter> onApply;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.onApply,
  });

  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  late _MarketFilter _filter;
  double _radius = 10.0;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _radius = _filter.radiusKm ?? 10.0;
  }

  @override
  Widget build(BuildContext context) {
    const categories = ['Pasar Tradisional', 'Toko Modern', 'Kios', 'Kolektor'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Filter Pasar', style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 24),
          Text('Kategori', style: AppTheme.poppins(fontSize: 14, weight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChoiceChip(
                label: 'Semua',
                isSelected: _filter.category == null,
                onSelected: () => setState(() => _filter = _filter.copyWith(category: null)),
              ),
              ...categories.map((c) => _FilterChoiceChip(
                    label: c,
                    isSelected: _filter.category == c,
                    onSelected: () => setState(() => _filter = _filter.copyWith(category: c)),
                  )),
            ],
          ),
          const SizedBox(height: 24),
          Text('Radius Pencarian', style: AppTheme.poppins(fontSize: 14, weight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Text('${_radius.toInt()} km', style: AppTheme.inter(fontSize: 16, weight: FontWeight.w700, color: AppTheme.brandPrimary)),
          Slider(
            value: _radius,
            min: 1,
            max: 50,
            divisions: 49,
            label: '${_radius.toInt()} km',
            activeColor: AppTheme.brandPrimary,
            onChanged: (v) => setState(() => _radius = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _filter.openOnly,
                onChanged: (v) => setState(() => _filter = _filter.copyWith(openOnly: v!)),
                activeColor: AppTheme.brandPrimary,
              ),
              const SizedBox(width: 8),
              Text('Hanya yang buka sekarang', style: AppTheme.inter(fontSize: 14, color: AppTheme.textDark)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _filter = _MarketFilter.defaultFilter();
                      _radius = 10.0;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.neutral500,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Reset', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(_filter.copyWith(radiusKm: _radius));
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Terapkan', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FilterChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppTheme.brandPrimary.withValues(alpha: 0.12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.brandPrimary : AppTheme.neutral50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.brandPrimary : AppTheme.neutral200,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: AppTheme.inter(
              fontSize: 13,
              weight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sort Bottom Sheet ────────────────────────────────────────────────

class _SortBottomSheet extends StatelessWidget {
  final _SortOption currentSort;
  final ValueChanged<_SortOption> onSelect;

  const _SortBottomSheet({
    required this.currentSort,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Urutkan Berdasarkan', style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          ..._SortOption.values.map((option) {
            final isSelected = option == currentSort;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(option);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.label,
                          style: AppTheme.inter(
                            fontSize: 16,
                            weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppTheme.brandPrimary : AppTheme.textDark,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_rounded, color: AppTheme.brandPrimary, size: 24),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}