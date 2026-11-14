import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_pangan/core/theme/go_pay_theme.dart';

/// Bottom navigation item
class BottomNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// Custom bottom navigation - GoPay style with floating center button
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onCenterTap;
  final List<BottomNavItem> items;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.goPayColors;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bottom bar background
        Container(
          height: 72,
          decoration: BoxDecoration(
            color: color.surfaceWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: color.dividerLight,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left items (0, 1)
              _buildNavItem(0, color),
              _buildNavItem(1, color),
              // Spacer for center button
              const SizedBox(width: 64),
              // Right items (2, 3) - indices 2, 3 in items list
              _buildNavItem(2, color),
              _buildNavItem(3, color),
            ],
          ),
        ),
        // Floating center button - Larger, more prominent like GoPay QRIS
        Positioned(
          top: -32,
          left: 0,
          right: 0,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onCenterTap,
                borderRadius: BorderRadius.circular(GoPayRadius.circle),
                splashColor: color.brandPrimary.withValues(alpha: 0.12),
                child: Container(
                  width: 72, // Diameter 72px (lebih besar dari 64px)
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.brandPrimary,
                        color.brandSecondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      // Main shadow - 3D effect
                      BoxShadow(
                        color: color.brandPrimary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                      // Secondary shadow
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      // Inner highlight
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 32, // Larger icon
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, GoPayColors color) {
    final item = items[index];
    final isActive = currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(16),
          splashColor: color.brandPrimary.withValues(alpha: 0.08),
          child: SizedBox(
            height: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Active indicator pill
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.brandLightGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.activeIcon,
                      size: 24,
                      color: color.brandPrimary,
                    ),
                  )
                else
                  Icon(
                    item.icon,
                    size: 24,
                    color: color.neutral300,
                  ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? color.brandPrimary : color.neutral300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}