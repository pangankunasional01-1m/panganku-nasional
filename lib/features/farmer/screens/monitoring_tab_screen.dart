import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pangan_sliver_header.dart';

class MonitoringTabScreen extends ConsumerStatefulWidget {
  const MonitoringTabScreen({super.key});

  @override
  ConsumerState<MonitoringTabScreen> createState() => _MonitoringTabScreenState();
}

class _MonitoringTabScreenState extends ConsumerState<MonitoringTabScreen> {
  List<_Favorite> _favorites = [
    const _Favorite(name: 'Cabai', category: 'Sayuran', price: 'Rp 45.000 / kg'),
    const _Favorite(name: 'Bawang Merah', category: 'Bumbu', price: 'Rp 32.000 / kg'),
    const _Favorite(name: 'Beras', category: 'Pangan Pokok', price: 'Rp 12.500 / kg'),
  ];
  List<_Alert> _alerts = [
    _Alert(name: 'Harga Cabai Naik', condition: _AlertCondition.higher, targetPrice: 50000),
    _Alert(name: 'Harga Jagung Turun', condition: _AlertCondition.lower, targetPrice: 7000),
  ];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                collapsedTitle: 'Pantauan Harga',
                expandedContent: EntranceAnimation(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pantauan Harga & Alert',
                        style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pantaukan harga komoditas favorit Anda',
                        style: AppTheme.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildContentSliver() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      sliver: SliverList(delegate: SliverChildListDelegate(_buildContentList())),
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
                key: ValueKey('fav_${f.name}_$index'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.statusDanger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.delete_outline_rounded, color: AppTheme.statusDanger, size: 24),
                ),
                confirmDismiss: (direction) async {
                  HapticFeedback.lightImpact();
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text('Hapus Favorit?', style: AppTheme.poppins(fontSize: 18)),
                      content: Text(
                        'Yakin ingin menghapus ${f.name} dari favorit?',
                        style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500))),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus', style: AppTheme.inter(fontSize: 14, color: AppTheme.statusDanger))),
                      ],
                    ),
                  );
                  return confirmed ?? false;
                },
                onDismissed: (direction) {
                  setState(() => _favorites.removeAt(index));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${f.name} dihapus dari favorit'),
                      action: SnackBarAction(label: 'Undo', onPressed: () => setState(() => _favorites.insert(index, f))),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.textDark,
                    ),
                  );
                },
                child: _FavoriteCard(favorite: f),
              ),
            ),
          );
        }),
      if (_alerts.isNotEmpty) ...[
        const SizedBox(height: 12),
        _SectionHeader(
          title: 'Alert Harga',
          action: _alerts.isEmpty ? null : 'Kelola',
          onAction: _alerts.isEmpty ? null : () => _showAlertBottomSheet(context),
        ),
        const SizedBox(height: 12),
        ..._alerts.asMap().entries.map((entry) {
          final index = entry.key;
          final alert = entry.value;
          return _AlertTile(
            alert: alert,
            onToggle: () {
              setState(() {
                _alerts = List.from(_alerts);
                _alerts[index] = _Alert(
                  name: alert.name,
                  condition: alert.condition,
                  targetPrice: alert.targetPrice,
                  isActive: !alert.isActive,
                );
              });
            },
            onRemove: () => setState(() => _alerts.removeAt(index)),
          );
        }),
      ],
    ];
  }

  void _showAddAlertBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddAlertSheet(onSave: (name, condition, targetPrice) {
        setState(() {
          _alerts.add(_Alert(name: name, condition: condition, targetPrice: targetPrice, isActive: true));
        });
        Navigator.pop(context);
      }),
    );
  }

  void _showManageFavoritesBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManageFavoritesSheet(
        favorites: _favorites,
        onAdd: (fav) => setState(() => _favorites.add(fav)),
        onRemove: (index) => setState(() => _favorites.removeAt(index)),
      ),
    );
  }

  void _showAddFavoriteBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddFavoriteSheet(onSave: (fav) {
        setState(() => _favorites.add(fav));
        Navigator.pop(context);
      }),
    );
  }

  void _showAlertBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AlertSheet(
        alerts: _alerts,
        onRemove: (index) => setState(() => _alerts.removeAt(index)),
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
          Container(width: 48, height: 48, decoration: BoxDecoration(color: AppTheme.neutral200.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(120, 20, 4),
                const SizedBox(height: 6),
                _skeletonBox(80, 16, 4),
                const SizedBox(height: 6),
                _skeletonBox(100, 18, 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox(double w, double h, double r) => Container(width: w, height: h, decoration: BoxDecoration(color: AppTheme.neutral200.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(r)));
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
        boxShadow: AppTheme.softShadow(0.03),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.brandPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_grocery_store_rounded, color: AppTheme.brandPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(favorite.name, style: AppTheme.poppins(fontSize: 15, weight: FontWeight.w700, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Text(favorite.category, style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral500)),
                const SizedBox(height: 4),
                Text(favorite.price, style: AppTheme.inter(fontSize: 13, weight: FontWeight.w700, color: AppTheme.textDark)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppTheme.neutral300, size: 22),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTheme.poppins(fontSize: 17, weight: FontWeight.w700, color: AppTheme.textDark)),
        if (action != null) ...[
          const Spacer(),
          TextButton(onPressed: onAction, child: Text(action!, style: AppTheme.inter(fontSize: 13, weight: FontWeight.w700, color: AppTheme.brandPrimary))),
        ],
      ],
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  final VoidCallback onAddFavorite;

  const _EmptyFavoritesState({required this.onAddFavorite});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite_border_rounded, size: 48, color: AppTheme.neutral400),
          const SizedBox(height: 12),
          Text('Belum ada favorit', style: AppTheme.poppins(fontSize: 15, weight: FontWeight.w600, color: AppTheme.neutral500)),
          const SizedBox(height: 8),
          Text('Tambahkan komoditas favorit Anda untuk memantau harga', style: AppTheme.inter(fontSize: 13, color: AppTheme.neutral400, height: 1.4), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onAddFavorite,
            icon: const Icon(Icons.add, size: 18),
            label: Text('Tambah Komoditas', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.brandPrimary, side: const BorderSide(color: AppTheme.brandPrimary, width: 1.5), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final _Alert alert;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  const _AlertTile({required this.alert, required this.onToggle, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('alert_${alert.name}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppTheme.statusDanger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.delete_outline_rounded, color: AppTheme.statusDanger, size: 24),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.lightImpact();
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Hapus Alert?', style: AppTheme.poppins(fontSize: 18)),
            content: Text('Yakin ingin menghapus "${alert.name}"?', style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500))),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus', style: AppTheme.inter(fontSize: 14, color: AppTheme.statusDanger))),
            ],
          ),
        );
        return confirmed ?? false;
      },
      onDismissed: (direction) {
        onRemove();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alert dihapus'), action: SnackBarAction(label: 'Undo', onPressed: () => onRemove()), behavior: SnackBarBehavior.floating, backgroundColor: AppTheme.textDark),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.neutral200),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: alert.isActive ? AppTheme.brandPrimary.withValues(alpha: 0.1) : AppTheme.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Icon(alert.isActive ? Icons.notifications_active_rounded : Icons.notifications_off_rounded, size: 20, color: alert.isActive ? AppTheme.brandPrimary : AppTheme.neutral400)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.name, style: AppTheme.poppins(fontSize: 15, weight: FontWeight.w600, color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(
                    alert.condition == _AlertCondition.higher ? 'Naik di atas Rp ${_formatPrice(alert.targetPrice)}' : 'Turun di bawah Rp ${_formatPrice(alert.targetPrice)}',
                    style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral500),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: alert.isActive,
              onChanged: (_) => onToggle(),
              activeThumbColor: AppTheme.brandPrimary,
              activeTrackColor: AppTheme.brandPrimary.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

class _AlertSheet extends StatelessWidget {
  final List<_Alert> alerts;
  final ValueChanged<int> onRemove;

  const _AlertSheet({required this.alerts, required this.onRemove});

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
              Text('Kelola Alert', style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w700, color: AppTheme.textDark)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 20),
          if (alerts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 48, color: AppTheme.neutral400),
                    const SizedBox(height: 12),
                    Text('Belum ada alert', style: AppTheme.poppins(fontSize: 15, weight: FontWeight.w600, color: AppTheme.neutral500)),
                    const SizedBox(height: 8),
                    Text('Tambahkan alert harga untuk dimonitor', style: AppTheme.inter(fontSize: 13, color: AppTheme.neutral400), textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          else
            Column(
              children: alerts.asMap().entries.map((entry) {
                final index = entry.key;
                final alert = entry.value;
                return Dismissible(
                  key: ValueKey('alert_sheet_${alert.name}'),
                  direction: DismissDirection.endToStart,
                  background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: AppTheme.statusDanger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.delete_outline_rounded, color: AppTheme.statusDanger, size: 24)),
                  confirmDismiss: (direction) async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: Text('Hapus Alert?', style: AppTheme.poppins(fontSize: 18)), content: Text('Yakin ingin menghapus "${alert.name}"?', style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500)), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500))), TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus', style: AppTheme.inter(fontSize: 14, color: AppTheme.statusDanger)))]),
                    );
                    return confirmed ?? false;
                  },
                  onDismissed: (direction) => onRemove(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppTheme.neutral100, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.neutral200)),
                    child: Row(
                      children: [
                        Switch.adaptive(value: alert.isActive, onChanged: (_) {}, activeThumbColor: AppTheme.brandPrimary, activeTrackColor: AppTheme.brandPrimary.withValues(alpha: 0.3)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(alert.name, style: AppTheme.poppins(fontSize: 14, weight: FontWeight.w600, color: AppTheme.textDark)), const SizedBox(height: 2), Text(alert.condition == _AlertCondition.higher ? 'Naik di atas Rp ${_formatPrice(alert.targetPrice)}' : 'Turun di bawah Rp ${_formatPrice(alert.targetPrice)}', style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral500))])),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

