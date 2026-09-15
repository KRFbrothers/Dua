import 'package:flutter/material.dart';

import '../theme/dua_colors.dart';
import '../widgets/offline_tile.dart';
import 'apps_list_screen.dart';
import 'file_browser_screen.dart';
import 'media_gallery_screen.dart';
import 'storage_analysis_screen.dart';
import 'stub_detail_screen.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  static const _tiles = <OfflineTileData>[
    OfflineTileData(title: 'Main storage', icon: Icons.sd_storage_outlined),
    OfflineTileData(title: 'Downloads', icon: Icons.download_outlined),
    OfflineTileData(
      title: 'Storage Analysis',
      icon: Icons.pie_chart_outline,
      accent: DuaColors.purple,
    ),
    OfflineTileData(title: 'Images', icon: Icons.image_outlined),
    OfflineTileData(title: 'Audio', icon: Icons.audiotrack_outlined),
    OfflineTileData(title: 'Videos', icon: Icons.videocam_outlined),
    OfflineTileData(title: 'Documents', icon: Icons.description_outlined),
    OfflineTileData(title: 'Apps', icon: Icons.apps_outlined),
    OfflineTileData(title: 'New files', icon: Icons.fiber_new_outlined),
    OfflineTileData(
      title: 'Cloud',
      icon: Icons.cloud_outlined,
      accent: DuaColors.blue,
    ),
    OfflineTileData(
      title: 'Remote',
      icon: Icons.lan_outlined,
      accent: DuaColors.blue,
    ),
    OfflineTileData(
      title: 'Access from...',
      icon: Icons.link_outlined,
      accent: DuaColors.magenta,
    ),
  ];

  void _openTile(BuildContext context, OfflineTileData tile) {
    final Widget page;
    switch (tile.title) {
      case 'Images':
        page = const MediaGalleryScreen(
          title: 'Images',
          kind: MediaGalleryKind.images,
        );
      case 'Videos':
        page = const MediaGalleryScreen(
          title: 'Videos',
          kind: MediaGalleryKind.videos,
        );
      case 'Audio':
        page = const FileBrowserScreen(
          title: 'Audio',
          mode: FileBrowserMode.audio,
        );
      case 'Downloads':
        page = const FileBrowserScreen(
          title: 'Downloads',
          mode: FileBrowserMode.downloads,
        );
      case 'Documents':
        page = const FileBrowserScreen(
          title: 'Documents',
          mode: FileBrowserMode.documents,
        );
      case 'New files':
        page = const FileBrowserScreen(
          title: 'New files',
          mode: FileBrowserMode.recent,
        );
      case 'Main storage':
        page = const FileBrowserScreen(
          title: 'Main storage',
          mode: FileBrowserMode.folder,
        );
      case 'Storage Analysis':
        page = const StorageAnalysisScreen();
      case 'Apps':
        page = const AppsListScreen();
      case 'Cloud':
      case 'Remote':
      case 'Access from...':
        page = StubDetailScreen(
          title: tile.title,
          subtitle: 'Coming next — post-MVP sync / remote access.',
        );
      default:
        page = StubDetailScreen(title: tile.title);
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Offline'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'LOCAL',
                style: TextStyle(
                  color: DuaColors.cyanSoft,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Local files & storage',
              style: TextStyle(color: DuaColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: _tiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.92,
                ),
                itemBuilder: (context, index) {
                  final tile = _tiles[index];
                  return OfflineTile(
                    data: tile,
                    onTap: () => _openTile(context, tile),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
