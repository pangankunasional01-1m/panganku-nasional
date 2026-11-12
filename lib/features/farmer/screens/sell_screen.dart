import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/data/commodities.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_button.dart';
import '../../../core/widgets/p_chip_badge.dart';
import '../../../core/widgets/p_connection_banner.dart';

enum _ListingStatus { aktif, dipesan, habis }

class _Listing {
  final String id;
  final String commodity;
  final IconData icon;
  final Color tint;
  final int qtyKg;
  final int soldKg;
  final int pricePerKg;
  final _ListingStatus status;
  _Listing({
    required this.id,
    required this.commodity,
    required this.icon,
    required this.tint,
    required this.qtyKg,
    required this.soldKg,
    required this.pricePerKg,
    required this.status,
  });
}

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _commodity = 'Cabai Merah';
  PSyncState _sync = PSyncState.synced;
  bool _saving = false;

  late final List<_Listing> _listings = [
    _Listing(
      id: '1',
      commodity: 'Cabai Merah',
      icon: Icons.local_fire_department_rounded,
      tint: AppTheme.statusDanger,
      qtyKg: 80,
      soldKg: 25,
      pricePerKg: 45000,
      status: _ListingStatus.aktif,
    ),
    _Listing(
      id: '2',
      commodity: 'Bawang Merah',
      icon: Icons.spa_rounded,
      tint: const Color(0xFFB0539A),
      qtyKg: 120,
      soldKg: 120,
      pricePerKg: 32000,
      status: _ListingStatus.habis,
    ),
    _Listing(
      id: '3',
      commodity: 'Beras',
      icon: Icons.grain_rounded,
      tint: const Color(0xFFD99A1E),
      qtyKg: 200,
      soldKg: 40,
      pricePerKg: 12500,
      status: _ListingStatus.dipesan,
    ),
  ];

  static List<String> get _commodityNames =>
      Commodities.panganPokok.map((c) => c.name).toList();

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  String _rp(int v) {
    final s = v.toString();
    return 'Rp ${s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
  }

  Future<void> _publish() async {
    final qty = int.tryParse(_qtyCtrl.text.trim());
    final price = int.tryParse(_priceCtrl.text.trim());
    if (qty == null || price == null || qty <= 0 || price <= 0 || _saving) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _sync = PSyncState.offline;
    });
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _sync = PSyncState.pending);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final meta = Commodities.byName(_commodity);
    setState(() {
      _sync = PSyncState.synced;
      _saving = false;
      _listings.insert(
        0,
        _Listing(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          commodity: _commodity,
          icon: meta.icon,
          tint: meta.tint,
          qtyKg: qty,
          soldKg: 0,
          pricePerKg: price,
          status: _ListingStatus.aktif,
        ),
      );
    });
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.brandPrimaryLight,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Listing aktif: $_commodity · $qty kg @ ${_rp(price)}/kg',
                ),
              ),
            ],
          ),
        ),
      );
    _qtyCtrl.clear();
    _priceCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final active = _listings
        .where((l) => l.status != _ListingStatus.habis)
        .length;
    final revenue = _listings.fold<int>(
      0,
      (s, l) => s + l.soldKg * l.pricePerKg,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Jual Hasil Panen')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          EntranceAnimation(child: PConnectionBanner(state: _sync)),
          const SizedBox(height: 16),
          EntranceAnimation(
            delay: const Delay(80),
            scaleFrom: 0.96,
            child: _summary(revenue, active),
          ),
          const SizedBox(height: 16),
          EntranceAnimation(delay: const Delay(160), child: _form()),
          const SizedBox(height: 16),
          EntranceAnimation(delay: const Delay(240), child: _listingSection()),
        ],
      ),
    );
  }

  Widget _summary(int revenue, int active) {
    return Row(
      children: [
        Expanded(
          child: _miniStat(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Pendapatan',
            value: _rp(revenue),
            tint: AppTheme.brandPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _miniStat(
            icon: Icons.storefront_rounded,
            label: 'Listing aktif',
            value: '$active',
            tint: AppTheme.brandAccent,
          ),
        ),
      ],
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: tint, size: 22),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: tabularNumber(
                fontSize: 20,
                weight: FontWeight.w800,
                color: tint,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral400),
          ),
        ],
      ),
    );
  }

  Widget _form() {
    return _Panel(
      title: 'Buat Listing Baru',
      icon: Icons.add_shopping_cart_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komoditas',
            style: AppTheme.inter(
              fontSize: 13,
              weight: FontWeight.w600,
              color: AppTheme.neutral500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _commodityNames
                .map((name) => _SellPick(
                      name: name,
                      selected: _commodity == name,
                      onTap: () => setState(() => _commodity = name),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: tabularNumber(fontSize: 18),
                  decoration: const InputDecoration(
                    labelText: 'Stok (kg)',
                    hintText: '80',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: tabularNumber(fontSize: 18),
                  decoration: const InputDecoration(
                    labelText: 'Harga/kg (Rp)',
                    hintText: '45000',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PButton(
            text: 'Pasang Listing',
            icon: Icons.campaign_outlined,
            isLoading: _saving,
            onPressed: _publish,
          ),
        ],
      ),
    );
  }

  Widget _listingSection() {
    return _Panel(
      title: 'Listing Saya',
      icon: Icons.list_alt_rounded,
      child: Column(
        children: [
          for (var i = 0; i < _listings.length; i++) ...[
            if (i > 0) const Divider(height: 22),
            _listingTile(_listings[i]),
          ],
        ],
      ),
    );
  }

  Widget _listingTile(_Listing l) {
    final (statusLabel, statusType) = switch (l.status) {
      _ListingStatus.aktif => ('AKTIF', PStatusType.success),
      _ListingStatus.dipesan => ('DIPESAN', PStatusType.warning),
      _ListingStatus.habis => ('HABIS', PStatusType.danger),
    };
    final progress = l.qtyKg == 0 ? 0.0 : (l.soldKg / l.qtyKg).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Commodities.imageFor(l.commodity, size: 44, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.commodity,
                    style: AppTheme.poppins(
                      fontSize: 15,
                      weight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_rp(l.pricePerKg)} / kg · ${l.qtyKg} kg',
                    style: AppTheme.inter(
                      fontSize: 12,
                      color: AppTheme.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            PStatusBadge(type: statusType, label: statusLabel),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: AppTheme.neutral100,
            valueColor: AlwaysStoppedAnimation<Color>(
              l.status == _ListingStatus.habis ? AppTheme.neutral400 : l.tint,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Terjual ${l.soldKg}/${l.qtyKg} kg',
          style: AppTheme.inter(
            fontSize: 11,
            weight: FontWeight.w500,
            color: AppTheme.neutral400,
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _Panel({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(color: cs.surface, radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 19, color: AppTheme.brandPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.poppins(
                    fontSize: 16,
                    weight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SellPick extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;
  const _SellPick(
      {required this.name, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Commodities.byName(name);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? c.tint.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? c.tint : AppTheme.neutral200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Commodities.imageFor(name, size: 44, radius: 10),
            const SizedBox(height: 4),
            Text(
              name.split(' ').first,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.inter(
                fontSize: 11,
                weight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? c.tint : AppTheme.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
