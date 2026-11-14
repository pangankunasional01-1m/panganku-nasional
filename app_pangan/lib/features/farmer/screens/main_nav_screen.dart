import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/custom_bottom_nav.dart';
import '../../../core/theme/go_pay_theme.dart';
import 'home_tab_screen.dart';
import 'price_tab_screen.dart';
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
    MonitoringTabScreen(),
    ProfileTabScreen(),
  ];

  // Bottom nav items (4 items, center is floating button)
  static final List<BottomNavItem> _navItems = const [
    BottomNavItem(
      label: 'Beranda',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    BottomNavItem(
      label: 'Harga',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
    ),
    BottomNavItem(
      label: 'Pantauan',
      icon: Icons.bookmark_outline_rounded,
      activeIcon: Icons.bookmark_rounded,
    ),
    BottomNavItem(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  void _onNavTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  void _onCenterTap() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/production');
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = context.goPayColors.bgCream;
    return Scaffold(
      backgroundColor: bgColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        onCenterTap: _onCenterTap,
        items: _navItems,
      ),
    );
  }
}