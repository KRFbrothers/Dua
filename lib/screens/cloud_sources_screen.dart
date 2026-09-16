import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../offline/remote_prefs.dart';
import '../privacy/data_paths.dart';
import '../theme/dua_colors.dart';
import 'file_browser_screen.dart';

/// Privacy-first Cloud hub — connectors disabled until a later sync phase.
class CloudSourcesScreen extends StatefulWidget {
  const CloudSourcesScreen({super.key});

  @override
  State<CloudSourcesScreen> createState() => _CloudSourcesScreenState();
}

class _CloudSourcesScreenState extends State<CloudSourcesScreen> {
  String? _mirrorHint;

  @override
  void initState() {
    super.initState();
    assertOfflinePath('CloudSourcesScreen');
    _loadHint();
  }

  Future<void> _loadHint() async {
    final hint = await RemotePrefs.loadMirrorFolderHint();
    if (mounted) setState(() => _mirrorHint = hint);
  }

  void _comingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming in a later sync phase'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickLocalMirror() async {
    // Navigate to Documents / Downloads as a local "mirror" browser.
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: DuaColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Pick a local mirror folder',
                style: TextStyle(
                  color: DuaColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined,
                  color: DuaColors.cyanSoft),
              title: const Text('Documents',
                  style: TextStyle(color: DuaColors.textPrimary)),
              onTap: () => Navigator.pop(ctx, 'documents'),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined,
                  color: DuaColors.cyanSoft),
              title: const Text('Downloads',
                  style: TextStyle(color: DuaColors.textPrimary)),
              onTap: () => Navigator.pop(ctx, 'downloads'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined,
                  color: DuaColors.cyanSoft),
              title: const Text('App documents (sandbox)',
                  style: TextStyle(color: DuaColors.textPrimary)),
              onTap: () => Navigator.pop(ctx, 'app_docs'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;

    if (choice == 'app_docs') {
      final dir = await getApplicationDocumentsDirectory();
      await RemotePrefs.saveMirrorFolderHint(dir.path);
      if (!mounted) return;
      setState(() => _mirrorHint = dir.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mirror hint: ${dir.path}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final mode = choice == 'downloads'
        ? FileBrowserMode.downloads
        : FileBrowserMode.documents;
    final title = choice == 'downloads' ? 'Downloads' : 'Documents';
    await RemotePrefs.saveMirrorFolderHint(title);
    if (!mounted) return;
    setState(() => _mirrorHint = title);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FileBrowserScreen(title: title, mode: mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud'),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy first',
                  style: TextStyle(
                    color: DuaColors.cyanSoft,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Offline stays local. Cloud connect is optional — future sync '
                  'phase. Koi Drive/Dropbox/OneDrive abhi connect nahi hota.',
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
          _providerCard(
            icon: Icons.add_to_drive_outlined,
            name: 'Google Drive',
          ),
          const SizedBox(height: 10),
          _providerCard(
            icon: Icons.cloud_outlined,
            name: 'Dropbox',
          ),
          const SizedBox(height: 10),
          _providerCard(
            icon: Icons.cloud_circle_outlined,
            name: 'OneDrive',
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: _pickLocalMirror,
            icon: const Icon(Icons.folder_open_outlined),
            label: const Text('Pick a local mirror folder'),
            style: FilledButton.styleFrom(
              foregroundColor: DuaColors.cyanSoft,
              backgroundColor: DuaColors.surfaceElevated,
            ),
          ),
          if (_mirrorHint != null) ...[
            const SizedBox(height: 10),
            Text(
              'Last mirror: $_mirrorHint',
              style: const TextStyle(
                color: DuaColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _providerCard({required IconData icon, required String name}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DuaColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DuaColors.borderNeon),
      ),
      child: Row(
        children: [
          Icon(icon, color: DuaColors.blue, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: DuaColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Not connected — privacy first',
                  style: TextStyle(
                    color: DuaColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _comingSoon,
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
