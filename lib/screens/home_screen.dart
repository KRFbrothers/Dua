import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../agent/agent_settings.dart';
import '../privacy/data_paths.dart';
import '../theme/dua_colors.dart';
import '../widgets/dua_logo.dart';
import '../widgets/mode_cta_button.dart';
import '../widgets/neon_orb.dart';
import 'offline_screen.dart';
import 'online_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _openOnline(BuildContext context) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '${DataPathLabels.onlineNeedsNetwork} — Online agent uses the internet.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final settings = await AgentSettings.load();
    if (!settings.hasApiKey) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API key required. Open Online settings first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OnlineScreen()),
    );
  }

  void _openOffline(BuildContext context) {
    assertOfflinePath('Home→Offline');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OfflineScreen()),
    );
  }

  Widget _onlineButton(BuildContext context) {
    return FutureBuilder<AgentSettings>(
      future: AgentSettings.load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _disabledOnlineButton('Checking..');
        final hasKey = snapshot.data!.hasApiKey;
        return ModeCtaButton(
          label: hasKey ? 'Online' : 'Set API key',
          color: DuaColors.onlineTeal,
          icon: hasKey ? Icons.cloud_outlined : Icons.key_outlined,
          onPressed: hasKey ? () => _openOnline(context) : null,
        );
      },
    );
  }

  Widget _disabledOnlineButton(String label) {
    return ModeCtaButton(
      label: label,
      color: DuaColors.onlineTeal,
      icon: Icons.cloud_outlined,
      onPressed: null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DuaColors.darkNavy, DuaColors.darkPurple],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            const DuaLogo(),
            const Spacer(),
            const NeonOrb(size: 200, onTap: null),
            const SizedBox(height: 28),
            Text(
              'Tap mic for Voice',
              style: TextStyle(
                color: DuaColors.textMuted.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ModeCtaButton(
                      label: 'Offline',
                      color: DuaColors.offlineRed,
                      icon: Icons.folder_off_outlined,
                      onPressed: () => _openOffline(context),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: _onlineButton(context)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Offline = local  ·  Online = network + API key',
              style: TextStyle(
                color: DuaColors.textMuted.withValues(alpha: 0.85),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
