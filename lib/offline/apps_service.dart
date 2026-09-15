import 'package:flutter/foundation.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

class LaunchableApp {
  const LaunchableApp({
    required this.name,
    required this.packageName,
    this.icon,
  });

  final String name;
  final String packageName;
  final Uint8List? icon;
}

class AppsService {
  AppsService._();

  static Future<List<LaunchableApp>> listLaunchable({
    bool withIcon = true,
  }) async {
    if (kIsWeb) return const [];
    try {
      final apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        excludeNonLaunchableApps: true,
        withIcon: withIcon,
      );
      final mapped = apps
          .map(
            (AppInfo a) => LaunchableApp(
              name: a.name,
              packageName: a.packageName,
              icon: a.icon,
            ),
          )
          .toList();
      mapped.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return mapped;
    } catch (_) {
      return const [];
    }
  }

  static Future<bool> launch(String packageName) async {
    try {
      final ok = await InstalledApps.startApp(packageName);
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }
}
