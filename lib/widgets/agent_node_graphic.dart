import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/dua_colors.dart';

/// Soft constellation / node graph for Online Agent (Phase 4 polish).
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
      duration: const Duration(seconds: 10),
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
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    final nodes = <Offset>[
      c,
      c + Offset(
        math.cos(t * math.pi * 2) * 50,
        math.sin(t * math.pi * 2) * 30,
      ),
      c + Offset(
        math.cos(t * math.pi * 2 + 2.1) * 58,
        math.sin(t * math.pi * 2 + 1.2) * 42,
      ),
      c + Offset(
        math.cos(t * math.pi * 2 + 4.0) * 44,
        -math.sin(t * math.pi * 2 + 2.4) * 52,
      ),
      c + Offset(
        math.cos(t * math.pi * 2 + 5.2) * 36,
        math.sin(t * math.pi * 2 + 3.1) * 38,
      ),
      c + const Offset(-52, 22),
      c + const Offset(42, -48),
    ];

    final cyanLine = Paint()
      ..color = DuaColors.cyan.withValues(alpha: 0.28 + pulse * 0.12)
      ..strokeWidth = 1.15;
    final purpleLine = Paint()
      ..color = DuaColors.purple.withValues(alpha: 0.22 + pulse * 0.1)
      ..strokeWidth = 1.0;

    for (var i = 1; i < nodes.length; i++) {
      canvas.drawLine(nodes[0], nodes[i], cyanLine);
    }
    canvas.drawLine(nodes[1], nodes[2], cyanLine);
    canvas.drawLine(nodes[3], nodes[4], cyanLine);
    canvas.drawLine(nodes[5], nodes[6], purpleLine);

    for (var i = 0; i < nodes.length; i++) {
      final r =
          i == 0 ? 9.0 + pulse * 2.0 : 4.5 + (i.isEven ? pulse : 1 - pulse);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            i == 0 ? DuaColors.cyan : DuaColors.purple,
            (i == 0 ? DuaColors.blue : DuaColors.magenta).withValues(alpha: 0.2),
          ],
        ).createShader(Rect.fromCircle(center: nodes[i], radius: r * 2.2));
      canvas.drawCircle(nodes[i], r, paint);
      canvas.drawCircle(
        nodes[i],
        r * 2.4,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = DuaColors.cyan.withValues(alpha: 0.18 + pulse * 0.12)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NodePainter oldDelegate) => oldDelegate.t != t;
}
