import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

import '../../../core/theme/app_theme.dart';
import 'home_tab_screen.dart';
import 'price_tab_screen.dart';
import 'market_tab_screen.dart';
import 'monitoring_tab_screen.dart';
import 'profile_tab_screen.dart';

class MainNavScreen extends ConsumerStatefulWidget {
  const MainNavScreen({super.key});

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  int _currentIndex = 0;

  static final List<Widget> _screens = const [
    HomeTabScreen(),
    PriceTabScreen(),
    MarketTabScreen(),
    MonitoringTabScreen(),
    ProfileTabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: _screens[_currentIndex],
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_NavItem>[
      _NavItem(
        index: 0,
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Beranda',
        semanticsLabel: 'Beranda, tab 1 dari 5',
      ),
      _NavItem(
        index: 1,
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
        label: 'Harga',
        semanticsLabel: 'Harga komoditas, tab 2 dari 5',
      ),
      _NavItem(
        index: 2,
        icon: Icons.location_on_outlined,
        activeIcon: Icons.location_on_rounded,
        label: 'Pasar',
        semanticsLabel: 'Pasar terdekat, tab 3 dari 5',
      ),
      _NavItem(
        index: 3,
        icon: Icons.bookmark_outline_rounded,
        activeIcon: Icons.bookmark_rounded,
        label: 'Pantauan',
        semanticsLabel: 'Pantauan harga, tab 4 dari 5',
      ),
      _NavItem(
        index: 4,
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profil',
        semanticsLabel: 'Profil dan pengaturan, tab 5 dari 5',
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: AppTheme.textDark.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: AppTheme.neutral200,
              width: 1,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Active indicator bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              left: (MediaQuery.of(context).size.width / 5) * currentIndex,
              top: 0,
              width: MediaQuery.of(context).size.width / 5,
              height: 3,
              child: Container(
                color: AppTheme.brandPrimary,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final item in items)
                  _NavButton(
                    item: item,
                    isActive: item.index == currentIndex,
                    onTap: () => onTap(item.index),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String semanticsLabel;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.semanticsLabel,
  });
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: item.semanticsLabel,
        selected: isActive,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: AppTheme.brandPrimary.withValues(alpha: 0.12),
            highlightColor: AppTheme.brandPrimary.withValues(alpha: 0.08),
            child: SizedBox(
              height: 72,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 4), // Space for indicator bar
                  Icon(
                    isActive ? item.activeIcon : item.icon,
                    size: 26,
                    color: isActive ? AppTheme.brandPrimary : AppTheme.neutral400,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: AppTheme.inter(
                      fontSize: 12,
                      weight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppTheme.brandPrimary : AppTheme.neutral400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}