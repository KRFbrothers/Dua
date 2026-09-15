import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/dua_colors.dart';

/// Demo storage pie for Storage Analysis stub.
class StoragePieChart extends StatelessWidget {
  const StoragePieChart({super.key, this.size = 180});

  final double size;

  static const _slices = <_Slice>[
    _Slice('Images', 0.32, DuaColors.cyan),
    _Slice('Videos', 0.28, DuaColors.purple),
    _Slice('Audio', 0.12, DuaColors.blue),
    _Slice('Docs', 0.10, DuaColors.onlineTeal),
    _Slice('Apps', 0.12, DuaColors.magenta),
    _Slice('Other', 0.06, DuaColors.textMuted),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          size: Size.square(size),
          painter: _PiePainter(slices: _slices),
          child: SizedBox(
            width: size,
            height: size,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '64%',
                    style: TextStyle(
                      color: DuaColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'used · demo',
                    style: TextStyle(
                      color: DuaColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _slices
              .map(
                (s) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: s.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${s.label} ${(s.value * 100).round()}%',
                      style: const TextStyle(
                        color: DuaColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _Slice {
  const _Slice(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class _PiePainter extends CustomPainter {
  _PiePainter({required this.slices});

  final List<_Slice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var start = -math.pi / 2;

    for (final slice in slices) {
      final sweep = slice.value * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.butt
        ..color = slice.color;
      canvas.drawArc(rect, start, sweep - 0.02, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
