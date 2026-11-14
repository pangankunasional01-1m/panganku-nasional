import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Header untuk [CustomScrollView] — memakai [SliverAppBar] bawaan (native).
/// - `floating: true` + `pinned: false` → header menghilang saat scroll ke bawah,
///   muncul lagi saat scroll ke atas.
/// - `expandedHeight` mengatur ukuran besar header (dioptimalkan lebih proporsional).
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
    this.expandedHeight = 110,
    this.bottomHeight,
    this.bottom,
    this.backgroundColor = AppTheme.brandPrimary,
    this.backgroundGradient,
    this.floating = true,
    this.pinned = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final collapsedHeight = kToolbarHeight + statusBarHeight;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      backgroundColor: backgroundColor,
      collapsedHeight: collapsedHeight,
      title: Text(
        collapsedTitle,
        style: AppTheme.poppins(
          fontSize: 18,
          weight: FontWeight.w700,
          color: Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        centerTitle: false,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: backgroundGradient ?? AppTheme.primaryGradient,
              ),
            ),
            // Expanded content with fade-out
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ExpandedContentFadeOut(
                        expandedHeight: expandedHeight,
                        collapsedHeight: collapsedHeight,
                        child: expandedContent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight ?? 0),
              child: bottom!,
            )
          : null,
    );
  }
}

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
  State<_ExpandedContentFadeOut> createState() =>
      _ExpandedContentFadeOutState();
}

class _ExpandedContentFadeOutState extends State<_ExpandedContentFadeOut> {
  double _opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical) {
          final totalShrink = widget.expandedHeight - widget.collapsedHeight;
          if (totalShrink > 0) {
            final offset = notification.metrics.minScrollExtent - notification.metrics.pixels;
            setState(() {
              _opacity = (1.0 - (offset / totalShrink).clamp(0.0, 1.0)).clamp(0.0, 1.0);
            });
          }
        }
        return false;
      },
      child: Opacity(
        opacity: _opacity,
        child: widget.child,
      ),
    );
  }
}

class PanganSliverHeaderSimple extends StatelessWidget {
  final Widget expandedContent;
  final String collapsedTitle;
  final double expandedHeight;
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final bool floating;
  final bool pinned;

  const PanganSliverHeaderSimple({
    super.key,
    required this.expandedContent,
    required this.collapsedTitle,
    this.expandedHeight = 110,
    this.backgroundColor = AppTheme.brandPrimary,
    this.backgroundGradient,
    this.floating = true,
    this.pinned = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final collapsedHeight = kToolbarHeight + statusBarHeight;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      backgroundColor: backgroundColor,
      collapsedHeight: collapsedHeight,
      title: Text(
        collapsedTitle,
        style: AppTheme.poppins(
          fontSize: 18,
          weight: FontWeight.w700,
          color: Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        centerTitle: false,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: backgroundGradient ?? AppTheme.primaryGradient,
              ),
            ),
            // Expanded content with fade-out
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ExpandedContentFadeOut(
                        expandedHeight: expandedHeight,
                        collapsedHeight: collapsedHeight,
                        child: expandedContent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}