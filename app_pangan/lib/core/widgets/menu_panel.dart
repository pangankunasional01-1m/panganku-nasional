import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_pangan/core/theme/go_pay_theme.dart';

/// Panel putih besar untuk menu grid (seperti GoPay)
class MenuPanel extends StatelessWidget {
  final List<Widget> children;
  final String? title;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double? elevation;
  final EdgeInsetsGeometry? margin;

  const MenuPanel({
    super.key,
    required this.children,
    this.title,
    this.padding,
    this.borderRadius = 28,
    this.elevation,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.goPayColors;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surfaceWhite,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: color.dividerLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color.textDark,
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...children,
        ],
      ),
    );
  }
}

/// Data untuk item menu dengan warna pastel
class MenuItemData {
  final IconData icon;
  final String label;
  final Color iconBgColor; // Warna pastel background ikon
  final Color iconColor; // Warna solid ikon
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const MenuItemData({
    required this.icon,
    required this.label,
    required this.iconBgColor,
    required this.iconColor,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });
}