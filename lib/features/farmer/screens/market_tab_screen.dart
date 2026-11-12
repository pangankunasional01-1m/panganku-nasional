import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                collapsedTitle: 'Pasar Terdekat',
                bottomHeight: 130,
                bottom: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      const SizedBox(height: 8),
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
                expandedContent: const SizedBox.shrink(),
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
                            itemBuilder: (_, _) => const _MarketCardSkeleton(),
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
              ),
            ],
          ),
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
              Text(label, style: AppTheme.inter(fontSize: 13, weight: FontWeight.w600, color: AppTheme.textDark)),
              if (hasCount) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.brandPrimary, borderRadius: BorderRadius.circular(8)),
                  child: Text('$count', style: AppTheme.inter(fontSize: 11, weight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final _MarketFilter currentFilter;
  final ValueChanged<_MarketFilter> onApply;

  const _FilterBottomSheet({required this.currentFilter, required this.onApply});

  @override
  Widget build(BuildContext context) {
    String? selectedCategory = currentFilter.category;
    bool openOnly = currentFilter.openOnly;
    double radiusKm = currentFilter.radiusKm ?? 10.0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Filter Pasar', style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w700, color: AppTheme.textDark)),
              const Spacer(),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600, color: AppTheme.neutral500))),
            ],
          ),
          const SizedBox(height: 20),
          Text('Kategori', style: AppTheme.poppins(fontSize: 14, weight: FontWeight.w600, color: AppTheme.textDark)),
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
          Text('Radius Pencarian', style: AppTheme.poppins(fontSize: 14, weight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          Slider(
            value: radiusKm,
            min: 1,
            max: 50,
            divisions: 49,
            label: '${radiusKm.toInt()} km',
            activeColor: AppTheme.brandPrimary,
            onChanged: (v) => radiusKm = v,
          ),
          Text('Jarak maksimal: ${radiusKm.toInt()} km', style: AppTheme.inter(fontSize: 13, color: AppTheme.neutral500)),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: openOnly,
                onChanged: (v) => openOnly = v ?? false,
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
                    selectedCategory = null;
                    openOnly = false;
                    radiusKm = 10.0;
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.brandPrimary,
                    side: const BorderSide(color: AppTheme.brandPrimary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Reset', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    onApply(_MarketFilter(category: selectedCategory, openOnly: openOnly, radiusKm: radiusKm));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text('Terapkan', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChoiceChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, style: AppTheme.inter(fontSize: 13, weight: FontWeight.w500)),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.brandPrimary.withValues(alpha: 0.18),
      backgroundColor: Colors.white,
      labelStyle: AppTheme.inter(fontSize: 13, weight: FontWeight.w500, color: isSelected ? AppTheme.brandPrimary : AppTheme.neutral500),
      side: BorderSide(color: isSelected ? AppTheme.brandPrimary : AppTheme.neutral200, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}

class _SortBottomSheet extends StatelessWidget {
  final _SortOption currentSort;
  final ValueChanged<_SortOption> onSelect;

  const _SortBottomSheet({required this.currentSort, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Urutkan', style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w700, color: AppTheme.textDark)),
              const Spacer(),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600, color: AppTheme.neutral500))),
            ],
          ),
          const SizedBox(height: 20),
          ..._SortOption.values.map((opt) => RadioListTile<_SortOption>(
            title: Text(opt.label, style: AppTheme.inter(fontSize: 15, color: AppTheme.textDark)),
            value: opt,
            groupValue: currentSort,
            onChanged: (v) {
              if (v != null) {
                onSelect(v);
                Navigator.pop(context);
              }
            },
            activeColor: AppTheme.brandPrimary,
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

class _MarketCard extends StatelessWidget {
  final _Market market;

  const _MarketCard({required this.market});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${market.name}, ${market.type}, rating ${market.rating}',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMarketDetail(context),
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.brandPrimary.withValues(alpha: 0.12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.neutral200),
              boxShadow: AppTheme.softShadow(0.03),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getTypeIcon(market.type), color: AppTheme.brandPrimary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(market.name, style: AppTheme.poppins(fontSize: 15, weight: FontWeight.w700, color: AppTheme.textDark))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: market.isOpen ? AppTheme.statusSuccess.withValues(alpha: 0.1) : AppTheme.neutral200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              market.isOpen ? 'Buka' : 'Tutup',
                              style: AppTheme.inter(fontSize: 11, weight: FontWeight.w600, color: market.isOpen ? AppTheme.statusSuccess : AppTheme.neutral500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(market.type, style: AppTheme.inter(fontSize: 13, color: AppTheme.neutral500)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: AppTheme.neutral400),
                          const SizedBox(width: 4),
                          Text('${market.distance.toStringAsFixed(1)} km', style: AppTheme.inter(fontSize: 13, color: AppTheme.neutral500)),
                          const SizedBox(width: 16),
                          Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(market.rating.toStringAsFixed(1), style: AppTheme.inter(fontSize: 13, weight: FontWeight.w600, color: AppTheme.textDark)),
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
                    decoration: BoxDecoration(color: AppTheme.neutral100, borderRadius: BorderRadius.circular(6)),
                    child: Text(c, style: AppTheme.inter(fontSize: 11, color: AppTheme.neutral500)),
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

class _MarketDetailSheet extends StatelessWidget {
  final _Market market;

  const _MarketDetailSheet({required this.market});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                decoration: BoxDecoration(color: AppTheme.brandPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(_getTypeIcon(market.type), color: AppTheme.brandPrimary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(market.name, style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w700, color: AppTheme.textDark)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: market.isOpen ? AppTheme.statusSuccess.withValues(alpha: 0.1) : AppTheme.neutral200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(market.isOpen ? 'Buka Sekarang' : 'Tutup', style: AppTheme.inter(fontSize: 12, weight: FontWeight.w600, color: market.isOpen ? AppTheme.statusSuccess : AppTheme.neutral500)),
                        ),
                        const SizedBox(width: 12),
                        Text('${market.distance.toStringAsFixed(1)} km', style: AppTheme.inter(fontSize: 13, color: AppTheme.neutral500)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 20),
          Text('Komoditas Tersedia', style: AppTheme.poppins(fontSize: 16, weight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: market.commodities.map((c) => Chip(
              label: Text(c, style: AppTheme.inter(fontSize: 13, color: AppTheme.textDark)),
              backgroundColor: AppTheme.neutral100,
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
                  label: Text('Lapor Harga', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.brandAccent, side: const BorderSide(color: AppTheme.brandAccent, width: 1.5), padding: const EdgeInsets.symmetric(vertical: 16)),
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
                  label: Text('Navigasi', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
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

class _MarketCardSkeleton extends StatelessWidget {
  const _MarketCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.neutral200)),
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

  Widget _skeletonBox(double w, double h, double r) => Container(width: w, height: h, decoration: BoxDecoration(color: AppTheme.neutral200.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(r)));
}

class _OfflineBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const _OfflineBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.brandAccentSoft, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.brandAccent.withValues(alpha: 0.3))),
      child: Row(children: [Icon(Icons.wifi_off_rounded, color: AppTheme.brandAccent, size: 20), const SizedBox(width: 10), Expanded(child: Text('Mode offline — data terakhir disimpan', style: AppTheme.inter(fontSize: 13, weight: FontWeight.w500, color: AppTheme.textDark))), TextButton(onPressed: onDismiss, child: Text('Tutup', style: AppTheme.inter(fontSize: 13, weight: FontWeight.w600, color: AppTheme.brandAccent)))]),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.statusDanger.withValues(alpha: 0.5)), const SizedBox(height: 16), Text('Gagal Memuat', style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w600, color: AppTheme.textDark)), const SizedBox(height: 8), Text(message, style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500), textAlign: TextAlign.center), const SizedBox(height: 20), ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: Text('Coba Lagi', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)))])));
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  const _EmptyState({required this.title, required this.message, required this.actionLabel, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.inbox_outlined, size: 64, color: AppTheme.neutral300), const SizedBox(height: 16), Text(title, style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w600, color: AppTheme.textDark)), const SizedBox(height: 8), Text(message, style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500), textAlign: TextAlign.center), const SizedBox(height: 20), OutlinedButton.icon(onPressed: onAction, icon: const Icon(Icons.refresh_rounded), label: Text(actionLabel, style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.brandPrimary, side: const BorderSide(color: AppTheme.brandPrimary, width: 1.5), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)))])));
  }
}

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