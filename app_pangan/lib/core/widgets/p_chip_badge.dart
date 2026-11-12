import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../animation/entrance_animation.dart';

/// Chip filter dengan transisi warna halus + centang yang "tumbuh".
class PFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? activeColor;
  final IconData? icon;

  const PFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    required this.onTap,
    this.activeColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = activeColor ?? AppTheme.brandPrimary;
    final surface = Theme.of(context).colorScheme.surface;
    final onActive = c.computeLuminance() > 0.5 ? AppTheme.textDark : Colors.white;
    final fg = selected ? onActive : AppTheme.neutral500;

    return Pressable(
      onTap: onTap,
      scale: 0.94,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c : surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? c : AppTheme.neutral200, width: 1.5),
          boxShadow: selected
              ? [BoxShadow(color: c.withValues(alpha: 0.30), blurRadius: 14, offset: const Offset(0, 5))]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.check_rounded, size: 16, color: fg),
                    )
                  : const SizedBox.shrink(),
            ),
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTheme.inter(fontSize: 13, weight: FontWeight.w600, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

// Status badge: selalu warna + ikon + teks (tidak hanya warna)
enum PStatusType { success, warning, danger, info }

class PStatusBadge extends StatelessWidget {
  final PStatusType type;
  final String label;

  const PStatusBadge({super.key, required this.type, required this.label});

  @override
  Widget build(BuildContext context) {
    late Color c;
    late IconData icon;
    switch (type) {
      case PStatusType.success:
        c = AppTheme.statusSuccess;
        icon = Icons.check_circle_rounded;
        break;
      case PStatusType.warning:
        c = AppTheme.statusWarning;
        icon = Icons.warning_rounded;
        break;
      case PStatusType.danger:
        c = AppTheme.statusDanger;
        icon = Icons.error_rounded;
        break;
      case PStatusType.info:
        c = AppTheme.statusInfo;
        icon = Icons.info_rounded;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 5),
          Text(label, style: AppTheme.inter(fontSize: 11, weight: FontWeight.w700, color: c)),
        ],
      ),
    );
  }
}
