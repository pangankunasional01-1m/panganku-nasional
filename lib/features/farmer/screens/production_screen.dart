import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/data/commodities.dart';
import '../../../core/data/pangan_catalog.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_button.dart';
import '../../../core/widgets/p_chip_badge.dart';
import '../../../core/widgets/p_connection_banner.dart';

enum ProductionSector { darat, ternak, laut }

extension on ProductionSector {
  String get label => switch (this) {
        ProductionSector.darat => 'Darat (Tanaman)',
        ProductionSector.ternak => 'Ternak/Daging',
        ProductionSector.laut => 'Laut & Ikan',
      };
  String get verb => switch (this) {
        ProductionSector.darat => 'panen',
        ProductionSector.ternak => 'hasil ternak',
        ProductionSector.laut => 'tangkapan/panen',
      };
  IconData get icon => switch (this) {
        ProductionSector.darat => Icons.agriculture_rounded,
        ProductionSector.ternak => Icons.pets_rounded,
        ProductionSector.laut => Icons.set_meal_rounded,
      };
  Color get tint => switch (this) {
        ProductionSector.darat => AppTheme.brandPrimary,
        ProductionSector.ternak => const Color(0xFFB85C38),
        ProductionSector.laut => const Color(0xFF2E7D9A),
      };
  List<CommodityInfo> get items => switch (this) {
        ProductionSector.darat => PanganCatalog.items
            .where((c) =>
                c.category == 'Serealia & Umbi' ||
                c.category == 'Sayuran' ||
                c.category == 'Buah' ||
                c.category == 'Kacang-kacangan')
            .toList(),
        ProductionSector.ternak => PanganCatalog.items
            .where((c) => c.category == 'Daging, Telur, Susu')
            .toList(),
        ProductionSector.laut => PanganCatalog.items
            .where((c) => c.category == 'Ikan & Laut')
            .toList(),
      };
  List<String> get units => switch (this) {
        ProductionSector.darat => const ['kg', 'ton', 'karung', 'ikat'],
        ProductionSector.ternak => const ['kg', 'ekor', 'butir', 'liter'],
        ProductionSector.laut => const ['kg', 'ton', 'ekor', 'keranjang'],
      };
}

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key, this.initialSector});
  final ProductionSector? initialSector;

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionRecord {
  final ProductionSector sector;
  final String commodity;
  final String qty;
  final String unit;
  final String date;
  final String quality;
  _ProductionRecord(this.sector, this.commodity, this.qty, this.unit, this.date,
      this.quality);
}

class _ProductionScreenState extends State<ProductionScreen> {
  final _qtyCtrl = TextEditingController();
  late ProductionSector _sector;
  String _commodity = '';
  String _unit = 'kg';
  String _quality = 'Bagus';
  DateTime _date = DateTime.now();
  PSyncState _sync = PSyncState.synced;
  bool _saving = false;

  final List<_ProductionRecord> _records = [
    _ProductionRecord(ProductionSector.darat, 'Cabai Merah', '120', 'kg',
        '5 Nov 2026', 'Bagus'),
    _ProductionRecord(ProductionSector.ternak, 'Ayam', '30', 'ekor',
        '4 Nov 2026', 'Bagus'),
    _ProductionRecord(ProductionSector.laut, 'Ikan Lele', '80', 'kg',
        '3 Nov 2026', 'Sedang'),
  ];

  static const _qualities = ['Bagus', 'Sedang', 'Perlu sortir'];

  @override
  void initState() {
    super.initState();
    _sector = widget.initialSector ?? ProductionSector.darat;
    _syncCommodity();
  }

