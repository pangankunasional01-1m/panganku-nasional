import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'pangan_catalog.dart';

class CommodityInfo {
  final String name;
  final String imageAsset;
  final IconData icon;
  final Color tint;
  final String category;
  const CommodityInfo({
    required this.name,
    required this.imageAsset,
    required this.icon,
    required this.tint,
    required this.category,
  });
}

class Commodities {
  static const all = <CommodityInfo>[
    CommodityInfo(
      name: 'Cabai Merah',
      imageAsset: 'assets/images/cabai merah.jpg',
      icon: Icons.local_fire_department_rounded,
      tint: AppTheme.statusDanger,
      category: 'Sayuran',
    ),
    CommodityInfo(
      name: 'Bawang Merah',
      imageAsset: 'assets/images/bawang merah.jpg',
      icon: Icons.spa_rounded,
      tint: Color(0xFFB0539A),
      category: 'Bumbu',
    ),
    CommodityInfo(
      name: 'Beras',
      imageAsset: 'assets/images/beras.png',
      icon: Icons.grain_rounded,
      tint: Color(0xFFD99A1E),
      category: 'Pangan Pokok',
    ),
    CommodityInfo(
      name: 'Jagung',
      imageAsset: 'assets/images/jagung.jpg',
      icon: Icons.grass_rounded,
      tint: AppTheme.brandPrimary,
      category: 'Pangan Pokok',
    ),
    CommodityInfo(
      name: 'Tomat',
      imageAsset: 'assets/images/tomat.jpg',
      icon: Icons.circle,
      tint: Color(0xFFE85D4A),
      category: 'Sayuran',
    ),
    CommodityInfo(
      name: 'Kentang',
      imageAsset: 'assets/images/kentang.jpg',
      icon: Icons.egg_rounded,
      tint: Color(0xFFC49A6C),
      category: 'Umbi',
    ),
    CommodityInfo(
      name: 'Wortel',
      imageAsset: 'assets/images/wortel.jpg',
      icon: Icons.change_history_rounded,
      tint: Color(0xFFF08A24),
      category: 'Sayuran',
    ),
    CommodityInfo(
      name: 'Bayam',
      imageAsset: 'assets/images/bayam.jpg',
      icon: Icons.eco_rounded,
      tint: Color(0xFF3FAF66),
      category: 'Sayuran',
    ),
  ];

  /// Hanya pangan pokok (data lain tetap ada di [all]).
  static List<CommodityInfo> get panganPokok => [
        ...all.where((c) => c.category == 'Pangan Pokok'),
        ...PanganCatalog.items.where((c) => c.category == 'Serealia & Umbi'),
      ];

  static CommodityInfo byName(String name) {
    final n = name.toLowerCase().trim();
    for (final c in all) {
      if (c.name.toLowerCase() == n) return c;
    }
    final cat = PanganCatalog.byName(name);
    return cat ?? all.first;
  }

  static String? assetPathFor(String name) {
    final n = name.toLowerCase().trim();
    for (final c in all) {
      if (c.name.toLowerCase() == n) return c.imageAsset;
    }
    return PanganCatalog.byName(name)?.imageAsset;
  }

  static Widget imageFor(
    String name, {
    double size = 48,
    double radius = 14,
  }) {
    final c = byName(name);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        c.imageAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: c.tint.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Icon(c.icon, color: c.tint, size: size * 0.52),
        ),
      ),
    );
  }
}
