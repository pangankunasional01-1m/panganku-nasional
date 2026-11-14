import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore_for_file: unused_element

import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/go_pay_theme.dart';

/// Pantauan (Monitoring Tab) — GoPay style redesign
class MonitoringTabScreen extends ConsumerStatefulWidget {
  const MonitoringTabScreen({super.key});

  @override
  ConsumerState<MonitoringTabScreen> createState() => _MonitoringTabScreenState();
}

class _MonitoringTabScreenState extends ConsumerState<MonitoringTabScreen> {
  final List<_Favorite> _favorites = [
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
    final colors = GoPayColors();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.bgCream,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.lightImpact();
            _showAddAlertBottomSheet(context);
          },
          icon: const Icon(Icons.add_alert_rounded, size: 22),
          label: Text('Tambah Alert', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          backgroundColor: colors.brandPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: colors.brandPrimary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ===== HEADER (GoPay Style) =====
              SliverAppBar(
                expandedHeight: 160,
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

                    if (_isLoading)
                      _buildLoadingState()
                    else
                      _buildContent(colors),

                    // Bottom clearance for FAB
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

  /// Header content
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
                  'Pantauan Harga & Alert',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pantaukan harga komoditas favorit Anda',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Loading skeleton state
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        children: List.generate(3, (index) => Padding(
          padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
          child: _FavoriteCardSkeleton(),
        )),
      ),
    );
  }

  /// Main content
  Widget _buildContent(GoPayColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Favorites Section
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
                        color: colors.statusDanger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.delete_outline_rounded, color: colors.statusDanger, size: 24),
                    ),
                    confirmDismiss: (direction) async {
                      HapticFeedback.lightImpact();
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => _ConfirmDialog(
                          title: 'Hapus Favorit?',
                          content: 'Yakin ingin menghapus ${f.name} dari favorit?',
                          confirmText: 'Hapus',
                          confirmColor: colors.statusDanger,
                          onConfirm: () => Navigator.pop(context, true),
                          onCancel: () => Navigator.pop(context, false),
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
                          backgroundColor: colors.textDark,
                        ),
                      );
                    },
                    child: _FavoriteCard(favorite: f),
                  ),
                ),
              );
            }),

          // Alerts Section
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
        ],
      ),
    );
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

/// Favorite card skeleton
class _FavoriteCardSkeleton extends StatelessWidget {
  const _FavoriteCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.dividerLight),
      ),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: colors.neutral200.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12))),
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

  Widget _skeletonBox(double w, double h, double r) => Container(width: w, height: h, decoration: BoxDecoration(color: GoPayColors().neutral200.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(r)));
}

/// Favorite card
class _FavoriteCard extends StatelessWidget {
  final _Favorite favorite;

  const _FavoriteCard({required this.favorite});

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return Container(
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.brandPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_grocery_store_rounded, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(favorite.name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textDark)),
                const SizedBox(height: 4),
                Text(favorite.category, style: GoogleFonts.inter(fontSize: 12, color: colors.neutral500)),
                const SizedBox(height: 4),
                Text(favorite.price, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textDark)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.neutral300, size: 22),
        ],
      ),
    );
  }
}

/// Section header
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return Row(
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textDark)),
        if (action != null) ...[
          const Spacer(),
          TextButton(onPressed: onAction, child: Text(action!, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: colors.brandPrimary))),
        ],
      ],
    );
  }
}

/// Empty favorites state
class _EmptyFavoritesState extends StatelessWidget {
  final VoidCallback onAddFavorite;

  const _EmptyFavoritesState({required this.onAddFavorite});

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.dividerLight),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite_border_rounded, size: 48, color: colors.neutral400),
          const SizedBox(height: 12),
          Text('Belum ada favorit', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: colors.neutral500)),
          const SizedBox(height: 8),
          Text('Tambahkan komoditas favorit Anda untuk memantau harga', style: GoogleFonts.inter(fontSize: 13, color: colors.neutral400, height: 1.4), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onAddFavorite,
            icon: const Icon(Icons.add, size: 18),
            label: Text('Tambah Komoditas', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(foregroundColor: colors.brandPrimary, side: BorderSide(color: colors.brandPrimary, width: 1.5), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
          ),
        ],
      ),
    );
  }
}

