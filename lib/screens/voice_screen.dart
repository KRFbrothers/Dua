import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../privacy/data_paths.dart';
import '../theme/dua_colors.dart';
import '../widgets/dua_logo.dart';
import '../widgets/mode_cta_button.dart';
import '../widgets/neon_orb.dart';
import 'agent_settings_screen.dart';
import 'offline_screen.dart';
import 'online_screen.dart';
import 'privacy_screen.dart';
import 'voice_screen.dart';

import '../providers/connectivity_provider.dart';
import '../services/ai_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _openOnline(BuildContext context, WidgetRef ref) async {
    final connectivityResult = await ref.read(connectivityProvider.future);
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${DataPathLabels.onlineNeedsNetwork} — Online agent uses the internet.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final response = await AiService.getOnlineResponse('Give me a dua for success');
    print('Online Service Response: $response');

    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OnlineScreen()),
    );
  }

  void _openOffline(BuildContext context, WidgetRef ref) {
    assertOfflinePath('Home→Offline');

    final response = AiService.getOfflineResponse('Give me a dua for protection');
    print('Offline Service Response: $response');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(DataPathLabels.offlineSubtitle),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OfflineScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsyncValue = ref.watch(connectivityProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DuaColors.darkNavy,
              DuaColors.darkPurple,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            const DuaLogo(),
            const Spacer(),
            const NeonOrb(
              size: 200,
              onTap: null,
            ),
            const SizedBox(height: 28),
            const SizedBox(height: 8),
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
                      onPressed: () => _openOffline(context, ref),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: connectivityAsyncValue.when(
                      data: (connectivityResult) {
                        final isOnline = connectivityResult != ConnectivityResult.none;
                        return ModeCtaButton(
                          label: 'Online',
                          color: DuaColors.onlineTeal,
                          icon: Icons.cloud_outlined,
                          onPressed: isOnline
                              ? () => _openOnline(context, ref)
                              : null,
                        );
                      },
                      loading: () => ModeCtaButton(
                        label: 'Checking..',
                        color: DuaColors.onlineTeal,
                        icon: Icons.cloud_outlined,
                        onPressed: null,
                      ),
                      error: (err, stack) => ModeCtaButton(
                        label: 'Error',
                        color: DuaColors.onlineTeal,
                        icon: Icons.error_outline,
                        onPressed: null,
                      ),
                    ),
                  ),
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
