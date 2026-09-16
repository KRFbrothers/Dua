// Offline data path — local device only; must never call LLM/network APIs.
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalFileEntry {
  const LocalFileEntry({
    required this.path,
    required this.name,
    required this.isDirectory,
    this.size,
    this.modified,
  });

  final String path;
  final String name;
  final bool isDirectory;
  final int? size;
  final DateTime? modified;
}

/// Directory listing helpers for Downloads, docs, audio files, and main storage.
class FileBrowserService {
  FileBrowserService._();

  static const documentExtensions = <String>{
    '.pdf',
    '.txt',
    '.doc',
    '.docx',
    '.xls',
    '.xlsx',
    '.ppt',
    '.pptx',
    '.rtf',
    '.odt',
    '.csv',
    '.md',
  };

  static const audioExtensions = <String>{
    '.mp3',
    '.m4a',
    '.aac',
    '.wav',
    '.flac',
    '.ogg',
    '.wma',
    '.opus',
  };

  static const videoExtensions = <String>{
    '.mp4',
    '.mkv',
    '.avi',
    '.mov',
    '.webm',
    '.3gp',
  };

  static const imageExtensions = <String>{
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.bmp',
    '.heic',
  };

  /// Best-effort primary external storage root on Android.
  static Future<String?> primaryStorageRoot() async {
    if (!Platform.isAndroid) {
      final docs = await getApplicationDocumentsDirectory();
      return docs.path;
    }

    // Prefer classic primary volume when readable under scoped storage.
    const candidates = <String>[
      '/storage/emulated/0',
      '/sdcard',
    ];
    for (final c in candidates) {
      final dir = Directory(c);
      try {
        if (await dir.exists()) return c;
      } catch (_) {}
    }

    final ext = await getExternalStorageDirectory();
    if (ext != null) {
      // Climb out of Android/data/<pkg>/files when possible.
      var path = ext.path;
      final marker = '${p.separator}Android${p.separator}data';
      final idx = path.indexOf(marker);
      if (idx > 0) path = path.substring(0, idx);
      final dir = Directory(path);
      if (await dir.exists()) return path;
      return ext.path;
    }
    return null;
  }

  static Future<String?> downloadsPath() async {
    if (Platform.isAndroid) {
      final root = await primaryStorageRoot();
      if (root != null) {
        for (final name in ['Download', 'Downloads']) {
          final d = Directory(p.join(root, name));
          if (await d.exists()) return d.path;
        }
      }
    }
    try {
      final d = await getDownloadsDirectory();
      return d?.path;
    } catch (_) {
      return null;
    }
  }

  static Future<List<LocalFileEntry>> listDirectory(
    String dirPath, {
    bool includeHidden = false,
  }) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return const [];

    final entries = <LocalFileEntry>[];
    try {
      await for (final entity in dir.list(followLinks: false)) {
        final name = p.basename(entity.path);
        if (!includeHidden && name.startsWith('.')) continue;
        try {
          final stat = await entity.stat();
          entries.add(
            LocalFileEntry(
              path: entity.path,
              name: name,
              isDirectory: entity is Directory,
              size: entity is File ? stat.size : null,
              modified: stat.modified,
            ),
          );
        } catch (_) {
          entries.add(
            LocalFileEntry(
              path: entity.path,
              name: name,
              isDirectory: entity is Directory,
            ),
          );
        }
      }
    } catch (_) {
      return const [];
    }

