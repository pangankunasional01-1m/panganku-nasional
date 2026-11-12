import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Laporan Musim Tanam — laba/rugi otomatis.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text('Laporan',
            style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w600)),
        backgroundColor: AppTheme.bgCream,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // Indikator besar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Laba Bersih Musim Tanam Cabai',
                      style: AppTheme.inter(
                          fontSize: 13, color: AppTheme.neutral500)),
                  const SizedBox(height: 8),
                  Text('UNTUNG Rp 2.400.000',
                      style: tabularNumber(
                          fontSize: 30,
                          weight: FontWeight.w700,
                          color: AppTheme.statusSuccess)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.arrow_upward,
                          size: 14, color: AppTheme.statusSuccess),
                      const SizedBox(width: 4),
                      Text('+12% vs musim lalu',
                          style: AppTheme.inter(
                              fontSize: 12,
                              weight: FontWeight.w600,
                              color: AppTheme.statusSuccess)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Diperbarui 2 menit lalu',
                      style: AppTheme.inter(
                          fontSize: 11, color: AppTheme.neutral400)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Pemasukan vs Pengeluaran',
              style: AppTheme.poppins(
                  fontSize: 16, weight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(height: 200, child: _barChart()),
            ),
          ),
          const SizedBox(height: 16),
          Text('Rincian Biaya',
              style: AppTheme.poppins(
                  fontSize: 16, weight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _costRow('Pupuk', 0.35, AppTheme.brandPrimary),
                  _costRow('Bibit', 0.22, AppTheme.brandSecondary),
                  _costRow('Upah', 0.20, AppTheme.brandAccent),
                  _costRow('Pestisida', 0.13, AppTheme.statusWarning),
                  _costRow('Lain-lain', 0.10, AppTheme.neutral400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                const m = ['Mei', 'Jun', 'Jul', 'Ags'];
                final i = v.toInt();
                return Text(
                  i >= 0 && i < m.length ? m[i] : '',
                  style: AppTheme.inter(fontSize: 11),
                );
              },
            ),
          ),
        ),
        barGroups: [
          _group(0, 4, 2.8),
          _group(1, 3.2, 1.5),
          _group(2, 5.2, 2.1),
          _group(3, 2.5, 0.8),
        ],
      ),
    );
  }

  BarChartGroupData _group(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: AppTheme.brandPrimary,
          width: 14,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: expense,
          color: AppTheme.brandAccent,
          width: 14,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _costRow(String label, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppTheme.inter(fontSize: 14))),
          Text('${(pct * 100).round()}%',
              style: tabularNumber(fontSize: 14)),
        ],
      ),
    );
  }
}