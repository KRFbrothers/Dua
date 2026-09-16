import 'package:flutter/material.dart';

import '../privacy/data_paths.dart';
import '../theme/dua_colors.dart';

/// Short privacy explainer (Phase 4) — Offline local, Online key, Voice STT.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _card(
            icon: Icons.folder_off_outlined,
            color: DuaColors.offlineRed,
            title: 'Offline — ${DataPathLabels.offlineLocal}',
            body:
                '${DataPathLabels.offlineSubtitle} Gallery, files, apps, and '
                'storage tools never call the LLM.',
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.cloud_outlined,
            color: DuaColors.onlineTeal,
            title: 'Online — ${DataPathLabels.onlineNeedsNetwork}',
            body:
                '${DataPathLabels.onlineSubtitle} Your API key is stored '
                'on-device in secure storage and only sent to the Base URL '
                'you configure.',
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.mic_none,
            color: DuaColors.cyan,
            title: 'Voice',
            body:
                '${DataPathLabels.voiceOnDevicePrefer} Toggle this in '
                'Settings. Offline voice intents stay local; agent answers '
                'still need Online + API key.',
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.hourglass_empty,
            color: DuaColors.purple,
            title: 'Phase 5 hubs',
            body:
                'Cloud / Remote / Access-from screens are local hubs '
                '(providers not connected yet). Voice Share / camera / Pulse '
                'work on-device. Full cloud sync & video call stay later.',
          ),
          const SizedBox(height: 24),
          const Text(
            'PRIVATE · OFFLINE · ONLINE · ALWAYS WITH YOU',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DuaColors.cyanSoft,
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DuaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DuaColors.borderNeon),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: DuaColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: DuaColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
