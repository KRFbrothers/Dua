import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/dua_colors.dart';

/// Center orb / soft waveform mark for Home.
class NeonOrb extends StatefulWidget {
  const NeonOrb({super.key, this.size = 180, this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  State<NeonOrb> createState() => _NeonOrbState();
}

class _NeonOrbState extends State<NeonOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.square(widget.size),
            painter: _OrbPainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.32;

    // Outer glow rings
    for (var i = 3; i >= 1; i--) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            DuaColors.cyan.withValues(alpha: 0.12 / i),
            DuaColors.purple.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * (1.4 + i * 0.35)));
      canvas.drawCircle(center, radius * (1.4 + i * 0.35), paint);
    }

    // Core orb
    final corePaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF7CF0FF),
          DuaColors.blue,
          DuaColors.purple,
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, corePaint);

    // Soft highlight
    canvas.drawCircle(
      center.translate(-radius * 0.25, -radius * 0.3),
      radius * 0.35,
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );

    // Waveform arcs
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = DuaColors.cyanSoft.withValues(alpha: 0.7);

    for (var ring = 0; ring < 3; ring++) {
      final r = radius * (1.15 + ring * 0.18);
      final path = Path();
      for (var a = 0; a <= 360; a += 4) {
        final rad = (a + progress * 360 + ring * 40) * math.pi / 180;
        final wobble = math.sin(rad * 3 + progress * math.pi * 2) * 4;
        final p = Offset(
          center.dx + math.cos(rad) * (r + wobble),
          center.dy + math.sin(rad) * (r + wobble),
        );
        if (a == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        wavePaint..color = DuaColors.cyanSoft.withValues(alpha: 0.45 - ring * 0.1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
