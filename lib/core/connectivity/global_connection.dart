import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../theme/app_theme.dart';
import '../widgets/p_connection_banner.dart';

/// Global connectivity provider that monitors network status
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Connection state notifier for global banner
class GlobalConnectionState extends StateNotifier<PSyncState> {
  GlobalConnectionState() : super(PSyncState.synced);

  void updateFromConnectivity(List<ConnectivityResult> results) {
    // Check if any connection is available
    final hasConnection = results.any((r) => 
      r == ConnectivityResult.mobile || 
      r == ConnectivityResult.wifi || 
      r == ConnectivityResult.ethernet || 
      r == ConnectivityResult.vpn ||
      r == ConnectivityResult.satellite
    );
    
    final newState = hasConnection ? PSyncState.synced : PSyncState.offline;
    if (newState != state) {
      state = newState;
      if (newState == PSyncState.offline) {
        HapticFeedback.heavyImpact();
      } else if (newState == PSyncState.synced) {
        HapticFeedback.lightImpact();
      }
    }
  }
}

final globalConnectionProvider = StateNotifierProvider<GlobalConnectionState, PSyncState>((ref) {
  final notifier = GlobalConnectionState();
  final subscription = ref.listen(connectivityProvider, (previous, next) {
    next.whenData(notifier.updateFromConnectivity);
  });
  ref.onDispose(() => subscription.close());
  return notifier;
});

/// Global offline banner that can be added to any screen
class GlobalOfflineBanner extends ConsumerWidget {
  const GlobalOfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(globalConnectionProvider);

    if (connectionState != PSyncState.offline) {
      return const SizedBox.shrink();
    }

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      offset: const Offset(0, 0),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.statusDanger.withValues(alpha: 0.12),
          child: Row(
            children: [
              Icon(Icons.wifi_off_rounded, size: 18, color: AppTheme.statusDanger),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mode offline — perubahan disimpan lokal',
                  style: AppTheme.inter(
                    fontSize: 13,
                    weight: FontWeight.w500,
                    color: AppTheme.statusDanger,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.statusDanger,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: Text('Tutup', style: AppTheme.inter(fontSize: 12, weight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wrapper that adds global offline banner to any screen
class WithGlobalBanner extends StatelessWidget {
  final Widget child;

  const WithGlobalBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const GlobalOfflineBanner(),
        Expanded(child: child),
      ],
    );
  }
}

/// Mixin for screens that need haptic feedback on interactions
mixin HapticMixin {
  void lightImpact() => HapticFeedback.lightImpact();
  void mediumImpact() => HapticFeedback.mediumImpact();
  void heavyImpact() => HapticFeedback.heavyImpact();
  void selectionClick() => HapticFeedback.selectionClick();
  void vibrate() => HapticFeedback.vibrate();
}

/// Extension for adding haptic feedback to any widget
extension HapticExtension on Widget {
  Widget withHapticTap({
    VoidCallback? onTap,
    HapticFeedbackType type = HapticFeedbackType.lightImpact,
  }) {
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            switch (type) {
              case HapticFeedbackType.lightImpact:
                HapticFeedback.lightImpact();
                break;
              case HapticFeedbackType.mediumImpact:
                HapticFeedback.mediumImpact();
                break;
              case HapticFeedbackType.heavyImpact:
                HapticFeedback.heavyImpact();
                break;
              case HapticFeedbackType.selectionClick:
                HapticFeedback.selectionClick();
                break;
              case HapticFeedbackType.vibrate:
                HapticFeedback.vibrate();
                break;
            }
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: AppTheme.brandPrimary.withValues(alpha: 0.08),
          child: this,
        ),
      ),
    );
  }
}

enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}