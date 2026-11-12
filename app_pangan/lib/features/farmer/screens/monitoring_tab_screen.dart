import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pangan_sliver_header.dart';

/// Pantauan (Monitoring Tab) — komoditas favorit dan alert harga
class MonitoringTabScreen extends ConsumerStatefulWidget {
  const MonitoringTabScreen({super.key});

  @override
  ConsumerState<MonitoringTabScreen> createState() => _MonitoringTabScreenState();
}

class _MonitoringTabScreenState extends ConsumerState<MonitoringTabScreen> {
  List<_Favorite> _favorites = [..._defaultFavorites];
  List<_Alert> _alerts = [..._defaultAlerts];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final slivers = <Widget>[
      PanganSliverHeaderSimple(
        expandedHeight: 100,
        collapsedTitle: 'Pantauan Harga',
        expandedContent: const SizedBox.shrink(),
      ),
      if (_isLoading)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          sliver: SliverList.separated(
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const _FavoriteCardSkeleton(),
          ),
        )
      else
        _buildContentSliver(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showAddAlertBottomSheet(context);
        },
        icon: const Icon(Icons.add_alert_rounded, size: 22),
        label: Text('Tambah Alert', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
        backgroundColor: AppTheme.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.brandPrimary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: slivers,
        ),
      ),
    );
  }

  Widget _buildContentSliver() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      sliver: SliverList(
        delegate: SliverChildListDelegate(_buildContentList()),
      ),
    );
  }

  List<Widget> _buildContentList() {
    return [
      _SectionHeader(
        title: 'Komoditas Favorit',
        action: _favorites.isEmpty ? null : 'Kelola',
        onAction: _favorites.isEmpty ? null : () => _showManageFavoritesBottomSheet(context),
      ),
      const SizedBox(height: 12),
      if (_favorites.isEmpty)
        _EmptyFavoritesState(onAddFavorite: () => _showAddFavoriteBottomSheet(context))
      else
        ..._favorites.asMap().entries.map((entry) {
          final index = entry.key;
          final f = entry.value;
          return EntranceAnimation(
            delay: Delay(100 + index * 60),
            offset: const Offset(0, 0.15),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey(f.name),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.statusDanger,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                ),
                confirmDismiss: (direction) async {
                  HapticFeedback.lightImpact();
                  return await _showDeleteConfirmation(context, f.name);
                },
                onDismissed: (_) {
                  setState(() => _favorites.removeAt(index));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${f.name} dihapus dari favorit'),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'BATAL',
                        onPressed: () => setState(() => _favorites.insert(index, f)),
                      ),
                    ),
                  );
                },
                child: _FavoriteCard(favorite: f),
              ),
            ),
          );
        }),
      const SizedBox(height: 24),
      _SectionHeader(
        title: 'Alert Harga',
        action: 'Tambah',
        onAction: () => _showAddAlertBottomSheet(context),
      ),
      const SizedBox(height: 12),
      if (_alerts.isEmpty)
        _EmptyAlertsState(onAddAlert: () => _showAddAlertBottomSheet(context))
      else
        ..._alerts.asMap().entries.map((entry) {
          final index = entry.key;
          final a = entry.value;
          return EntranceAnimation(
            delay: Delay(200 + index * 60),
            offset: const Offset(0, 0.15),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey('${a.commodity}_${a.targetPrice}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.statusDanger,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                ),
                confirmDismiss: (direction) async {
                  HapticFeedback.lightImpact();
                  return await _showDeleteConfirmation(context, 'alert ${a.commodity}');
                },
                onDismissed: (_) {
                  setState(() => _alerts.removeAt(index));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Alert ${a.commodity} dihapus'),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'BATAL',
                        onPressed: () => setState(() => _alerts.insert(index, a)),
                      ),
                    ),
                  );
                },
                child: _AlertCard(
                  alert: a,
                  onToggle: (value) {
                    HapticFeedback.selectionClick();
                    setState(() => _alerts[index] = _alerts[index].copyWith(isActive: value));
                  },
                ),
              ),
            ),
          );
        }),
    ];
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus $name?', style: AppTheme.poppins(fontSize: 18)),
        content: Text(
          'Item ini akan dihapus dari daftar. Tindakan ini dapat dibatalkan dalam beberapa detik.',
          style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.statusDanger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showAddFavoriteBottomSheet(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    List<_CommodityOption> filtered = _commodityOptions;
    String selectedCategory = 'Semua';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Tambah Favorit', style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari komoditas...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppTheme.neutral100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setModalState(() {
                      filtered = _commodityOptions.where((c) =>
                        c.name.toLowerCase().contains(value.toLowerCase()) &&
                        (selectedCategory == 'Semua' || c.category == selectedCategory)
                      ).toList();
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: ['Semua', 'Sayur', 'Buah', 'Padi', 'Lainnya'].map((cat) {
                    final isSelected = cat == selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => setModalState(() => selectedCategory = cat),
                        backgroundColor: AppTheme.neutral100,
                        selectedColor: AppTheme.brandPrimary.withValues(alpha: 0.15),
                        labelStyle: AppTheme.inter(
                          fontSize: 13,
                          weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppTheme.brandPrimary : AppTheme.textDark,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(color: isSelected ? AppTheme.brandPrimary : AppTheme.neutral300),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: AppTheme.neutral300),
                            const SizedBox(height: 8),
                            Text('Komoditas tidak ditemukan', style: AppTheme.inter(fontSize: 16, color: AppTheme.neutral500)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          final c = filtered[index];
                          final isAlreadyFavorite = _favorites.any((f) => f.name == c.name);
                          return _CommodityOptionTile(
                            option: c,
                            isSelected: isAlreadyFavorite,
                            onTap: () {
                              if (isAlreadyFavorite) return;
                              HapticFeedback.selectionClick();
                              setState(() => _favorites.add(_Favorite(name: c.name, category: c.category)));
                              setModalState(() => filtered = filtered);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${c.name} ditambahkan ke favorit'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
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

  void _showManageFavoritesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Kelola Favorit', style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_favorites.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border_rounded, size: 48, color: AppTheme.neutral300),
                      const SizedBox(height: 8),
                      Text('Belum ada komoditas favorit', style: AppTheme.inter(fontSize: 16, color: AppTheme.neutral500)),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _favorites.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final f = _favorites[index];
                    return _FavoriteTile(
                      favorite: f,
                      onRemove: () {
                        HapticFeedback.lightImpact();
                        setState(() => _favorites.removeAt(index));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${f.name} dihapus dari favorit'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddAlertBottomSheet(BuildContext context) {
    final TextEditingController targetController = TextEditingController();
    String selectedCommodity = _commodityOptions.first.name;
    _AlertCondition selectedCondition = _AlertCondition.above;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Text('Tambah Alert Harga', style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCommodity,
                decoration: InputDecoration(
                  labelText: 'Komoditas',
                  filled: true,
                  fillColor: AppTheme.neutral100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _commodityOptions.map((c) => DropdownMenuItem(
                  value: c.name,
                  child: Text(c.name, style: AppTheme.inter(fontSize: 16)),
                )).toList(),
                onChanged: (value) => setModalState(() => selectedCommodity = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<_AlertCondition>(
                value: selectedCondition,
                decoration: InputDecoration(
                  labelText: 'Kondisi',
                  filled: true,
                  fillColor: AppTheme.neutral100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _AlertCondition.values.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.label, style: AppTheme.inter(fontSize: 16)),
                )).toList(),
                onChanged: (value) => setModalState(() => selectedCondition = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga Target (Rp/kg)',
                  filled: true,
                  fillColor: AppTheme.neutral100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Batal', style: AppTheme.inter(fontSize: 16, weight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final target = int.tryParse(targetController.text.replaceAll('.', ''));
                        if (target == null) return;
                        HapticFeedback.mediumImpact();
                        setState(() => _alerts.add(_Alert(
                          commodity: selectedCommodity,
                          condition: selectedCondition,
                          targetPrice: target,
                        )));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Alert ${selectedCondition.label.toLowerCase()} Rp ${target.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} untuk $selectedCommodity ditambahkan'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.brandPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Simpan', style: AppTheme.inter(fontSize: 16, weight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data Models & Defaults ──────────────────────────────────────────────
class _Favorite {
  final String name;
  final String category;
  _Favorite({required this.name, required this.category});
}

class _Alert {
  final String commodity;
  final _AlertCondition condition;
  final int targetPrice;
  bool isActive;
  _Alert({required this.commodity, required this.condition, required this.targetPrice, this.isActive = true});
  _Alert copyWith({bool? isActive}) => _Alert(
    commodity: commodity,
    condition: condition,
    targetPrice: targetPrice,
    isActive: isActive ?? this.isActive,
  );
}

enum _AlertCondition { above, below }
extension on _AlertCondition {
  String get label => this == _AlertCondition.above ? 'Di Atas' : 'Di Bawah';
}

class _CommodityOption {
  final String name;
  final String category;
  _CommodityOption(this.name, this.category);
}

final List<_CommodityOption> _commodityOptions = [
  _CommodityOption('Cabai Merah', 'Sayur'),
  _CommodityOption('Cabai Rawit', 'Sayur'),
  _CommodityOption('Bawang Merah', 'Sayur'),
  _CommodityOption('Bawang Putih', 'Sayur'),
  _CommodityOption('Tomat', 'Sayur'),
  _CommodityOption('Kentang', 'Sayur'),
  _CommodityOption('Wortel', 'Sayur'),
  _CommodityOption('Bayam', 'Sayur'),
  _CommodityOption('Kangkung', 'Sayur'),
  _CommodityOption('Cabai Hijau', 'Sayur'),
  _CommodityOption('Mangga', 'Buah'),
  _CommodityOption('Pisang', 'Buah'),
  _CommodityOption('Jeruk', 'Buah'),
  _CommodityOption('Apel', 'Buah'),
  _CommodityOption('Anggur', 'Buah'),
  _CommodityOption('Padi', 'Padi'),
  _CommodityOption('Jagung', 'Padi'),
  _CommodityOption('Kedelai', 'Lainnya'),
  _CommodityOption('Gula', 'Lainnya'),
  _CommodityOption('Minyak Goreng', 'Lainnya'),
];

final List<_Favorite> _defaultFavorites = [
  _Favorite(name: 'Cabai Merah', category: 'Sayur'),
  _Favorite(name: 'Bawang Merah', category: 'Sayur'),
  _Favorite(name: 'Bawang Putih', category: 'Sayur'),
];

final List<_Alert> _defaultAlerts = [
  _Alert(commodity: 'Cabai Merah', condition: _AlertCondition.above, targetPrice: 85000),
  _Alert(commodity: 'Bawang Merah', condition: _AlertCondition.below, targetPrice: 25000),
];

// ── UI Components ──────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w700, color: AppTheme.textDark)),
        const Spacer(),
        if (action != null)
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

class _EmptyFavoritesState extends StatelessWidget {
  final VoidCallback onAddFavorite;
  const _EmptyFavoritesState({required this.onAddFavorite});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 48, color: AppTheme.neutral300),
            const SizedBox(height: 12),
            Text('Belum ada komoditas favorit', style: AppTheme.poppins(fontSize: 16, color: AppTheme.neutral500)),
            const SizedBox(height: 8),
            Text('Tambahkan komoditas yang ingin dipantau', style: AppTheme.inter(fontSize: 13, color: AppTheme.neutral400)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAddFavorite,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text('Tambah Favorit', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAlertsState extends StatelessWidget {
  final VoidCallback onAddAlert;
  const _EmptyAlertsState({required this.onAddAlert});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, size: 48, color: AppTheme.neutral300),
            const SizedBox(height: 12),
            Text('Belum ada alert harga', style: AppTheme.poppins(fontSize: 16, color: AppTheme.neutral500)),
            const SizedBox(height: 8),
            Text('Dapatkan notifikasi saat harga mencapai target', style: AppTheme.inter(fontSize: 13, color: AppTheme.neutral400)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAddAlert,
              icon: const Icon(Icons.add_alert_rounded, size: 20),
              label: Text('Tambah Alert', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final _Favorite favorite;
  const _FavoriteCard({required this.favorite});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: AppTheme.softShadow(0.04),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.brandPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.grass_rounded, color: AppTheme.brandPrimary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(favorite.name, style: AppTheme.poppins(fontSize: 15, weight: FontWeight.w600, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(favorite.category, style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral500)),
              ],
            ),
          ),
          Icon(Icons.drag_handle_rounded, color: AppTheme.neutral300, size: 24),
        ],
      ),
    );
  }
}

class _FavoriteCardSkeleton extends StatelessWidget {
  const _FavoriteCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.neutral200, borderRadius: BorderRadius.circular(12))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 16, decoration: BoxDecoration(color: AppTheme.neutral200, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(width: 60, height: 12, decoration: BoxDecoration(color: AppTheme.neutral200, borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final _Alert alert;
  final ValueChanged<bool> onToggle;
  const _AlertCard({required this.alert, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: AppTheme.softShadow(0.04),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.statusWarning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(alert.condition == _AlertCondition.above ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: AppTheme.statusWarning, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(alert.commodity, style: AppTheme.poppins(fontSize: 15, weight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.statusWarning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(alert.condition.label, style: AppTheme.inter(fontSize: 10, weight: FontWeight.w600, color: AppTheme.statusWarning)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Target: Rp ${alert.targetPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                    style: AppTheme.inter(fontSize: 13, color: AppTheme.neutral500)),
              ],
            ),
          ),
          Switch.adaptive(
            value: alert.isActive,
            onChanged: onToggle,
            activeThumbColor: AppTheme.brandPrimary,
            activeTrackColor: AppTheme.brandPrimary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _CommodityOptionTile extends StatelessWidget {
  final _CommodityOption option;
  final bool isSelected;
  final VoidCallback onTap;
  const _CommodityOptionTile({required this.option, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.brandPrimary.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppTheme.brandPrimary : AppTheme.neutral200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.name, style: AppTheme.poppins(fontSize: 15, weight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 2),
                    Text(option.category, style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral500)),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: AppTheme.brandPrimary, size: 24)
              else
                const Icon(Icons.add_circle_outline_rounded, color: AppTheme.neutral400, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final _Favorite favorite;
  final VoidCallback onRemove;
  const _FavoriteTile({required this.favorite, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(favorite.name, style: AppTheme.poppins(fontSize: 15, weight: FontWeight.w600, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(favorite.category, style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral500)),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.statusDanger),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.statusDanger.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}