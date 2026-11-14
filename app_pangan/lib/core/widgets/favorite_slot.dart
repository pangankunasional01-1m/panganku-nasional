import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_pangan/core/theme/go_pay_theme.dart';

/// Favorite slot for access bar - GoPay style
class FavoriteSlot extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool hasPlus; // whether to show + empty slot

  const FavoriteSlot({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.hasPlus = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.goPayColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? color.brandPrimary.withValues(alpha: 0.1) : color.surfaceWhite,
          border: Border.all(
            color: isSelected ? color.brandPrimary : color.dividerLight,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(GoPayRadius.circle),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? color.brandPrimary : color.neutral300,
            ),
            if (!hasPlus && label.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: color.neutral300,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (hasPlus) ...[
              const SizedBox(height: 2),
              Text(
                '+',
                style: TextStyle(
                  fontSize: 22,
                  color: color.neutral300,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}