class _AddAlertSheet extends StatelessWidget {
  final void Function(String name, _AlertCondition condition, int targetPrice) onSave;

  const _AddAlertSheet({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    _AlertCondition selectedCondition = _AlertCondition.higher;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Buat Alert Harga', style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w700, color: AppTheme.textDark)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Nama Alert', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            style: AppTheme.inter(fontSize: 14, color: AppTheme.textDark),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Target Harga', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixText: 'Rp '),
                  keyboardType: TextInputType.number,
                  style: AppTheme.inter(fontSize: 14, color: AppTheme.textDark),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: AppTheme.neutral200), borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<_AlertCondition>(
                    value: selectedCondition,
                    isExpanded: true,
                    style: AppTheme.inter(fontSize: 13, color: AppTheme.textDark),
                    items: const [
                      DropdownMenuItem(value: _AlertCondition.higher, child: Text('Naik di atas')),
                      DropdownMenuItem(value: _AlertCondition.lower, child: Text('Turun di bawah')),
                    ],
                    onChanged: (value) {
                      if (value != null) selectedCondition = value;
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.brandPrimary, side: const BorderSide(color: AppTheme.brandPrimary, width: 1.5), padding: const EdgeInsets.symmetric(vertical: 16)), child: Text('Batal', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)))),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final price = int.tryParse(priceController.text.replaceAll('.', '')) ?? 0;
                    if (name.isNotEmpty && price > 0) {
                      HapticFeedback.lightImpact();
                      onSave(name, selectedCondition, price);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text('Simpan', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ManageFavoritesSheet extends StatelessWidget {
  final List<_Favorite> favorites;
  final void Function(_Favorite) onAdd;
  final void Function(int) onRemove;

  const _ManageFavoritesSheet({required this.favorites, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Kelola Favorit', style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w700, color: AppTheme.textDark)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: searchController,
            decoration: InputDecoration(labelText: 'Cari komoditas', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.search_rounded)),
            style: AppTheme.inter(fontSize: 14, color: AppTheme.textDark),
          ),
          const SizedBox(height: 16),
          if (favorites.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(children: [Icon(Icons.star_border_rounded, size: 48, color: AppTheme.neutral400), const SizedBox(height: 12), Text('Belum ada favorit', style: AppTheme.poppins(fontSize: 15, weight: FontWeight.w600, color: AppTheme.neutral500)), const SizedBox(height: 8), Text('Tambahkan komoditas untuk memantau harga', style: AppTheme.inter(fontSize: 13, color: AppTheme.neutral400), textAlign: TextAlign.center)]),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: favorites.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final f = favorites[index];
                  return Dismissible(
                    key: ValueKey('manage_fav_${f.name}'),
                    direction: DismissDirection.endToStart,
                    background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: AppTheme.statusDanger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.delete_outline_rounded, color: AppTheme.statusDanger, size: 24)),
                    confirmDismiss: (direction) async => (await showDialog<bool>(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: Text('Hapus?', style: AppTheme.poppins(fontSize: 18)), content: Text('Hapus ${f.name}?', style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500)), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500))), TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus', style: AppTheme.inter(fontSize: 14, color: AppTheme.statusDanger)))]))) ?? false,
                    onDismissed: (direction) => onRemove(index),
                    child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.neutral100, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.neutral200)), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.brandPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.local_grocery_store_rounded, color: AppTheme.brandPrimary, size: 20)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(f.name, style: AppTheme.poppins(fontSize: 14, weight: FontWeight.w600, color: AppTheme.textDark)), Text(f.category, style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral500))]))])),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showAddFavoriteDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: Text('Tambah Favorit', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.brandPrimary, side: const BorderSide(color: AppTheme.brandPrimary, width: 1.5), padding: const EdgeInsets.symmetric(vertical: 14), minimumSize: const Size(double.infinity, 0)),
          ),
        ],
      ),
    );
  }

  void _showAddFavoriteDialog(BuildContext context) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: Text('Tambah Favorit', style: AppTheme.poppins(fontSize: 18)), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nama', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 12), TextField(controller: categoryController, decoration: InputDecoration(labelText: 'Kategori', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 12), TextField(controller: priceController, decoration: InputDecoration(labelText: 'Harga (Rp)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number)]) , actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500))), ElevatedButton(onPressed: () { if (nameController.text.isNotEmpty && categoryController.text.isNotEmpty) { onAdd(_Favorite(name: nameController.text, category: categoryController.text, price: 'Rp ${priceController.text} / kg')); Navigator.pop(context); Navigator.pop(context); } }, child: Text('Simpan', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600))) ]));
  }
}

