import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pangan_sliver_header.dart';
import 'market_tab_screen.dart';

/// Halaman Pasar lengkap (standalone dari tab)
class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            PanganSliverHeader(
              expandedHeight: 130,
              collapsedTitle: 'Pasar Terdekat',
              expandedContent: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  'Pasar Terdekat',
                  style: AppTheme.poppins(
                    fontSize: 24,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              child: MarketTabScreen(),
            ),
          ],
        ),
      ),
    );
  }
}