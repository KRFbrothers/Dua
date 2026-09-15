import 'package:open_filex/open_filex.dart';
import 'package:photo_manager/photo_manager.dart';

class OpenHelper {
  OpenHelper._();

  static Future<String?> openPath(String path) async {
    final result = await OpenFilex.open(path);
    if (result.type == ResultType.done) return null;
    return result.message;
  }

  static Future<String?> openAsset(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) return 'Could not resolve file for this item.';
    return openPath(file.path);
  }
}
