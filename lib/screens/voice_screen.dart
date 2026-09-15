import 'package:flutter/material.dart';

import '../theme/dua_colors.dart';
import '../widgets/dua_logo.dart';
import '../widgets/waveform.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  bool _listening = true;

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — stub (post-MVP)'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF141428), DuaColors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: DuaColors.cyanSoft),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    const DuaLogo(showTagline: false, fontSize: 28),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: DuaColors.cyan.withValues(alpha: 0.55),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DuaColors.cyan.withValues(alpha: 0.15),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                      color: DuaColors.surface.withValues(alpha: 0.6),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Voice Mode',
                          style: TextStyle(
                            color: DuaColors.cyanSoft,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: NeonWaveform(
                            height: 140,
                            active: _listening,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tum',
                            style: TextStyle(
                              color: DuaColors.textMuted,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '“Dua, gallery kholo”',
                            style: TextStyle(
                              color: DuaColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Dua',
                            style: TextStyle(
                              color: DuaColors.cyanSoft,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Gallery khol rahi hoon…',
                            style: TextStyle(
                              color: DuaColors.textSecondary,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Control(
                      icon: Icons.screen_share_outlined,
                      label: 'Share',
                      onTap: () => _stub('Screen share'),
                    ),
                    _Control(
                      icon: Icons.videocam_outlined,
                      label: 'Video',
                      onTap: () => _stub('Video'),
                    ),
                    _MicControl(
                      listening: _listening,
                      onTap: () => setState(() => _listening = !_listening),
                    ),
                    _Control(
                      icon: Icons.graphic_eq,
                      label: 'Pulse',
                      onTap: () => _stub('Pulse'),
                    ),
                    _Control(
                      icon: Icons.call_end,
                      label: 'End',
                      color: DuaColors.offlineRed,
                      filled: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Control extends StatelessWidget {
  const _Control({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = DuaColors.textSecondary,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? color : DuaColors.surfaceElevated,
              border: Border.all(
                color: filled ? color : DuaColors.borderNeon,
              ),
            ),
            child: Icon(icon, color: filled ? Colors.white : color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: DuaColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

class _MicControl extends StatelessWidget {
  const _MicControl({required this.listening, required this.onTap});

  final bool listening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: listening ? DuaColors.orbGradient : null,
              color: listening ? null : DuaColors.surfaceElevated,
              border: Border.all(
                color: listening ? DuaColors.cyan : DuaColors.borderNeon,
                width: 2,
              ),
              boxShadow: listening
                  ? [
                      BoxShadow(
                        color: DuaColors.cyan.withValues(alpha: 0.45),
                        blurRadius: 18,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              listening ? Icons.mic : Icons.mic_off,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          listening ? 'Listening' : 'Muted',
          style: const TextStyle(color: DuaColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}
