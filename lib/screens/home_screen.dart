import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openOnline(BuildContext context) async {
    try {
      final results = await Connectivity().checkConnectivity();
      final offline = results.isEmpty ||
          results.every((r) => r == ConnectivityResult.none);
      if (offline && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${DataPathLabels.onlineNeedsNetwork} — Online agent uses the internet.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Still navigate — do not block forever.
      }
    } catch (_) {
      // Connectivity plugin may fail on some hosts; allow entry anyway.
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OnlineScreen()),
    );
  }

  void _openOffline(BuildContext context) {
    assertOfflinePath('Home→Offline');
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.1,
            colors: [
              Color(0xFF12121C),
              DuaColors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Menu',
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: DuaColors.surfaceElevated,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (ctx) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.settings_outlined,
                                      color: DuaColors.cyanSoft,
                                    ),
                                    title: const Text('Settings'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AgentSettingsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.privacy_tip_outlined,
                                      color: DuaColors.cyanSoft,
                                    ),
                                    title: const Text('Privacy'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const PrivacyScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.menu, color: DuaColors.cyanSoft),
                    ),
                    const Spacer(),
                    Text(
                      'PRIVATE',
                      style: TextStyle(
                        color: DuaColors.textMuted.withValues(alpha: 0.9),
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const DuaLogo(fontSize: 52, taglineSize: 11),
              const Spacer(flex: 2),
              NeonOrb(
                size: 200,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VoiceScreen()),
                ),
              ),
              const SizedBox(height: 28),
              NeonMicButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VoiceScreen()),
                ),
              ),
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
                        onPressed: () => _openOffline(context),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ModeCtaButton(
                        label: 'Online',
                        color: DuaColors.onlineTeal,
                        icon: Icons.cloud_outlined,
                        onPressed: () => _openOnline(context),
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
      ),
    );
  }
}
