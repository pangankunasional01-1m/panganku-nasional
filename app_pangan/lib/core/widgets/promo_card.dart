import 'package:flutter/material.dart';
import 'package:app_pangan/core/theme/go_pay_theme.dart';

/// Promo card horizontal scroll - GoPay style
class PromoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const PromoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.goPayColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.surfaceWhite,
          borderRadius: BorderRadius.circular(GoPayRadius.pill),
          border: Border.all(color: color.dividerLight, width: 0.5),
          boxShadow: [GoPayShadows.cardShadow()],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon di kiri atas
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.neutral100,
                  borderRadius: BorderRadius.circular(GoPayRadius.small),
                ),
                child: Icon(icon, size: 24, color: color.brandPrimary),
              ),
              const SizedBox(height: 12),
              // Judul tebal
              Text(
                title,
                style: GoPayTextTheme.bodyLarge(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Subteks abu
              Text(
                subtitle,
                style: GoPayTextTheme.bodySmall().copyWith(
                  color: color.neutral400,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Panah di kanan atas
              Align(
                alignment: Alignment.centerRight,
                child: Transform.rotate(
                  angle: 0.3,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: color.neutral300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}