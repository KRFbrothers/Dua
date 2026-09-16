import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local prefs for Offline Remote / Voice Pulse (Phase 5).
/// Matches [AgentSettings] secure-storage pattern — no network.
abstract final class RemotePrefs {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const _kAllowRemote = 'dua_allow_remote_access';
  static const _kPulseBoost = 'dua_pulse_boost';
  static const _kMirrorFolderHint = 'dua_local_mirror_folder_hint';

  /// Default OFF — privacy first; Offline files never leave without Online/API.
  static Future<bool> loadAllowRemoteAccess() async {
    final raw = await _storage.read(key: _kAllowRemote);
    return raw != null && raw.toLowerCase() == 'true';
  }

  static Future<void> saveAllowRemoteAccess(bool value) async {
    await _storage.write(
      key: _kAllowRemote,
      value: value ? 'true' : 'false',
    );
  }

  /// Voice Pulse boost — stronger waveform even when not listening.
  static Future<bool> loadPulseBoost() async {
    final raw = await _storage.read(key: _kPulseBoost);
    return raw != null && raw.toLowerCase() == 'true';
  }

  static Future<void> savePulseBoost(bool value) async {
    await _storage.write(
      key: _kPulseBoost,
      value: value ? 'true' : 'false',
    );
  }

  /// Optional label for a local mirror folder (Documents / Downloads path hint).
  static Future<String?> loadMirrorFolderHint() async {
    final v = await _storage.read(key: _kMirrorFolderHint);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  static Future<void> saveMirrorFolderHint(String? path) async {
    if (path == null || path.trim().isEmpty) {
      await _storage.delete(key: _kMirrorFolderHint);
    } else {
      await _storage.write(key: _kMirrorFolderHint, value: path.trim());
    }
  }
}
