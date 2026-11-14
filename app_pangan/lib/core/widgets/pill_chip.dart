import 'package:flutter/material.dart';
import 'package:app_pangan/core/theme/go_pay_theme.dart';

/// Pill-style chip for horizontal scroll - GoPay style
class PillChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String trailing;
  final bool isOnline;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final TextStyle? labelStyle;

  const PillChip({
    super.key,
    required this.label,
    required this.icon,
    required this.trailing,
    this.isOnline = false,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.goPayColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? color.neutral100,
          borderRadius: BorderRadius.circular(GoPayRadius.pill),
          border: Border.all(color: color.dividerLight, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon di kiri
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: (iconColor ?? color.brandPrimary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor ?? color.brandPrimary),
            ),
            const SizedBox(width: 8),
            // Label
            Text(
              label,
              style: labelStyle ??
                  TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: iconColor ?? color.textDark,
                  ),
            ),
            const SizedBox(width: 8),
            // Trailing text (e.g., "ONLINE", "1 AKTIF >")
            Text(
              trailing,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isOnline ? color.statusSuccess : color.brandPrimary,
              ),
            ),
            const SizedBox(width: 4),
            // Panah di kanan
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: color.neutral300,
            ),
          ],
        ),
      ),
    );
  }
}