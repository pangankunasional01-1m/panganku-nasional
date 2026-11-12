import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_button.dart';
import 'ai_expert_screen.dart';

/// Panduan Tanam — langkah bergambar untuk petani.
class PlantingGuideScreen extends StatelessWidget {
  const PlantingGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text('Panduan Tanam',
            style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w600)),
        backgroundColor: AppTheme.bgCream,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text('Langkah Budidaya Cabai',
              style: AppTheme.poppins(
                  fontSize: 18, weight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          _guideCard(
            icon: Icons.calendar_month,
            color: AppTheme.brandPrimary,
            title: 'Waktu Tanam Terbaik',
            desc:
                'Tanam awal musim hujan (Nov–Des) agar kelembapan cukup. Hindari musim kemarau puncak.',
          ),
          const SizedBox(height: 12),
          _guideCard(
            icon: Icons.science_outlined,
            color: AppTheme.brandSecondary,
            title: 'Takaran Pupuk Efisien',
            desc:
                'Gunakan pupuk organik 2 ton/ha + NPK 300 kg/ha. Split 3 tahap: tanam, vegetatif, berbunga.',
          ),
          const SizedBox(height: 12),
          _guideCard(
            icon: Icons.bug_report_outlined,
            color: AppTheme.brandAccent,
            title: 'Pencegahan Hama Organik',
            desc:
                'Semprot ekstrak nimba 2x/minggu. Pasang perangkap kuning. Rotasi tanaman dengan jagung.',
          ),
          const SizedBox(height: 12),
          _guideCard(
            icon: Icons.water_drop_outlined,
            color: AppTheme.statusInfo,
            title: 'Irigasi & Drainase',
            desc:
                'Siram pagi hari 2–3x/minggu. Pastikan drainase lancar untuk cegah busuk akar.',
          ),
          const SizedBox(height: 24),
          PButton(
            text: 'Tanya Pakar AI',
            icon: Icons.smart_toy,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiExpertScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _guideCard({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTheme.poppins(
                          fontSize: 16,
                          weight: FontWeight.w600,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: AppTheme.inter(
                          fontSize: 13, color: AppTheme.neutral500, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}