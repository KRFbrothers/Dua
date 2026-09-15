import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/dua_colors.dart';

/// Placeholder node / constellation graphic for Online Agent screen.
class AgentNodeGraphic extends StatefulWidget {
  const AgentNodeGraphic({super.key, this.size = 160});

  final double size;

  @override
  State<AgentNodeGraphic> createState() => _AgentNodeGraphicState();
}

class _AgentNodeGraphicState extends State<AgentNodeGraphic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
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
          size: Size.square(widget.size),
          painter: _NodePainter(t: _controller.value),
        );
      },
    );
  }
}

class _NodePainter extends CustomPainter {
  _NodePainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final nodes = <Offset>[
      c,
      c + Offset(math.cos(t * math.pi * 2) * 48, math.sin(t * math.pi * 2) * 28),
      c + Offset(math.cos(t * math.pi * 2 + 2) * 55, math.sin(t * math.pi * 2 + 1) * 40),
      c + Offset(math.cos(t * math.pi * 2 + 4) * 42, -math.sin(t * math.pi * 2 + 2) * 50),
      c + const Offset(-50, 20),
      c + const Offset(40, -45),
    ];

    final line = Paint()
      ..color = DuaColors.cyan.withValues(alpha: 0.35)
      ..strokeWidth = 1.2;
    for (var i = 1; i < nodes.length; i++) {
      canvas.drawLine(nodes[0], nodes[i], line);
    }
    canvas.drawLine(nodes[1], nodes[2], line);
    canvas.drawLine(nodes[3], nodes[4], line);

    for (var i = 0; i < nodes.length; i++) {
      final r = i == 0 ? 10.0 : 5.0;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            i == 0 ? DuaColors.cyan : DuaColors.purple,
            (i == 0 ? DuaColors.blue : DuaColors.magenta).withValues(alpha: 0.2),
          ],
        ).createShader(Rect.fromCircle(center: nodes[i], radius: r * 2));
      canvas.drawCircle(nodes[i], r, paint);
      canvas.drawCircle(
        nodes[i],
        r * 2.2,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = DuaColors.cyan.withValues(alpha: 0.25)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NodePainter oldDelegate) => oldDelegate.t != t;
}
