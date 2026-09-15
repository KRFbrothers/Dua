import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../offline/file_browser_service.dart';
import '../offline/open_helper.dart';
import '../offline/permission_service.dart';
import '../theme/dua_colors.dart';
import '../widgets/offline_empty_state.dart';

enum FileBrowserMode {
  folder,
  downloads,
  documents,
  audio,
  recent,
}

class FileBrowserScreen extends StatefulWidget {
  const FileBrowserScreen({
    super.key,
    required this.title,
    required this.mode,
    this.initialPath,
  });

  final String title;
  final FileBrowserMode mode;
  final String? initialPath;

  @override
  State<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends State<FileBrowserScreen> {
  final List<String> _stack = [];
  List<LocalFileEntry> _entries = [];
  bool _loading = true;
  bool _denied = false;
  String? _error;
  String? _rootLabel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _denied = false;
      _error = null;
    });

    final ok = await OfflinePermissionService.ensure(
      context,
      OfflinePermissionKind.storage,
    );
    if (!ok) {
      if (mounted) {
        setState(() {
          _loading = false;
          _denied = true;
        });
      }
      return;
    }

    try {
      switch (widget.mode) {
        case FileBrowserMode.folder:
          final root = widget.initialPath ??
              await FileBrowserService.primaryStorageRoot();
          if (root == null) {
            setState(() {
              _loading = false;
              _error = 'Storage root not available.';
            });
            return;
          }
          _stack
            ..clear()
            ..add(root);
          _rootLabel = root;
          await _loadFolder(root);
          break;
        case FileBrowserMode.downloads:
          final path = await FileBrowserService.downloadsPath();
          if (path == null) {
            setState(() {
              _loading = false;
              _error = 'Downloads folder not found.';
            });
            return;
          }
          _stack
            ..clear()
            ..add(path);
          _rootLabel = path;
          await _loadFolder(path);
          break;
        case FileBrowserMode.documents:
          final docs = await FileBrowserService.findFiles(
            extensions: FileBrowserService.documentExtensions,
          );
          setState(() {
            _entries = docs;
            _loading = false;
            _rootLabel = 'Documents by type';
          });
          break;
        case FileBrowserMode.audio:
          final audio = await FileBrowserService.findFiles(
            extensions: FileBrowserService.audioExtensions,
          );
          setState(() {
            _entries = audio;
            _loading = false;
            _rootLabel = 'Audio files';
          });
          break;
        case FileBrowserMode.recent:
          final recent = await FileBrowserService.recentFiles();
          setState(() {
            _entries = recent;
            _loading = false;
            _rootLabel = 'Recent (30 days)';
          });
          break;
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not list files.';
        });
      }
    }
  }

  Future<void> _loadFolder(String path) async {
    setState(() => _loading = true);
    final entries = await FileBrowserService.listDirectory(path);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  bool get _isFolderMode =>
      widget.mode == FileBrowserMode.folder ||
      widget.mode == FileBrowserMode.downloads;

  Future<void> _openEntry(LocalFileEntry entry) async {
    if (entry.isDirectory && _isFolderMode) {
      _stack.add(entry.path);
      await _loadFolder(entry.path);
      return;
    }
    final err = await OpenHelper.openPath(entry.path);
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: DuaColors.surfaceElevated,
          content: Text(
            err,
            style: const TextStyle(color: DuaColors.textPrimary),
          ),
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_isFolderMode && _stack.length > 1) {
      _stack.removeLast();
      await _loadFolder(_stack.last);
      return false;
    }
    return true;
  }

  IconData _iconFor(LocalFileEntry e) {
    if (e.isDirectory) return Icons.folder_outlined;
    final ext = p.extension(e.name).toLowerCase();
    if (FileBrowserService.imageExtensions.contains(ext)) {
      return Icons.image_outlined;
    }
    if (FileBrowserService.videoExtensions.contains(ext)) {
      return Icons.videocam_outlined;
    }
    if (FileBrowserService.audioExtensions.contains(ext)) {
      return Icons.audiotrack_outlined;
    }
    if (FileBrowserService.documentExtensions.contains(ext)) {
      return Icons.description_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !(_isFolderMode && _stack.length > 1),
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _onWillPop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loading ? null : _bootstrap,
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_rootLabel != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  _isFolderMode && _stack.isNotEmpty ? _stack.last : _rootLabel!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DuaColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: DuaColors.cyan),
      );
    }
    if (_denied) {
      return OfflineEmptyState(
        icon: Icons.lock_outline,
        title: 'Permission required',
        subtitle: 'Allow storage / media access, then refresh.',
        onRetry: _bootstrap,
      );
    }
    if (_error != null) {
      return OfflineEmptyState(
        icon: Icons.error_outline,
        title: _error!,
        subtitle: 'Try again or check device storage.',
        onRetry: _bootstrap,
      );
    }
    if (_entries.isEmpty) {
      return OfflineEmptyState(
        icon: Icons.inbox_outlined,
        title: 'Nothing here',
        subtitle: 'No files matched this view.',
        onRetry: _bootstrap,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      itemCount: _entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final e = _entries[index];
        final subtitleParts = <String>[
          if (e.size != null && !e.isDirectory)
            FileBrowserService.formatBytes(e.size),
          if (e.modified != null)
            '${e.modified!.year}-${e.modified!.month.toString().padLeft(2, '0')}-${e.modified!.day.toString().padLeft(2, '0')}',
        ];
        return Material(
          color: DuaColors.card,
          borderRadius: BorderRadius.circular(14),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: DuaColors.borderNeon),
            ),
            leading: CircleAvatar(
              backgroundColor: DuaColors.cyan.withValues(alpha: 0.12),
              child: Icon(_iconFor(e), color: DuaColors.cyanSoft, size: 20),
            ),
            title: Text(
              e.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DuaColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: subtitleParts.isEmpty
                ? null
                : Text(
                    subtitleParts.join(' - '),
                    style: const TextStyle(
                      color: DuaColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
            trailing: e.isDirectory
                ? const Icon(Icons.chevron_right, color: DuaColors.textMuted)
                : null,
            onTap: () => _openEntry(e),
          ),
        );
      },
    );
  }
}
