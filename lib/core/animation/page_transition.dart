import 'package:flutter/material.dart';

/// Transisi halaman: fade + slide halus
class FadeSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Offset beginOffset;

  FadeSlideRoute({
    required this.page,
    super.settings,
    this.duration = const Duration(milliseconds: 420),
    this.beginOffset = const Offset(0, 0.08),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(curved),
                child: child,
              ),
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );

  static Route<T> create<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 420),
  }) {
    return FadeSlideRoute<T>(page: page, duration: duration);
  }
}

/// Transisi scale untuk modal / dialog
class ScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  ScaleRoute({required this.page, super.settings, this.duration = const Duration(milliseconds: 350)})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                child: child,
              ),
            );
          },
          transitionDuration: duration,
        );

  static Route<T> create<T>({required Widget page, Duration duration = const Duration(milliseconds: 350)}) {
    return ScaleRoute<T>(page: page, duration: duration);
  }
}
