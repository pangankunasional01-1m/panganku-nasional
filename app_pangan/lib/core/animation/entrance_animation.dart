import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper jeda animasi stagger
class Delay {
  final int milliseconds;
  const Delay(this.milliseconds);
}

/// Fade-in + slide (+ scale opsional) saat widget pertama tampil.
/// Memakai satu AnimationController (tanpa Timer) dan menghormati
/// pengaturan "kurangi animasi" milik sistem.
class EntranceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Delay? delay;
  final Curve curve;
  final Offset offset;
  final double scaleFrom;

  const EntranceAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 650),
    this.delay,
    this.curve = Curves.easeOutCubic,
    this.offset = const Offset(0, 0.14),
    this.scaleFrom = 1.0,
  });

  @override
  State<EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<EntranceAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final delayMs = widget.delay?.milliseconds ?? 0;
    final total = widget.duration + Duration(milliseconds: delayMs);
    _controller = AnimationController(vsync: this, duration: total);

    final begin = total.inMilliseconds == 0 ? 0.0 : delayMs / total.inMilliseconds;
    final fade = CurvedAnimation(parent: _controller, curve: Interval(begin, 1.0, curve: Curves.easeOut));
    final move = CurvedAnimation(parent: _controller, curve: Interval(begin, 1.0, curve: widget.curve));

    _opacity = fade;
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(move);
    _scale = Tween<double>(begin: widget.scaleFrom, end: 1.0).animate(move);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SlideTransition(position: _slide, child: widget.child);
    if (widget.scaleFrom != 1.0) {
      content = ScaleTransition(scale: _scale, child: content);
    }
    return FadeTransition(opacity: _opacity, child: content);
  }
}

/// Staggered column: tiap anak muncul berurutan
class StaggeredColumn extends StatelessWidget {
  final List<Widget> children;
  final int delayBetween;
  final Duration duration;

  const StaggeredColumn({
    super.key,
    required this.children,
    this.delayBetween = 110,
    this.duration = const Duration(milliseconds: 650),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(children.length, (index) {
        return EntranceAnimation(
          delay: Delay(index * delayBetween),
          duration: duration,
          child: children[index],
        );
      }),
    );
  }
}

/// Staggered wrap untuk grid
class StaggeredWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int delayBetween;
  final Duration duration;

  const StaggeredWrap({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.delayBetween = 80,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: List.generate(children.length, (index) {
        return EntranceAnimation(
          delay: Delay(index * delayBetween),
          duration: duration,
          scaleFrom: 0.92,
          child: children[index],
        );
      }),
    );
  }
}

/// Efek tekan: mengecil sedikit + haptic ringan. Aman dipakai untuk
/// kartu, chip, tombol — tanpa bentrok dengan gesture anak.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;
  final String? semanticLabel;

  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.96,
    this.haptic = true,
    this.semanticLabel,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: enabled ? () => _set(false) : null,
        onTap: enabled
            ? () {
                if (widget.haptic) HapticFeedback.selectionClick();
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1.0,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Kompatibel dengan versi lama.
class AnimatedScaleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;

  const AnimatedScaleButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  Widget build(BuildContext context) => Pressable(onTap: onPressed, scale: 0.94, child: child);
}

/// Format angka ribuan gaya Indonesia: 1200000 → 1.200.000
String formatNumber(num v) {
  final s = v.round().toString();
  return s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
}

/// Angka yang menghitung naik dari 0 saat pertama tampil.
class AnimatedCounter extends StatelessWidget {
  final double value;
  final String prefix;
  final String suffix;
  final TextStyle style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text('$prefix${formatNumber(v)}$suffix', style: style),
    );
  }
}

/// Titik berdenyut — penanda "sedang aktif / menunggu".
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  const PulseDot({super.key, required this.color, this.size = 8});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s * 2.4,
      height: s * 2.4,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value;
          final ring = s * (1 + 1.4 * t);
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: ring,
                height: ring,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.35 * (1 - t)),
                ),
              ),
              Container(
                width: s,
                height: s,
                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Melayang naik-turun pelan (untuk ikon dekoratif / empty state).
class Floating extends StatefulWidget {
  final Widget child;
  final double distance;
  const Floating({super.key, required this.child, this.distance = 7});

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (_, child) {
        final t = Curves.easeInOut.transform(_c.value);
        return Transform.translate(offset: Offset(0, -widget.distance * t), child: child);
      },
    );
  }
}

/// Gelombang suara mini (indikator mikrofon aktif).
class Waveform extends StatefulWidget {
  final Color color;
  const Waveform({super.key, required this.color});

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(5, (i) {
          final v = (math.sin(_c.value * 2 * math.pi + i * 0.9) + 1) / 2;
          return Container(
            width: 4,
            height: 8 + 18 * v,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(2)),
          );
        }),
      ),
    );
  }
}
