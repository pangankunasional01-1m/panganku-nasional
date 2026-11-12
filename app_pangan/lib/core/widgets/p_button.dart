import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../animation/entrance_animation.dart';

enum PButtonType { primary, secondary, ghost, danger }

class PButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final PButtonType type;
  final bool isLoading;
  final IconData? icon;

  const PButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = PButtonType.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null && !isLoading;
    final enabled = onPressed != null && !isLoading;

    Color fg;
    Color? bg;
    Gradient? gradient;
    Border? border;
    List<BoxShadow> shadow = const [];

    switch (type) {
      case PButtonType.primary:
        gradient = AppTheme.primaryGradient;
        fg = Colors.white;
        shadow = AppTheme.glow(AppTheme.brandPrimary);
        break;
      case PButtonType.secondary:
        bg = Theme.of(context).colorScheme.surface;
        fg = AppTheme.brandPrimary;
        border = Border.all(color: AppTheme.brandPrimary, width: 1.5);
        break;
      case PButtonType.ghost:
        bg = Colors.transparent;
        fg = Theme.of(context).colorScheme.onSurface;
        break;
      case PButtonType.danger:
        gradient = AppTheme.accentGradient;
        fg = Colors.white;
        shadow = AppTheme.glow(AppTheme.brandAccent);
        break;
    }

    if (disabled) {
      gradient = null;
      bg = AppTheme.neutral200;
      fg = AppTheme.neutral400;
      border = null;
      shadow = const [];
    }

    final Widget content = isLoading
        ? SizedBox(
            key: const ValueKey('loading'),
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.6, color: fg),
          )
        : Row(
            key: const ValueKey('label'),
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.poppins(fontSize: 16, weight: FontWeight.w600, color: fg),
                ),
              ),
            ],
          );

    return SizedBox(
      height: 56, // target sentuh minimum petani
      child: Pressable(
        onTap: enabled ? onPressed : null,
        semanticLabel: text,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: gradient == null ? bg : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            border: border,
            boxShadow: enabled ? shadow : const [],
          ),
          child: Center(
            widthFactor: 1,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol ikon besar untuk beranda petani (operasi satu tangan).
/// Lebar mengikuti induk — letakkan di dalam SizedBox / Expanded.
class PIconBigButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const PIconBigButton({
    super.key,
    required this.icon,
    required this.label,
    this.color = AppTheme.brandPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      scale: 0.94,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 14),
        decoration: AppTheme.cardDecoration(radius: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.20), color.withValues(alpha: 0.07)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTheme.inter(fontSize: 12, weight: FontWeight.w600, color: AppTheme.textDark, height: 1.25),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
