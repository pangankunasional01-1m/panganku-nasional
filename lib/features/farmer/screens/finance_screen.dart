import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_button.dart';
import '../../../core/widgets/p_chip_badge.dart';
import '../../../core/widgets/p_connection_banner.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final _amountCtrl = TextEditingController();
  String _category = 'Pupuk';
  PSyncState _sync = PSyncState.synced;
  bool _saving = false;

  static const _categories = [
    ('Bibit', Icons.spa_outlined),
    ('Pupuk', Icons.science_outlined),
    ('Pestisida', Icons.bug_report_outlined),
    ('Upah', Icons.groups_outlined),
    ('Listrik/Air', Icons.bolt_outlined),
    ('Lain-lain', Icons.more_horiz),
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_amountCtrl.text.trim().isEmpty || _saving) return;
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
    });
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.brandPrimaryLight, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('Tersimpan: $_category · Rp ${_amountCtrl.text}')),
            ],
          ),
        ),
      );
    _amountCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keuangan')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          EntranceAnimation(child: PConnectionBanner(state: _sync)),
          const SizedBox(height: 16),
          const EntranceAnimation(delay: Delay(80), scaleFrom: 0.96, child: _ProfitSummary()),
          const SizedBox(height: 16),
          EntranceAnimation(delay: const Delay(160), child: _expenseForm()),
          const SizedBox(height: 16),
          EntranceAnimation(delay: const Delay(240), child: _chartCard()),
          const SizedBox(height: 16),
          const EntranceAnimation(delay: Delay(320), child: _CostBreakdown()),
        ],
      ),
    );
  }

  // ── Form catat pengeluaran ────────────────────────────────────────────
  Widget _expenseForm() {
    return _Panel(
      title: 'Catat Pengeluaran',
      icon: Icons.edit_note_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories
                .map(
                  (c) => PFilterChip(
                    label: c.$1,
                    icon: c.$2,
                    selected: _category == c.$1,
                    onTap: () => setState(() => _category = c.$1),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: tabularNumber(fontSize: 20),
            decoration: InputDecoration(
              labelText: 'Nominal (Rp)',
              hintText: '140000',
              prefixIcon: const Icon(Icons.payments_outlined),
              suffixIcon: IconButton(
                icon: const Icon(Icons.mic_rounded, color: AppTheme.brandPrimary),
                tooltip: 'Input suara',
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Simulasi voice: "pupuk urea dua karung seratus empat puluh ribu" → Rp 140.000'),
                      ),
                    );
                  _amountCtrl.text = '140000';
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          PButton(
            text: 'Simpan Biaya',
            icon: Icons.save_outlined,
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  // ── Grafik pemasukan vs pengeluaran ───────────────────────────────────
  Widget _chartCard() {
    return _Panel(
      title: 'Pemasukan vs Pengeluaran',
      icon: Icons.bar_chart_rounded,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _LegendDot(color: AppTheme.brandPrimary, label: 'Masuk'),
          SizedBox(width: 10),
          _LegendDot(color: AppTheme.brandAccent, label: 'Keluar'),
        ],
      ),
      child: SizedBox(height: 190, child: _barChart()),
    );
  }

  Widget _barChart() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 6,
          minY: 0,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppTheme.neutral200.withValues(alpha: 0.6),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) {
                  const m = ['Mei', 'Jun', 'Jul', 'Ags'];
                  final i = v.toInt();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      i >= 0 && i < m.length ? m[i] : '',
                      style: AppTheme.inter(fontSize: 12, weight: FontWeight.w500, color: AppTheme.neutral400),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            _group(0, 4, 2.8, t),
            _group(1, 3.2, 1.5, t),
            _group(2, 5.2, 2.1, t),
            _group(3, 2.5, 0.8, t),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _group(int x, double income, double expense, double t) {
    return BarChartGroupData(
      x: x,
      barsSpace: 6,
      barRods: [
        BarChartRodData(
          toY: income * t,
          gradient: LinearGradient(
            colors: [AppTheme.brandPrimaryLight, AppTheme.brandPrimary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
        BarChartRodData(
          toY: expense * t,
          gradient: LinearGradient(
            colors: [const Color(0xFFF58455), AppTheme.brandAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}

// ── Komponen privat ─────────────────────────────────────────────────────────

/// Kartu bagian dengan judul + ikon kecil.
class _Panel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _Panel({required this.title, required this.icon, required this.child, this.trailing});

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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.poppins(fontSize: 16, weight: FontWeight.w600, color: cs.onSurface),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(label, style: AppTheme.inter(fontSize: 11, weight: FontWeight.w500, color: AppTheme.neutral400)),
      ],
    );
  }
}

class _ProfitSummary extends StatelessWidget {
  const _ProfitSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.glow(AppTheme.brandPrimary),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          Positioned(
            right: 6,
            bottom: -6,
            child: Floating(
              child: Icon(Icons.trending_up_rounded, size: 84, color: Colors.white.withValues(alpha: 0.13)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 5),
                    Text('UNTUNG', style: AppTheme.inter(fontSize: 11, weight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: AnimatedCounter(
                  value: 1200000,
                  prefix: 'Rp ',
                  style: tabularNumber(fontSize: 36, weight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Laba bersih musim tanam cabai · diperbarui 2 menit lalu',
                style: AppTheme.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.82), height: 1.4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostBreakdown extends StatelessWidget {
  const _CostBreakdown();

  static const _items = [
    ('Pupuk', 0.35, AppTheme.brandPrimary),
    ('Bibit', 0.22, AppTheme.brandSecondary),
    ('Upah', 0.20, AppTheme.brandAccent),
    ('Pestisida', 0.13, AppTheme.statusWarning),
    ('Lain-lain', 0.10, AppTheme.neutral400),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const maxV = 0.35;
    return _Panel(
      title: 'Rincian biaya per kategori',
      icon: Icons.pie_chart_outline_rounded,
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: _items[i].$3, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _items[i].$1,
                          style: AppTheme.inter(fontSize: 14, weight: FontWeight.w500, color: cs.onSurface),
                        ),
                      ),
                      Text(
                        '${(_items[i].$2 * 100).round()}%',
                        style: tabularNumber(fontSize: 14, color: cs.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 8,
                      color: AppTheme.neutral100,
                      alignment: Alignment.centerLeft,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _items[i].$2 / maxV),
                        duration: Duration(milliseconds: 800 + i * 150),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, _) => FractionallySizedBox(
                          widthFactor: v.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _items[i].$3,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