class _AddFavoriteSheet extends StatelessWidget {
  final void Function(_Favorite) onSave;

  const _AddFavoriteSheet({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Tambah Favorit', style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w700, color: AppTheme.textDark)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nama Komoditas', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), style: AppTheme.inter(fontSize: 14, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          TextField(controller: categoryController, decoration: InputDecoration(labelText: 'Kategori', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), style: AppTheme.inter(fontSize: 14, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          TextField(controller: priceController, decoration: InputDecoration(labelText: 'Harga (Rp)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixText: 'Rp '), keyboardType: TextInputType.number, style: AppTheme.inter(fontSize: 14, color: AppTheme.textDark)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.brandPrimary, side: const BorderSide(color: AppTheme.brandPrimary, width: 1.5), padding: const EdgeInsets.symmetric(vertical: 16)), child: Text('Batal', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: () { if (nameController.text.isNotEmpty && categoryController.text.isNotEmpty) { HapticFeedback.lightImpact(); onSave(_Favorite(name: nameController.text, category: categoryController.text, price: 'Rp ${priceController.text} / kg')); } }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)), child: Text('Simpan', style: AppTheme.inter(fontSize: 14, weight: FontWeight.w600)))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Favorite {
  final String name;
  final String category;
  final String price;

  const _Favorite({required this.name, required this.category, required this.price});
}

class _Alert {
  final String name;
  final _AlertCondition condition;
  final int targetPrice;
  final bool isActive;

  const _Alert({
    required this.name,
    required this.condition,
    required this.targetPrice,
    this.isActive = false,
  });
}

enum _AlertCondition { higher, lower }