  void _syncCommodity() {
    final items = _sector.items;
    if (items.isEmpty) {
      _commodity = 'Lainnya';
    } else if (!items.any((c) => c.name == _commodity)) {
      _commodity = items.first.name;
    }
    final units = _sector.units;
    if (!units.contains(_unit)) _unit = units.first;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    const m = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${m[d.month]} ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      helpText: 'Tanggal',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_qtyCtrl.text.trim().isEmpty || _saving) return;
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
    setState(() {
      _sync = PSyncState.synced;
      _saving = false;
      _records.insert(
        0,
        _ProductionRecord(_sector, _commodity, _qtyCtrl.text.trim(), _unit,
            _fmtDate(_date), _quality),
      );
    });
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Tersimpan: ${_sector.label} · $_commodity · ${_qtyCtrl.text} $_unit'),
      ));
    _qtyCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final view = _records.where((r) => r.sector == _sector).toList();
    final totalKg = view
        .where((r) => r.unit == 'kg')
        .fold<int>(0, (s, r) => s + (int.tryParse(r.qty) ?? 0));
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Produksi')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          EntranceAnimation(child: PConnectionBanner(state: _sync)),
          const SizedBox(height: 12),
          _sectorTabs(),
          const SizedBox(height: 14),
          EntranceAnimation(
            delay: const Delay(80),
            scaleFrom: 0.96,
            child: _summaryCard(totalKg, view.length),
          ),
          const SizedBox(height: 16),
          EntranceAnimation(delay: const Delay(160), child: _form()),
          const SizedBox(height: 16),
          EntranceAnimation(delay: const Delay(240), child: _history(view)),
        ],
      ),
    );
  }

  Widget _sectorTabs() {
    return Row(
      children: ProductionSector.values.map((s) {
        final sel = _sector == s;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() {
                _sector = s;
                _syncCommodity();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  color: sel ? s.tint : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: sel ? s.tint : AppTheme.neutral200),
                  boxShadow: sel
                      ? [BoxShadow(color: s.tint.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(s.icon, size: 22, color: sel ? Colors.white : s.tint),
                    const SizedBox(height: 4),
                    Text(
                      s.label,
                      textAlign: TextAlign.center,
                      style: AppTheme.inter(
                        fontSize: 11,
                        weight: FontWeight.w600,
                        color: sel ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _summaryCard(int totalKg, int count) {
    final s = _sector;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [s.tint, s.tint.withValues(alpha: 0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: s.tint.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(s.icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total ${s.verb} (${s.label.split(' ').first})',
                    style: AppTheme.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.88))),
                const SizedBox(height: 4),
                Text('$totalKg kg',
                    style: tabularNumber(
                        fontSize: 30,
                        weight: FontWeight.w800,
                        color: Colors.white)),
                Text('$count catatan',
                    style: AppTheme.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _form() {
    final items = _sector.items;
    final names = items.map((c) => c.name).toList();
    if (names.isEmpty) names.add('Lainnya');
    return _Panel(
      title: 'Catat ${_sector.label}',
      icon: _sector.icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Komoditas',
              style: AppTheme.inter(
                  fontSize: 13, weight: FontWeight.w600, color: AppTheme.neutral500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: names
                .map((name) => _Pick(
                      name: name,
                      selected: _commodity == name,
                      tint: _sector.tint,
                      onTap: () => setState(() => _commodity = name),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: tabularNumber(fontSize: 20),
                  decoration: const InputDecoration(
                    labelText: 'Jumlah',
                    hintText: '100',
                    prefixIcon: Icon(Icons.scale_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _unit,
                  decoration: const InputDecoration(labelText: 'Satuan'),
                  items: _sector.units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _unit = v ?? _unit),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Tanggal',
                prefixIcon: Icon(Icons.event_rounded),
              ),
              child: Text(_fmtDate(_date),
                  style: AppTheme.inter(fontSize: 15, weight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 12),
          Text('Kualitas',
              style: AppTheme.inter(
                  fontSize: 13, weight: FontWeight.w600, color: AppTheme.neutral500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _qualities
                .map((q) => PFilterChip(
                      label: q,
                      selected: _quality == q,
                      onTap: () => setState(() => _quality = q),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          PButton(
            text: 'Simpan Hasil',
            icon: Icons.save_outlined,
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Widget _history(List<_ProductionRecord> view) {
    return _Panel(
      title: 'Riwayat ${_sector.label}',
      icon: Icons.history_rounded,
      child: view.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 40, color: AppTheme.neutral300),
                  const SizedBox(height: 8),
                  Text('Belum ada catatan.',
                      style: AppTheme.inter(
                          fontSize: 14,
                          weight: FontWeight.w600,
                          color: AppTheme.neutral500)),
                  const SizedBox(height: 4),
                  Text('Isi jumlah lalu tekan Simpan Hasil.',
                      style: AppTheme.inter(
                          fontSize: 12, color: AppTheme.neutral400)),
                ],
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < view.length; i++) ...[
                  if (i > 0) const Divider(height: 20),
                  _recordTile(view[i]),
                ],
              ],
            ),
    );
  }

  Widget _recordTile(_ProductionRecord r) {
    final tone = r.quality == 'Bagus'
        ? PStatusType.success
        : r.quality == 'Sedang'
            ? PStatusType.warning
            : PStatusType.danger;
    return Row(
      children: [
        Commodities.imageFor(r.commodity, size: 42, radius: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.commodity,
                  style: AppTheme.poppins(fontSize: 14, weight: FontWeight.w600)),
              Text('${r.date} · ${r.qty} ${r.unit}',
                  style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral400)),
            ],
          ),
        ),
        PStatusBadge(type: tone, label: r.quality.toUpperCase()),
      ],
    );
  }
}

class _Pick extends StatelessWidget {
  final String name;
  final bool selected;
  final Color tint;
  final VoidCallback onTap;
  const _Pick(
      {required this.name,
      required this.selected,
      required this.tint,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? tint.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? tint : AppTheme.neutral200,
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
                color: selected ? tint : AppTheme.neutral500,
              ),
            ),
          ],
        ),
      ),
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
                child: Text(title,
                    style: AppTheme.poppins(
                        fontSize: 16,
                        weight: FontWeight.w600,
                        color: cs.onSurface)),
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
