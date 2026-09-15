import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/dua_colors.dart';

/// Neon waveform bars for Voice mode.
class NeonWaveform extends StatefulWidget {
  const NeonWaveform({super.key, this.height = 120, this.active = true});

  final double height;
  final bool active;

  @override
  State<NeonWaveform> createState() => _NeonWaveformState();
}

class _NeonWaveformState extends State<NeonWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant NeonWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _WavePainter(t: _controller.value, active: widget.active),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.t, required this.active});

  final double t;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    const bars = 36;
    final barWidth = size.width / (bars * 1.8);
    final gap = barWidth * 0.8;
    final midY = size.height / 2;

    for (var i = 0; i < bars; i++) {
      final phase = (i / bars) * math.pi * 2;
      final amp = active
          ? (0.25 + 0.75 * ((math.sin(phase + t * math.pi * 2) + 1) / 2))
          : 0.2;
      final h = size.height * 0.7 * amp;
      final x = i * (barWidth + gap) + gap;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, midY),
          width: barWidth,
          height: h,
        ),
        const Radius.circular(4),
      );
      final paint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DuaColors.cyan,
            DuaColors.blue,
            DuaColors.purple,
          ],
        ).createShader(rect.outerRect);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.active != active;
}
