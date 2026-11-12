import 'package:flutter/material.dart';
import '../animation/entrance_animation.dart';
import '../theme/app_theme.dart';
import 'p_button.dart';

/// Skeleton dengan efek shimmer yang benar-benar bergerak.
class PSkeleton extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;

  const PSkeleton({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  State<PSkeleton> createState() => _PSkeletonState();
}

class _SlideGradient extends GradientTransform {
  final double slide;
  const _SlideGradient(this.slide);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slide, 0, 0);
}

class _PSkeletonState extends State<PSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? AppTheme.darkBorder : AppTheme.neutral200.withValues(alpha: 0.7);
    final light = dark ? const Color(0xFF4A3F31) : AppTheme.neutral100;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          gradient: LinearGradient(
            colors: [base, light, base],
            stops: const [0.25, 0.5, 0.75],
            transform: _SlideGradient(-1 + 2 * _c.value),
          ),
        ),
      ),
    );
  }
}

class PEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const PEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: EntranceAnimation(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Floating(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppTheme.brandPrimary.withValues(alpha: 0.16), AppTheme.brandPrimary.withValues(alpha: 0.04)],
                    ),
                  ),
                  child: Icon(icon, size: 44, color: AppTheme.brandPrimary.withValues(alpha: 0.7)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: AppTheme.poppins(fontSize: 18, weight: FontWeight.w600, color: onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral400, height: 1.5),
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[
                const SizedBox(height: 20),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PErrorState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  const PErrorState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return PEmptyState(
      icon: Icons.error_outline_rounded,
      title: title,
      subtitle: subtitle,
      action: PButton(
        text: 'Coba Lagi',
        type: PButtonType.secondary,
        onPressed: onRetry,
        icon: Icons.refresh_rounded,
      ),
    );
  }
}

enum SyncState { local, pending, synced }

class PSyncIndicator extends StatelessWidget {
  final SyncState state;

  const PSyncIndicator({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    late IconData icon;
    late Color color;
    late String text;
    switch (state) {
      case SyncState.local:
        icon = Icons.save_alt_rounded;
        color = AppTheme.brandAccent;
        text = 'Tersimpan di HP';
        break;
      case SyncState.pending:
        icon = Icons.sync_rounded;
        color = AppTheme.statusWarning;
        text = 'Menunggu sinkron';
        break;
      case SyncState.synced:
        icon = Icons.cloud_done_rounded;
        color = AppTheme.statusSuccess;
        text = 'Tersinkron';
        break;
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Row(
        key: ValueKey(state),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: AppTheme.inter(fontSize: 12, weight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}