    entries.sort((a, b) {
      if (a.isDirectory != b.isDirectory) {
        return a.isDirectory ? -1 : 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return entries;
  }

  static Future<List<LocalFileEntry>> findFiles({
    required Set<String> extensions,
    int maxResults = 200,
    int maxDepth = 3,
  }) async {
    final roots = <String>[];
    final download = await downloadsPath();
    final primary = await primaryStorageRoot();
    if (download != null) roots.add(download);
    if (primary != null) {
      for (final sub in [
        'Documents',
        'Download',
        'Downloads',
        'DCIM',
        'Pictures',
        'Music',
        'Movies',
        'Podcasts',
        'Audiobooks',
      ]) {
        final path = p.join(primary, sub);
        if (await Directory(path).exists()) roots.add(path);
      }
      if (!roots.contains(primary)) roots.add(primary);
    }

    final seen = <String>{};
    final results = <LocalFileEntry>[];

    for (final root in roots) {
      await _walk(
        root,
        depth: 0,
        maxDepth: maxDepth,
        extensions: extensions,
        results: results,
        seen: seen,
        maxResults: maxResults,
      );
      if (results.length >= maxResults) break;
    }

    results.sort((a, b) {
      final am = a.modified ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bm = b.modified ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bm.compareTo(am);
    });
    return results;
  }

  static Future<List<LocalFileEntry>> recentFiles({
    int maxResults = 120,
    int maxDepth = 2,
    Duration within = const Duration(days: 30),
  }) async {
    final cutoff = DateTime.now().subtract(within);
    final primary = await primaryStorageRoot();
    final download = await downloadsPath();
    final roots = <String>[
      if (download != null) download,
      if (primary != null) ...[
        p.join(primary, 'Download'),
        p.join(primary, 'Downloads'),
        p.join(primary, 'DCIM'),
        p.join(primary, 'Pictures'),
        p.join(primary, 'Documents'),
        p.join(primary, 'Music'),
        p.join(primary, 'Movies'),
      ],
    ];

    final results = <LocalFileEntry>[];
    final seen = <String>{};
    final allExt = {
      ...documentExtensions,
      ...audioExtensions,
      ...videoExtensions,
      ...imageExtensions,
    };

    for (final root in roots) {
      if (!await Directory(root).exists()) continue;
      await _walk(
        root,
        depth: 0,
        maxDepth: maxDepth,
        extensions: allExt,
        results: results,
        seen: seen,
        maxResults: maxResults * 2,
        modifiedAfter: cutoff,
      );
    }

    results.sort((a, b) {
      final am = a.modified ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bm = b.modified ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bm.compareTo(am);
    });
    if (results.length > maxResults) {
      return results.sublist(0, maxResults);
    }
    return results;
  }

  static Future<void> _walk(
    String dirPath, {
    required int depth,
    required int maxDepth,
    required Set<String> extensions,
    required List<LocalFileEntry> results,
    required Set<String> seen,
    required int maxResults,
    DateTime? modifiedAfter,
  }) async {
    if (results.length >= maxResults || depth > maxDepth) return;
    final dir = Directory(dirPath);
    List<FileSystemEntity> children;
    try {
      children = await dir.list(followLinks: false).toList();
    } catch (_) {
      return;
    }

    for (final entity in children) {
      if (results.length >= maxResults) return;
      final name = p.basename(entity.path);
      if (name.startsWith('.')) continue;

      if (entity is Directory) {
        // Skip heavy / private trees.
        if (name == 'Android' || name == 'obb' || name == 'data') {
          if (depth == 0 && dirPath.contains('emulated')) {
            continue;
          }
        }
        await _walk(
          entity.path,
          depth: depth + 1,
          maxDepth: maxDepth,
          extensions: extensions,
          results: results,
          seen: seen,
          maxResults: maxResults,
          modifiedAfter: modifiedAfter,
        );
        continue;
      }

      if (entity is! File) continue;
      final ext = p.extension(name).toLowerCase();
      if (!extensions.contains(ext)) continue;
      if (!seen.add(entity.path)) continue;

      try {
        final stat = await entity.stat();
        if (modifiedAfter != null && stat.modified.isBefore(modifiedAfter)) {
          continue;
        }
        results.add(
          LocalFileEntry(
            path: entity.path,
            name: name,
            isDirectory: false,
            size: stat.size,
            modified: stat.modified,
          ),
        );
      } catch (_) {}
    }
  }

  static String formatBytes(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
