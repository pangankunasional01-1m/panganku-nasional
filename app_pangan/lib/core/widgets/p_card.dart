import 'package:flutter/material.dart';
import '../animation/entrance_animation.dart';
import '../data/commodities.dart';
import '../theme/app_theme.dart';

class PStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? delta;
  final bool deltaPositive;
  final IconData? icon;

  const PStatCard({
    super.key,
    required this.title,
    required this.value,
    this.delta,
    this.deltaPositive = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final deltaColor = deltaPositive ? AppTheme.statusSuccess : AppTheme.statusDanger;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(color: cs.surface, radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: AppTheme.brandPrimary),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.inter(fontSize: 12, weight: FontWeight.w500, color: AppTheme.neutral400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: tabularNumber(fontSize: 28, weight: FontWeight.w700, color: cs.onSurface)),
          ),
          if (delta != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: deltaColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(deltaPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 13, color: deltaColor),
                  const SizedBox(width: 3),
                  Text(delta!, style: AppTheme.inter(fontSize: 12, weight: FontWeight.w600, color: deltaColor)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kartu komoditas. Vertikal (untuk carousel) atau [horizontal] (untuk daftar).
class PCommodityCard extends StatelessWidget {
  final String name;
  final String price; // contoh: "Rp 45.000 / kg"
  final String stock;
  final String category;
  final VoidCallback onTap;
  final IconData icon;
  final Color tint;
  final bool horizontal;

  const PCommodityCard({
    super.key,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.onTap,
    this.icon = Icons.eco_rounded,
    this.tint = AppTheme.brandPrimary,
    this.horizontal = false,
  });

  Widget _thumb(double size) => Commodities.imageFor(
        name,
        size: size,
        radius: size * 0.28,
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final parts = price.split(' / ');
    final main = parts.first;
    final unit = parts.length > 1 ? '/${parts[1]}' : null;

    final priceWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(main, style: tabularNumber(fontSize: 18, weight: FontWeight.w700, color: cs.onSurface)),
          ),
        ),
        if (unit != null) ...[
          const SizedBox(width: 3),
          Text(unit, style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral400)),
        ],
      ],
    );

    final stockRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(color: AppTheme.statusSuccess, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            stock,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.inter(fontSize: 12, weight: FontWeight.w500, color: AppTheme.neutral500),
          ),
        ),
      ],
    );

    final nameText = Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTheme.poppins(fontSize: 15, weight: FontWeight.w600, color: cs.onSurface),
    );

    return Pressable(
      onTap: onTap,
      semanticLabel: '$name, $price, $stock',
      scale: 0.97,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration(color: cs.surface, radius: 22),
        child: horizontal
            ? Row(
                children: [
                  _thumb(52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        nameText,
                        const SizedBox(height: 4),
                        Text(category, style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral400)),
                        const SizedBox(height: 6),
                        stockRow,
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: priceWidget),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _thumb(40),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.inter(fontSize: 11, weight: FontWeight.w600, color: AppTheme.neutral400),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  nameText,
                  const SizedBox(height: 4),
                  priceWidget,
                  const SizedBox(height: 8),
                  stockRow,
                ],
              ),
      ),
    );
  }
}
