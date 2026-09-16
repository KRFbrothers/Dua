import 'package:flutter/material.dart';

import '../privacy/data_paths.dart';
import '../theme/dua_colors.dart';
import 'file_browser_screen.dart';

/// Checklist: get files into Dua Documents via share / Open with / copy.
class AccessFromScreen extends StatelessWidget {
  const AccessFromScreen({super.key});

  void _openDocuments(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FileBrowserScreen(
          title: 'Documents',
          mode: FileBrowserMode.documents,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assertOfflinePath('AccessFromScreen');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access from…'),
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DuaColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: DuaColors.borderNeon),
            ),
            child: const Text(
              'Files Dua mein kaise laao — share sheet, Open with, ya Downloads '
              'se copy. Sab local; koi cloud sync nahi.',
              style: TextStyle(
                color: DuaColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _step(
            n: '1',
            title: 'Share sheet',
            body:
                'Any app → Share → save / copy the file into Downloads or Documents.',
          ),
          _step(
            n: '2',
            title: 'Open with / copy',
            body:
                'File manager mein Open with / Copy → paste into Downloads or '
                'a Documents folder Dua can browse.',
          ),
          _step(
            n: '3',
            title: 'Open in Dua',
            body:
                'Offline → Documents (or Downloads / New files) se browse karo. '
                'Tap below to jump straight to Documents.',
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _openDocuments(context),
            icon: const Icon(Icons.description_outlined),
            label: const Text('Open Documents'),
            style: FilledButton.styleFrom(
              backgroundColor: DuaColors.magenta.withValues(alpha: 0.85),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FileBrowserScreen(
                    title: 'Downloads',
                    mode: FileBrowserMode.downloads,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download_outlined, color: DuaColors.cyanSoft),
            label: const Text(
              'Open Downloads',
              style: TextStyle(color: DuaColors.cyanSoft),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: DuaColors.borderNeon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step({
    required String n,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DuaColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DuaColors.borderNeon),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: DuaColors.magenta),
                color: DuaColors.magenta.withValues(alpha: 0.2),
              ),
              child: Text(
                n,
                style: const TextStyle(
                  color: DuaColors.magenta,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: const TextStyle(
                      color: DuaColors.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
