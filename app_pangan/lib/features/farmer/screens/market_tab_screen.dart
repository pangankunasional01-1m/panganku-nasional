import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/go_pay_theme.dart';

/// Pasar (Market Tab) — GoPay style redesign
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
  // ignore: unused_field
  final bool _isOffline = false;

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
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!m.name.toLowerCase().contains(query) &&
            !m.type.toLowerCase().contains(query) &&
            !m.commodities.any((c) => c.toLowerCase().contains(query))) {
          return false;
        }
      }
      if (_filter.category != null && m.type != _filter.category) {
        return false;
      }
      if (_filter.openOnly && !m.isOpen) {
        return false;
      }
      return true;
    }).toList();

    switch (_sortOption) {
      case _SortOption.distance:
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
    final colors = GoPayColors();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.bgCream,
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: colors.brandPrimary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ===== HEADER (GoPay Style) =====
              SliverAppBar(
                expandedHeight: 180,
                floating: true,
                pinned: false,
                backgroundColor: colors.brandPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeaderContent(colors),
                ),
              ),

              // ===== CONTENT (White rounded panel overlapping header) =====
              SliverPersistentHeader(
                pinned: false,
                delegate: _ContentHeaderDelegate(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.bgCream,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(GoPayRadius.header)),
                    ),
                  ),
                ),
              ),

              // Content slivers
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Search bar
                    _buildSearchBar(colors),

                    const SizedBox(height: 12),

                    // Filter & Sort chips
                    _buildFilterSortChips(colors),

                    const SizedBox(height: 16),

                    // Market list or states
                    if (_isLoading)
                      _buildLoadingState()
                    else if (_error != null)
                      _buildErrorState(colors)
                    else if (_filteredMarkets.isEmpty)
                      _buildEmptyState(colors)
                    else
                      _buildMarketList(colors),

                    // Bottom nav clearance
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header content with title, subtitle, search hint
  Widget _buildHeaderContent(GoPayColors colors) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.brandPrimary, colors.brandSecondary],
              stops: const [0.0, 0.6],
            ),
          ),
        ),
        // Subtle texture overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _HeaderPatternPainter(),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pasar & Toko Terdekat',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Temukan pasar dan toko terdekat untuk menjual hasil panen',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // Search hint in header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.7), size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'Cari pasar, toko, atau komoditas...',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Search bar in content area
  Widget _buildSearchBar(GoPayColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: colors.surfaceWhite,
          borderRadius: BorderRadius.circular(GoPayRadius.pill),
          boxShadow: [GoPayShadows.cardShadow()],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: GoogleFonts.inter(fontSize: 14, color: colors.textDark),
          decoration: InputDecoration(
            hintText: 'Cari pasar, toko, atau komoditas...',
            hintStyle: GoogleFonts.inter(fontSize: 14, color: colors.neutral400),
            prefixIcon: Icon(Icons.search_rounded, color: colors.neutral400, size: 22),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: colors.neutral400, size: 22),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  /// Filter & Sort chips
  Widget _buildFilterSortChips(GoPayColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
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
    );
  }

  /// Loading skeleton state
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        children: List.generate(4, (index) => Padding(
          padding: EdgeInsets.only(bottom: index == 3 ? 0 : 12),
          child: _MarketCardSkeleton(),
        )),
      ),
    );
  }

  /// Error state
  Widget _buildErrorState(GoPayColors colors) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: colors.statusDanger.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('Gagal Memuat', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: colors.textDark)),
            const SizedBox(height: 8),
            Text(_error!, style: GoogleFonts.inter(fontSize: 14, color: colors.neutral500), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('Coba Lagi', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState(GoPayColors colors) {
    final hasFilters = _searchQuery.isNotEmpty || _filter.hasActiveFilters;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: colors.neutral300),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'Tidak Ada Hasil' : 'Belum Ada Data Pasar',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: colors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters ? 'Coba ubah pencarian atau filter' : 'Data pasar akan segera tersedia',
              style: GoogleFonts.inter(fontSize: 14, color: colors.neutral500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                if (hasFilters) {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _filter = _MarketFilter.defaultFilter();
                  });
                } else {
                  _onRefresh();
                }
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(hasFilters ? 'Reset Filter' : 'Muat Ulang', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.brandPrimary,
                side: BorderSide(color: colors.brandPrimary, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Market list
  Widget _buildMarketList(GoPayColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        children: [
          for (int i = 0; i < _filteredMarkets.length; i++) ...[
            EntranceAnimation(
              delay: Delay(100 + i * 60),
              offset: const Offset(0, 0.15),
              child: _MarketCard(market: _filteredMarkets[i]),
            ),
            if (i != _filteredMarkets.length - 1) const SizedBox(height: 12),
          ],
        ],
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

/// Filter chip (Filter, Sort)
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
    final colors = GoPayColors();
    final hasCount = count > 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: colors.brandPrimary.withValues(alpha: 0.12),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.dividerLight),
            boxShadow: [GoPayShadows.cardShadow()],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: colors.textDark),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textDark)),
              if (hasCount) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: colors.brandPrimary, borderRadius: BorderRadius.circular(8)),
                  child: Text('$count', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Filter bottom sheet
class _FilterBottomSheet extends StatelessWidget {
  final _MarketFilter currentFilter;
  final ValueChanged<_MarketFilter> onApply;

  const _FilterBottomSheet({required this.currentFilter, required this.onApply});

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    String? selectedCategory = currentFilter.category;
    bool openOnly = currentFilter.openOnly;
    double radiusKm = currentFilter.radiusKm ?? 10.0;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(GoPayRadius.header)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Filter Pasar', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
              const Spacer(),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.neutral500))),
            ],
          ),
          const SizedBox(height: 20),
          Text('Kategori', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textDark)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChoiceChip(label: 'Semua', isSelected: selectedCategory == null, onTap: () => selectedCategory = null),
              _FilterChoiceChip(label: 'Pasar Tradisional', isSelected: selectedCategory == 'Pasar Tradisional', onTap: () => selectedCategory = 'Pasar Tradisional'),
              _FilterChoiceChip(label: 'Pasar Modern', isSelected: selectedCategory == 'Pasar Modern', onTap: () => selectedCategory = 'Pasar Modern'),
              _FilterChoiceChip(label: 'Toko Grosir', isSelected: selectedCategory == 'Toko Grosir', onTap: () => selectedCategory = 'Toko Grosir'),
              _FilterChoiceChip(label: 'Kios/Kantor', isSelected: selectedCategory == 'Kios/Kantor', onTap: () => selectedCategory = 'Kios/Kantor'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Radius Pencarian', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textDark)),
          const SizedBox(height: 12),
          Slider(
            value: radiusKm,
            min: 1,
            max: 50,
            divisions: 49,
            label: '${radiusKm.toInt()} km',
            activeColor: colors.brandPrimary,
            onChanged: (v) => radiusKm = v,
          ),
          Text('Jarak maksimal: ${radiusKm.toInt()} km', style: GoogleFonts.inter(fontSize: 13, color: colors.neutral500)),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: openOnly,
                onChanged: (v) => openOnly = v ?? false,
                activeColor: colors.brandPrimary,
              ),
              const SizedBox(width: 8),
              Text('Hanya yang buka sekarang', style: GoogleFonts.inter(fontSize: 14, color: colors.textDark)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    selectedCategory = null;
                    openOnly = false;
                    radiusKm = 10.0;
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.brandPrimary,
                    side: BorderSide(color: colors.brandPrimary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Reset', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    onApply(_MarketFilter(category: selectedCategory, openOnly: openOnly, radiusKm: radiusKm));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: colors.brandPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text('Terapkan', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Filter choice chip
class _FilterChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChoiceChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: colors.brandPrimary.withValues(alpha: 0.18),
      backgroundColor: colors.surfaceWhite,
      labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? colors.brandPrimary : colors.neutral500),
      side: BorderSide(color: isSelected ? colors.brandPrimary : colors.dividerLight, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}

/// Sort bottom sheet
class _SortBottomSheet extends StatelessWidget {
  final _SortOption currentSort;
  final ValueChanged<_SortOption> onSelect;

  const _SortBottomSheet({required this.currentSort, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(GoPayRadius.header)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Urutkan', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
              const Spacer(),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.neutral500))),
            ],
          ),
          const SizedBox(height: 20),
          ..._SortOption.values.map((opt) => RadioListTile<_SortOption>(
            title: Text(opt.label, style: GoogleFonts.inter(fontSize: 15, color: colors.textDark)),
            value: opt,
            // ignore: deprecated_member_use
            groupValue: currentSort,
            // ignore: deprecated_member_use
            onChanged: (v) {
              if (v != null) {
                onSelect(v);
                Navigator.pop(context);
              }
            },
            activeColor: colors.brandPrimary,
            contentPadding: EdgeInsets.zero,
          )),
        ],
      ),
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

