import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

/// Lists device images / videos via the media store (scoped storage friendly).
class MediaService {
  MediaService._();

  static Future<bool> requestPhotoAccess() async {
    final state = await PhotoManager.requestPermissionExtend();
    return state.isAuth || state.hasAccess;
  }

  static Future<List<AssetEntity>> listAssets({
    required RequestType type,
    int page = 0,
    int size = 80,
  }) async {
    final paths = await PhotoManager.getAssetPathList(
      type: type,
      onlyAll: true,
    );
    if (paths.isEmpty) return const [];
    return paths.first.getAssetListPaged(page: page, size: size);
  }

  static Future<Uint8List?> thumbnail(
    AssetEntity asset, {
    int width = 200,
    int height = 200,
  }) {
    return asset.thumbnailDataWithSize(ThumbnailSize(width, height));
  }

  static Future<bool> openAsset(AssetEntity asset) async {
    final file = await asset.file;
    return file != null;
  }
}
