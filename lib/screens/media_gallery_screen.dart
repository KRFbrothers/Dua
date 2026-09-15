import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../offline/media_service.dart';
import '../offline/open_helper.dart';
import '../offline/permission_service.dart';
import '../theme/dua_colors.dart';
import '../widgets/offline_empty_state.dart';

enum MediaGalleryKind { images, videos }

class MediaGalleryScreen extends StatefulWidget {
  const MediaGalleryScreen({
    super.key,
    required this.title,
    required this.kind,
  });

  final String title;
  final MediaGalleryKind kind;

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen> {
  final List<AssetEntity> _assets = [];
  final Map<String, Uint8List?> _thumbs = {};
  bool _loading = true;
  bool _denied = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _denied = false;
      _error = null;
    });

    final permKind = widget.kind == MediaGalleryKind.images
        ? OfflinePermissionKind.photos
        : OfflinePermissionKind.videos;
    final ok = await OfflinePermissionService.ensure(context, permKind);
    if (!ok) {
      if (mounted) {
        setState(() {
          _loading = false;
          _denied = true;
        });
      }
      return;
    }

    final photoOk = await MediaService.requestPhotoAccess();
    if (!photoOk) {
      if (mounted) {
        setState(() {
          _loading = false;
          _denied = true;
        });
      }
      return;
    }

    try {
      final type = widget.kind == MediaGalleryKind.images
          ? RequestType.image
          : RequestType.video;
      final assets = await MediaService.listAssets(type: type);
      if (!mounted) return;
      setState(() {
        _assets
          ..clear()
          ..addAll(assets);
        _loading = false;
      });
      for (final a in assets.take(60)) {
        final bytes = await MediaService.thumbnail(a);
        if (!mounted) return;
        setState(() => _thumbs[a.id] = bytes);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load media.';
        });
      }
    }
  }

  Future<void> _open(AssetEntity asset) async {
    final err = await OpenHelper.openAsset(asset);
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: DuaColors.surfaceElevated,
          content: Text(err, style: const TextStyle(color: DuaColors.textPrimary)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _buildBody(),
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
        subtitle: 'Allow media access in Settings, then refresh.',
        onRetry: _load,
      );
    }
    if (_error != null) {
      return OfflineEmptyState(
        icon: Icons.error_outline,
        title: _error!,
        subtitle: 'Try again.',
        onRetry: _load,
      );
    }
    if (_assets.isEmpty) {
      return OfflineEmptyState(
        icon: widget.kind == MediaGalleryKind.images
            ? Icons.image_outlined
            : Icons.videocam_outlined,
        title: 'No ${widget.title.toLowerCase()} found',
        subtitle: 'Nothing in the device media library yet.',
        onRetry: _load,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        final thumb = _thumbs[asset.id];
        return Material(
          color: DuaColors.card,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _open(asset),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumb != null)
                    Image.memory(thumb, fit: BoxFit.cover)
                  else
                    Container(
                      color: DuaColors.surfaceElevated,
                      child: Icon(
                        widget.kind == MediaGalleryKind.images
                            ? Icons.image_outlined
                            : Icons.videocam_outlined,
                        color: DuaColors.cyan.withValues(alpha: 0.5),
                      ),
                    ),
                  if (widget.kind == MediaGalleryKind.videos)
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.play_circle_fill,
                          color: DuaColors.cyanSoft,
                          size: 22,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
