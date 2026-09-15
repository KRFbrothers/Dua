import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/dua_colors.dart';

enum OfflinePermissionKind { photos, videos, audio, storage }

/// Requests media/storage permissions at tap time (not on Offline open).
class OfflinePermissionService {
  OfflinePermissionService._();

  static Future<bool> ensure(
    BuildContext context,
    OfflinePermissionKind kind,
  ) async {
    final permissions = _permissionsFor(kind);
    final statuses = await permissions.request();
    final granted = statuses.values.every(
      (s) => s.isGranted || s.isLimited || s.isRestricted,
    );

    if (granted) return true;

    final permanentlyDenied = statuses.values.any((s) => s.isPermanentlyDenied);
    if (!context.mounted) return false;

    final message = permanentlyDenied
        ? 'Permission denied. Open Settings to allow access.'
        : 'Permission needed to browse local files.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: DuaColors.surfaceElevated,
        content: Text(
          message,
          style: const TextStyle(color: DuaColors.textPrimary),
        ),
        action: SnackBarAction(
          label: 'Settings',
          textColor: DuaColors.cyan,
          onPressed: openAppSettings,
        ),
      ),
    );
    return false;
  }

  static List<Permission> _permissionsFor(OfflinePermissionKind kind) {
    switch (kind) {
      case OfflinePermissionKind.photos:
        return [Permission.photos, Permission.storage];
      case OfflinePermissionKind.videos:
        return [Permission.videos, Permission.storage];
      case OfflinePermissionKind.audio:
        return [Permission.audio, Permission.storage];
      case OfflinePermissionKind.storage:
        // Broad browse: photos+videos+audio cover API 33+; storage for older.
        return [
          Permission.photos,
          Permission.videos,
          Permission.audio,
          Permission.storage,
        ];
    }
  }
}
