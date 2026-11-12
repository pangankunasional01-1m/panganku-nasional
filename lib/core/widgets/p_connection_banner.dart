import 'package:flutter/material.dart';

import '../animation/entrance_animation.dart';
import '../theme/app_theme.dart';
import 'p_chip_badge.dart';

enum PSyncState { offline, pending, synced }

class PConnectionBanner extends StatelessWidget {
  final PSyncState state;
  final String? detail;

  const PConnectionBanner({super.key, required this.state, this.detail});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label, type, badge) = switch (state) {
      PSyncState.offline => (
        AppTheme.statusDanger,
        Icons.cloud_off_rounded,
        'Tidak ada sinyal — mencatat di HP',
        PStatusType.danger,
        'OFFLINE',
      ),
      PSyncState.pending => (
        AppTheme.statusWarning,
        Icons.sync_rounded,
        'Menunggu sinkron',
        PStatusType.warning,
        'ANTRE',
      ),
      PSyncState.synced => (
        AppTheme.statusSuccess,
        Icons.cloud_done_rounded,
        'Tersinkron',
        PStatusType.success,
        'ONLINE',
      ),
    };

    final surface = Theme.of(context).colorScheme.surface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: 0.10), surface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: AppTheme.softShadow(0.05),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
              child: state == PSyncState.pending
                  ? Center(key: const ValueKey('pending'), child: PulseDot(color: color, size: 8))
                  : Icon(icon, key: ValueKey(state), size: 20, color: color),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                detail != null ? '$label · $detail' : label,
                key: ValueKey('$state$detail'),
                style: AppTheme.inter(fontSize: 12, weight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PStatusBadge(type: type, label: badge),
        ],
      ),
    );
  }
}
