import 'package:flutter/material.dart';

import 'production_screen.dart';

/// Alias kompatibilitas: Catat Panen (darat). Halaman utama: [ProductionScreen].
class HarvestScreen extends StatelessWidget {
  const HarvestScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const ProductionScreen(initialSector: ProductionSector.darat);
}
