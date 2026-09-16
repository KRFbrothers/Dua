import 'package:flutter/material.dart';

import '../offline/remote_prefs.dart';
import '../privacy/data_paths.dart';
import '../theme/dua_colors.dart';

/// Explainer + opt-in remote access switch (default OFF).
class RemoteAccessScreen extends StatefulWidget {
  const RemoteAccessScreen({super.key});

  @override
  State<RemoteAccessScreen> createState() => _RemoteAccessScreenState();
}

class _RemoteAccessScreenState extends State<RemoteAccessScreen> {
  bool _allow = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    assertOfflinePath('RemoteAccessScreen');
    _load();
  }

  Future<void> _load() async {
    final v = await RemotePrefs.loadAllowRemoteAccess();
    if (!mounted) return;
    setState(() {
      _allow = v;
      _loading = false;
    });
  }

  Future<void> _setAllow(bool value) async {
    setState(() => _allow = value);
    await RemotePrefs.saveAllowRemoteAccess(value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Remote access ON — still local-only until a sync phase'
              : 'Remote access OFF — Offline files stay on device',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                DataPathLabels.offlineLocal,
                style: TextStyle(
                  color: DuaColors.cyanSoft,
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: DuaColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: DuaColors.borderNeon),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Remote access (optional)',
                        style: TextStyle(
                          color: DuaColors.cyanSoft,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Offline files never leave this phone without Online / API. '
                        'Yeh toggle sirf future remote features ke liye intent '
                        'store karta hai — abhi koi network sync nahi hota.',
                        style: TextStyle(
                          color: DuaColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DuaColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: DuaColors.borderNeon),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Allow remote access',
                      style: TextStyle(
                        color: DuaColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _allow
                          ? 'On — preference saved locally'
                          : 'Off (default) — privacy first',
                      style: const TextStyle(
                        color: DuaColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    value: _allow,
                    activeThumbColor: DuaColors.cyan,
                    onChanged: _setAllow,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tip: Cloud sync providers remain disconnected. Use '
                  'Access from… to copy files into Dua Documents manually.',
                  style: TextStyle(
                    color: DuaColors.textMuted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
    );
  }
}
