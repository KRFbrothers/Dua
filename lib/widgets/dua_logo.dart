import 'package:flutter/material.dart';

import '../theme/dua_colors.dart';

/// Script-style “Dua” wordmark + optional tagline.
class DuaLogo extends StatelessWidget {
  const DuaLogo({
    super.key,
    this.showTagline = true,
    this.fontSize = 48,
    this.taglineSize = 11,
  });

  final bool showTagline;
  final double fontSize;
  final double taglineSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => DuaColors.neonGradient.createShader(bounds),
          child: Text(
            'Dua',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              fontFamily: 'serif',
              height: 1.0,
              letterSpacing: 1.5,
            ),
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            'ALWAYS WITH YOU',
            style: TextStyle(
              color: DuaColors.cyanSoft.withValues(alpha: 0.85),
              fontSize: taglineSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.2,
            ),
          ),
        ],
      ],
    );
  }
}