/// Market card
class _MarketCard extends StatelessWidget {
  final _Market market;

  const _MarketCard({required this.market});

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return Semantics(
      label: '${market.name}, ${market.type}, rating ${market.rating}',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMarketDetail(context),
          borderRadius: BorderRadius.circular(16),
          splashColor: colors.brandPrimary.withValues(alpha: 0.12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.dividerLight),
              boxShadow: [GoPayShadows.cardShadow()],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getTypeIcon(market.type), color: colors.brandPrimary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(market.name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textDark))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: market.isOpen ? colors.statusSuccess.withValues(alpha: 0.1) : colors.neutral200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              market.isOpen ? 'Buka' : 'Tutup',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: market.isOpen ? colors.statusSuccess : colors.neutral500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(market.type, style: GoogleFonts.inter(fontSize: 13, color: colors.neutral500)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: colors.neutral400),
                          const SizedBox(width: 4),
                          Text('${market.distance.toStringAsFixed(1)} km', style: GoogleFonts.inter(fontSize: 13, color: colors.neutral500)),
                          const SizedBox(width: 16),
                          Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(market.rating.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textDark)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: market.commodities.take(3).map((c) => Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: colors.neutral100, borderRadius: BorderRadius.circular(6)),
                    child: Text(c, style: GoogleFonts.inter(fontSize: 11, color: colors.neutral500)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Pasar Tradisional': return Icons.storefront_rounded;
      case 'Pasar Modern': return Icons.store_mall_directory_rounded;
      case 'Toko Grosir': return Icons.inventory_2_rounded;
      default: return Icons.store_rounded;
    }
  }

  void _showMarketDetail(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MarketDetailSheet(market: market),
    );
  }
}

