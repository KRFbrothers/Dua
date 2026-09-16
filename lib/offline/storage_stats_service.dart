// Offline data path — local device only; must never call LLM/network APIs.
import 'package:disk_space_2/disk_space_2.dart';
import 'package:path_provider/path_provider.dart';

class StorageStats {
  const StorageStats({
    required this.totalMb,
    required this.freeMb,
    required this.sourceLabel,
  });

  final double totalMb;
  final double freeMb;
  final String sourceLabel;

  double get usedMb => (totalMb - freeMb).clamp(0, totalMb);
  double get usedFraction => totalMb <= 0 ? 0 : (usedMb / totalMb).clamp(0, 1);

  String get usedLabel => formatMb(usedMb);
  String get freeLabel => formatMb(freeMb);
  String get totalLabel => formatMb(totalMb);

  static String formatMb(double mb) {
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(0)} MB';
  }
}

class StorageStatsService {
  StorageStatsService._();

  static Future<StorageStats> load() async {
    try {
      final free = await DiskSpace.getFreeDiskSpace;
      final total = await DiskSpace.getTotalDiskSpace;
      if (free != null && total != null && total > 0) {
        return StorageStats(
          totalMb: total,
          freeMb: free,
          sourceLabel: 'Device storage',
        );
      }
    } catch (_) {}

    // Fallback: approximate via app documents path free space if available.
    try {
      final docs = await getApplicationDocumentsDirectory();
      final free = await DiskSpace.getFreeDiskSpaceForPath(docs.path);
      if (free != null) {
        final total = free * 2.5; // rough demo when total unavailable
        return StorageStats(
          totalMb: total,
          freeMb: free,
          sourceLabel: 'Approx (app path)',
        );
      }
    } catch (_) {}

    // Improved demo numbers if plugins fail (emulator / desktop).
    return const StorageStats(
      totalMb: 128 * 1024,
      freeMb: 46 * 1024,
      sourceLabel: 'Demo estimate',
    );
  }
}
