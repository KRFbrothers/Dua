import 'package:flutter/material.dart';

import '../theme/dua_colors.dart';
import '../widgets/dua_logo.dart';
import '../widgets/mode_cta_button.dart';
import '../widgets/neon_orb.dart';
import 'offline_screen.dart';
import 'online_screen.dart';
import 'voice_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Menu stub — settings coming later.'),
                            behavior: SnackBarBehavior.floating,
                          ),
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
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OfflineScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ModeCtaButton(
                        label: 'Online',
                        color: DuaColors.onlineTeal,
                        icon: Icons.cloud_outlined,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OnlineScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