/// Alert tile
class _AlertTile extends StatelessWidget {
  final _Alert alert;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  const _AlertTile({required this.alert, required this.onToggle, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return Dismissible(
      key: ValueKey('alert_${alert.name}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: colors.statusDanger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.delete_outline_rounded, color: colors.statusDanger, size: 24),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.lightImpact();
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => _ConfirmDialog(
            title: 'Hapus Alert?',
            content: 'Yakin ingin menghapus "${alert.name}"?',
            confirmText: 'Hapus',
            confirmColor: colors.statusDanger,
            onConfirm: () => Navigator.pop(context, true),
            onCancel: () => Navigator.pop(context, false),
          ),
        );
        return confirmed ?? false;
      },
      onDismissed: (direction) {
        onRemove();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alert dihapus'), action: SnackBarAction(label: 'Undo', onPressed: () => onRemove()), behavior: SnackBarBehavior.floating, backgroundColor: colors.textDark),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.dividerLight),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: alert.isActive ? colors.brandPrimary.withValues(alpha: 0.1) : colors.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Icon(alert.isActive ? Icons.notifications_active_rounded : Icons.notifications_off_rounded, size: 20, color: alert.isActive ? colors.brandPrimary : colors.neutral400)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textDark)),
                  const SizedBox(height: 2),
                  Text(
                    alert.condition == _AlertCondition.higher ? 'Naik di atas Rp ${_formatPrice(alert.targetPrice)}' : 'Turun di bawah Rp ${_formatPrice(alert.targetPrice)}',
                    style: GoogleFonts.inter(fontSize: 12, color: colors.neutral500),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: alert.isActive,
              onChanged: (_) => onToggle(),
              activeThumbColor: colors.brandPrimary,
              activeTrackColor: colors.brandPrimary.withValues(alpha: 0.3),
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

/// Confirm dialog
class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final Color confirmColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmDialog({
    required this.title,
    required this.content,
    required this.confirmText,
    required this.confirmColor,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
      content: Text(content, style: GoogleFonts.inter(fontSize: 14, color: colors.neutral500)),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Batal', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.neutral500)),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(confirmText, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: confirmColor)),
        ),
      ],
    );
  }
}

/// Alert sheet
class _AlertSheet extends StatelessWidget {
  final List<_Alert> alerts;
  final ValueChanged<int> onRemove;

  const _AlertSheet({required this.alerts, required this.onRemove});

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
              Text('Kelola Alert', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
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
                    Icon(Icons.notifications_off_outlined, size: 48, color: colors.neutral400),
                    const SizedBox(height: 12),
                    Text('Belum ada alert', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: colors.neutral500)),
                    const SizedBox(height: 8),
                    Text('Tambahkan alert harga untuk dimonitor', style: GoogleFonts.inter(fontSize: 13, color: colors.neutral400), textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          else
            Column(
              children: alerts.asMap().entries.map((entry) {
                final index = entry.key;
                final alert = entry.value;
                return _AlertSheetTile(
                  alert: alert,
                  onRemove: () => onRemove(index),
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

/// Add alert sheet
class _AddAlertSheet extends StatelessWidget {
  final void Function(String name, _AlertCondition condition, int targetPrice) onSave;

  const _AddAlertSheet({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    _AlertCondition selectedCondition = _AlertCondition.higher;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(GoPayRadius.header)),
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
              Text('Buat Alert Harga', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 20),
          _DialogTextField(
            controller: nameController,
            label: 'Nama Alert',
            prefixIcon: Icons.label_outline_rounded,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DialogTextField(
                  controller: priceController,
                  label: 'Target Harga',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: colors.dividerLight), borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<_AlertCondition>(
                    value: selectedCondition,
                    isExpanded: true,
                    style: GoogleFonts.inter(fontSize: 13, color: colors.textDark),
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
              Expanded(child: _DialogButton(
                text: 'Batal',
                type: _DialogButtonType.secondary,
                onPressed: () => Navigator.pop(context),
              )),
              const SizedBox(width: 12),
              Expanded(
                child: _DialogButton(
                  text: 'Simpan',
                  type: _DialogButtonType.primary,
                  onPressed: () {
                    final name = nameController.text.trim();
                    final price = int.tryParse(priceController.text.replaceAll('.', '')) ?? 0;
                    if (name.isNotEmpty && price > 0) {
                      HapticFeedback.lightImpact();
                      onSave(name, selectedCondition, price);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Manage favorites sheet
class _ManageFavoritesSheet extends StatelessWidget {
  final List<_Favorite> favorites;
  final void Function(_Favorite) onAdd;
  final void Function(int) onRemove;

  const _ManageFavoritesSheet({required this.favorites, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    final searchController = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(GoPayRadius.header)),
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
              Text('Kelola Favorit', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 20),
          _DialogTextField(
            controller: searchController,
            label: 'Cari komoditas',
            prefixIcon: Icons.search_rounded,
          ),
          const SizedBox(height: 16),
          if (favorites.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(children: [Icon(Icons.star_border_rounded, size: 48, color: colors.neutral400), const SizedBox(height: 12), Text('Belum ada favorit', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: colors.neutral500)), const SizedBox(height: 8), Text('Tambahkan komoditas untuk memantau harga', style: GoogleFonts.inter(fontSize: 13, color: colors.neutral400), textAlign: TextAlign.center)]),
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
                  return _ManageFavoriteTile(
                    favorite: f,
                    onRemove: () => onRemove(index),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          _DialogButton(
            text: 'Tambah Favorit',
            type: _DialogButtonType.secondary,
            onPressed: () => _showAddFavoriteDialog(context),
            icon: Icons.add,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  void _showAddFavoriteDialog(BuildContext context) {
    final colors = GoPayColors();
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: Text('Tambah Favorit', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)), content: Column(mainAxisSize: MainAxisSize.min, children: [_DialogTextField(controller: nameController, label: 'Nama', prefixIcon: Icons.label_outline_rounded), const SizedBox(height: 12), _DialogTextField(controller: categoryController, label: 'Kategori', prefixIcon: Icons.category_outlined), const SizedBox(height: 12), _DialogTextField(controller: priceController, label: 'Harga (Rp)', prefixIcon: Icons.attach_money_rounded, keyboardType: TextInputType.number)]) , actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.neutral500))), _DialogButton(text: 'Simpan', type: _DialogButtonType.primary, onPressed: () { if (nameController.text.isNotEmpty && categoryController.text.isNotEmpty) { onAdd(_Favorite(name: nameController.text, category: categoryController.text, price: 'Rp ${priceController.text} / kg')); Navigator.pop(context); Navigator.pop(context); } }) ]));
  }
}

/// Manage favorite tile - extracted to avoid const expression issues
class _ManageFavoriteTile extends StatelessWidget {
  final _Favorite favorite;
  final VoidCallback onRemove;

  const _ManageFavoriteTile({
    required this.favorite,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return Dismissible(
      key: ValueKey('manage_fav_${favorite.name}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: colors.statusDanger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.delete_outline_rounded, color: colors.statusDanger, size: 24),
      ),
      confirmDismiss: (direction) async => (await showDialog<bool>(context: context, builder: (context) => _ConfirmDialog(
        title: 'Hapus?',
        content: 'Hapus ${favorite.name}?',
        confirmText: 'Hapus',
        confirmColor: colors.statusDanger,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ))) ?? false,
      onDismissed: (direction) => onRemove(),
      child: _buildManageFavoriteTileContent(context, favorite),
    );
  }

  Widget _buildManageFavoriteTileContent(BuildContext context, _Favorite favorite) {
    final colors = GoPayColors();
    return Container(
      key: UniqueKey(),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.neutral100, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.dividerLight)),
      child: Row(children: [
        _buildManageFavoriteIcon(colors),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(favorite.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textDark)), Text(favorite.category, style: GoogleFonts.inter(fontSize: 12, color: colors.neutral500))])),
      ]),
    );
  }

  Widget _buildManageFavoriteIcon(GoPayColors colors) {
    return Container(
      key: UniqueKey(),
      width: 40, height: 40, decoration: BoxDecoration(color: colors.brandPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.local_grocery_store_rounded, color: GoPayColors().brandPrimary, size: 20));
  }
}

/// Add favorite sheet
class _AddFavoriteSheet extends StatelessWidget {
  final void Function(_Favorite) onSave;

  const _AddFavoriteSheet({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(GoPayRadius.header)),
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
              Text('Tambah Favorit', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 20),
          _DialogTextField(controller: nameController, label: 'Nama Komoditas', prefixIcon: Icons.label_outline_rounded),
          const SizedBox(height: 12),
          _DialogTextField(controller: categoryController, label: 'Kategori', prefixIcon: Icons.category_outlined),
          const SizedBox(height: 12),
          _DialogTextField(controller: priceController, label: 'Harga (Rp)', prefixIcon: Icons.attach_money_rounded, keyboardType: TextInputType.number),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _DialogButton(text: 'Batal', type: _DialogButtonType.secondary, onPressed: () => Navigator.pop(context))),
              const SizedBox(width: 12),
              Expanded(child: _DialogButton(text: 'Simpan', type: _DialogButtonType.primary, onPressed: () { if (nameController.text.isNotEmpty && categoryController.text.isNotEmpty) { HapticFeedback.lightImpact(); onSave(_Favorite(name: nameController.text, category: categoryController.text, price: 'Rp ${priceController.text} / kg')); } })),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dialog text field
class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final TextInputType? keyboardType;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: colors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 14, color: colors.neutral400),
        prefixIcon: Icon(prefixIcon, color: colors.neutral400, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.dividerLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.dividerLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.brandPrimary, width: 1.5),
        ),
        filled: true,
        fillColor: colors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

/// Dialog button types
enum _DialogButtonType { primary, secondary }

/// Dialog button
class _DialogButton extends StatelessWidget {
  final String text;
  final _DialogButtonType type;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool fullWidth;

  const _DialogButton({
    required this.text,
    required this.type,
    required this.onPressed,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    final isPrimary = type == _DialogButtonType.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        splashColor: isPrimary ? colors.brandPrimary.withValues(alpha: 0.12) : colors.neutral200,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary ? colors.brandPrimary : colors.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: isPrimary ? null : Border.all(color: colors.dividerLight),
            boxShadow: isPrimary ? [GoPayShadows.cardShadow()] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: isPrimary ? Colors.white : colors.textDark),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : colors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Favorite model
class _Favorite {
  final String name;
  final String category;
  final String price;

  const _Favorite({required this.name, required this.category, required this.price});
}

/// Alert model
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

/// Alert sheet tile - extracted to avoid const expression issues
class _AlertSheetTile extends StatelessWidget {
  final _Alert alert;
  final VoidCallback onRemove;

  const _AlertSheetTile({
    required this.alert,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return Dismissible(
      key: ValueKey('alert_sheet_${alert.name}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: colors.statusDanger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.delete_outline_rounded, color: colors.statusDanger, size: 24),
      ),
      confirmDismiss: (direction) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => _ConfirmDialog(
            title: 'Hapus Alert?',
            content: 'Yakin ingin menghapus "${alert.name}"?',
            confirmText: 'Hapus',
            confirmColor: colors.statusDanger,
            onConfirm: () => Navigator.pop(context, true),
            onCancel: () => Navigator.pop(context, false),
          ),
        );
        return confirmed ?? false;
      },
      onDismissed: (direction) => onRemove(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colors.neutral100, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.dividerLight)),
        child: Row(
          children: [
            Switch.adaptive(value: alert.isActive, onChanged: (_) {}, activeThumbColor: colors.brandPrimary, activeTrackColor: colors.brandPrimary.withValues(alpha: 0.3)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(alert.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textDark)), const SizedBox(height: 2), Text(alert.condition == _AlertCondition.higher ? 'Naik di atas Rp ${_formatPrice(alert.targetPrice)}' : 'Turun di bawah Rp ${_formatPrice(alert.targetPrice)}', style: GoogleFonts.inter(fontSize: 12, color: colors.neutral500))])),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
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