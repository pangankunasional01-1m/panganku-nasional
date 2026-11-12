import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A custom header for [CustomScrollView] that fades out the expanded content
/// as the user scrolls and the header shrinks. Uses a plain [SliverAppBar]
/// so the system handles layout and animation correctly.
class PanganSliverHeader extends StatelessWidget {
  final Widget expandedContent;
  final String collapsedTitle;
  final double expandedHeight;
  final double? bottomHeight;
  final Widget? bottom;
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final bool floating;
  final bool pinned;

  const PanganSliverHeader({
    super.key,
    required this.expandedContent,
    required this.collapsedTitle,
    this.expandedHeight = 200,
    this.bottomHeight,
    this.bottom,
    this.backgroundColor = AppTheme.brandPrimary,
    this.backgroundGradient,
    this.floating = false,
    this.pinned = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final toolbarHeight = kToolbarHeight;
    final bottomHeightValue = bottomHeight ?? (bottom != null ? 72.0 : 0.0);
    final collapsedHeight = toolbarHeight + statusBarHeight;

    return NotificationListener<ScrollNotification>(
      onNotification: (_) => true,
      child: SliverAppBar(
        expandedHeight: expandedHeight,
        floating: floating,
        pinned: pinned,
        backgroundColor: backgroundColor,
        collapsedHeight: collapsedHeight,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.only(
            left: 20,
            bottom: bottomHeightValue > 0 ? 16 + bottomHeightValue : 16,
          ),
          centerTitle: false,
          title: const SizedBox.shrink(),
          background: Stack(
            fit: StackFit.expand,
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: backgroundGradient ?? AppTheme.primaryGradient,
                ),
              ),
              // Collapsed title (fades out when expanding)
              Positioned(
                left: 20,
                right: 20,
                top: statusBarHeight,
                height: toolbarHeight,
                child: AnimatedOpacity(
                  opacity: _t,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      collapsedTitle,
                      style: AppTheme.poppins(
                        fontSize: 18,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottom: bottom != null
            ? PreferredSize(
                preferredSize: Size.fromHeight(bottomHeightValue),
                child: bottom!,
              )
            : null,
      ),
    );
  }
}

/// Fades out the expanded content as the header shrinks.
class _ExpandedContentFadeOut extends StatefulWidget {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget child;

  const _ExpandedContentFadeOut({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.child,
  });

  @override
  State<_ExpandedContentFadeOut> createState() => _ExpandedContentFadeOutState();
}

class _ExpandedContentFadeOutState extends State<_ExpandedContentFadeOut> {
  double _scrollOffset = 0.0;
  double _t = 1.0;

  @override
  Widget build(BuildContext context) {
    final totalShrink = widget.expandedHeight - widget.collapsedHeight;
    if (totalShrink > 0) {
      _t = 1.0 - (_scrollOffset / totalShrink).clamp(0.0, 1.0);
    } else {
      _t = 1.0;
    }
    return Opacity(
      opacity: _t,
      child: widget.child,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollOffset = 0.0;
  }
}