/// Market detail bottom sheet
class _MarketDetailSheet extends StatelessWidget {
  final _Market market;

  const _MarketDetailSheet({required this.market});

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(GoPayRadius.header)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: colors.brandPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(_getTypeIcon(market.type), color: colors.brandPrimary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(market.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: market.isOpen ? colors.statusSuccess.withValues(alpha: 0.1) : colors.neutral200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(market.isOpen ? 'Buka Sekarang' : 'Tutup', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: market.isOpen ? colors.statusSuccess : colors.neutral500)),
                        ),
                        const SizedBox(width: 12),
                        Text('${market.distance.toStringAsFixed(1)} km', style: GoogleFonts.inter(fontSize: 13, color: colors.neutral500)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 20),
          Text('Komoditas Tersedia', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textDark)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: market.commodities.map((c) => Chip(
              label: Text(c, style: GoogleFonts.inter(fontSize: 13, color: colors.textDark)),
              backgroundColor: colors.neutral100,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            )).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lapor harga — segera hadir'), behavior: SnackBarBehavior.floating));
                  },
                  icon: const Icon(Icons.report_problem_outlined),
                  label: Text('Lapor Harga', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(foregroundColor: colors.brandAccent, side: BorderSide(color: colors.brandAccent, width: 1.5), padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigasi — segera hadir'), behavior: SnackBarBehavior.floating));
                  },
                  icon: const Icon(Icons.navigation_rounded),
                  label: Text('Navigasi', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(backgroundColor: colors.brandPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Pasar Tradisional': return Icons.storefront_rounded;
      case 'Pasar Modern': return Icons.store_mall_directory_rounded;
      case 'Toko Grosir': return Icons.inventory_2_rounded;
      default: return Icons.store_rounded;
    }
  }
}

