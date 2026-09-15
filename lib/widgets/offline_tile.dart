import 'package:flutter/material.dart';

import '../theme/dua_colors.dart';

class OfflineTileData {
  const OfflineTileData({
    required this.title,
    required this.icon,
    this.accent = DuaColors.cyan,
  });

  final String title;
  final IconData icon;
  final Color accent;
}

class OfflineTile extends StatelessWidget {
  const OfflineTile({
    super.key,
    required this.data,
    required this.onTap,
  });

  final OfflineTileData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: DuaColors.card,
            border: Border.all(color: data.accent.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: data.accent.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.accent.withValues(alpha: 0.15),
                    border: Border.all(color: data.accent.withValues(alpha: 0.5)),
                  ),
                  child: Icon(data.icon, color: data.accent, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DuaColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
