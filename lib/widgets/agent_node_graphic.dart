import 'package:flutter/material.dart';

import '../theme/dua_colors.dart';

/// Soft constellation / node graph for Online Agent (static).
class AgentNodeGraphic extends StatelessWidget {
  const AgentNodeGraphic({super.key, this.size = 160});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _NodePainter(),
    );
  }
}

class _NodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    const pulse = 0.5; // Static value

    final nodes = <Offset>[
      c,
      c + const Offset(50, 0),
      c + const Offset(-25, 40),
      c + const Offset(-44, -52),
      c + const Offset(36, 38),
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
      final r = i == 0 ? 9.0 + pulse * 2.0 : 4.5 + (i.isEven ? pulse : 1 - pulse);
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
  bool shouldRepaint(covariant _NodePainter oldDelegate) => false;
}