/// Market card skeleton
class _MarketCardSkeleton extends StatelessWidget {
  const _MarketCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.surfaceWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.dividerLight)),
      child: Row(
        children: [
          _skeletonBox(56, 56, 14),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(150, 20, 4),
                const SizedBox(height: 6),
                _skeletonBox(100, 16, 4),
                const SizedBox(height: 6),
                _skeletonBox(120, 14, 4),
              ],
            ),
          ),
          Column(children: [_skeletonBox(70, 24, 6), const SizedBox(height: 6), _skeletonBox(70, 24, 6), const SizedBox(height: 6), _skeletonBox(70, 24, 6)]),
        ],
      ),
    );
  }

  Widget _skeletonBox(double w, double h, double r) => Container(width: w, height: h, decoration: BoxDecoration(color: GoPayColors().neutral200.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(r)));
}

/// Market model
class _Market {
  final String name;
  final String type;
  final double distance;
  final double rating;
  final bool isOpen;
  final List<String> commodities;

  const _Market({required this.name, required this.type, required this.distance, required this.rating, required this.isOpen, required this.commodities});
}

final List<_Market> _markets = [
  _Market(name: 'Pasar Induk Cipinang', type: 'Pasar Tradisional', distance: 1.2, rating: 4.5, isOpen: true, commodities: ['Cabai Merah', 'Bawang Merah', 'Beras', 'Tomat', 'Ayam']),
  _Market(name: 'Pasar Modern Bintaro', type: 'Pasar Modern', distance: 3.5, rating: 4.7, isOpen: true, commodities: ['Beras Premium', 'Minyak Goreng', 'Gula Pasir', 'Telur', 'Daging Sapi']),
  _Market(name: 'Toko Grosir Makmur Jaya', type: 'Toko Grosir', distance: 2.8, rating: 4.3, isOpen: true, commodities: ['Cabai Merah (Grosir)', 'Bawang Merah (Grosir)', 'Beras (Karung)', 'Pupuk Organik']),
  _Market(name: 'Kios Tani Sejahtera', type: 'Kios/Kantor', distance: 0.8, rating: 4.6, isOpen: false, commodities: ['Bibit Cabai', 'Pupuk NPK', 'Pestisida Hayati', 'Alat Tani']),
  _Market(name: 'Pasar Kramat Jati', type: 'Pasar Tradisional', distance: 4.1, rating: 4.4, isOpen: true, commodities: ['Ikan Segar', 'Udang', 'Cumi', 'Kerang', 'Beras']),
  _Market(name: 'Supermart Kemang', type: 'Pasar Modern', distance: 5.2, rating: 4.8, isOpen: true, commodities: ['Beras Organik', 'Sayur Hydroponik', 'Buah Import', 'Daging Beku', 'Susu Segar']),
  _Market(name: 'Grosir Sembako Bahagia', type: 'Toko Grosir', distance: 3.0, rating: 4.2, isOpen: true, commodities: ['Beras 50kg', 'Minyak 20L', 'Gula 50kg', 'Tepung Terigu', 'Kopi Bubuk']),
];

class _MarketFilter {
  final String? category;
  final bool openOnly;
  final double? radiusKm;

  const _MarketFilter({this.category, this.openOnly = false, this.radiusKm});

  static _MarketFilter defaultFilter() => const _MarketFilter();

  bool get hasActiveFilters => category != null || openOnly || (radiusKm != null && radiusKm! < 50);

  _MarketFilter copyWith({String? category, bool? openOnly, double? radiusKm}) {
    return _MarketFilter(category: category ?? this.category, openOnly: openOnly ?? this.openOnly, radiusKm: radiusKm ?? this.radiusKm);
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