import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely stored LLM + privacy prefs (API key never hardcoded).
class AgentSettings {
  AgentSettings({
    this.apiKey = '',
    this.baseUrl = defaultBaseUrl,
    this.model = defaultModel,
    this.preferOnDeviceStt = true,
  });

  static const String defaultBaseUrl = 'https://api.openai.com/v1';
  static const String defaultModel = 'gpt-4o-mini';

  static const _kApiKey = 'dua_llm_api_key';
  static const _kBaseUrl = 'dua_llm_base_url';
  static const _kModel = 'dua_llm_model';
  static const _kPreferOnDeviceStt = 'dua_prefer_on_device_stt';

  final String apiKey;
  final String baseUrl;
  final String model;

  /// When true, Voice Mode requests on-device STT first (privacy).
  final bool preferOnDeviceStt;

  bool get hasApiKey => apiKey.trim().isNotEmpty;

  String get normalizedBaseUrl {
    var u = baseUrl.trim();
    if (u.isEmpty) u = defaultBaseUrl;
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  String get effectiveModel {
    final m = model.trim();
    return m.isEmpty ? defaultModel : m;
  }

  AgentSettings copyWith({
    String? apiKey,
    String? baseUrl,
    String? model,
    bool? preferOnDeviceStt,
  }) {
    return AgentSettings(
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      preferOnDeviceStt: preferOnDeviceStt ?? this.preferOnDeviceStt,
    );
  }

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<AgentSettings> load() async {
    final key = await _storage.read(key: _kApiKey) ?? '';
    final base = await _storage.read(key: _kBaseUrl);
    final model = await _storage.read(key: _kModel);
    final sttRaw = await _storage.read(key: _kPreferOnDeviceStt);
    // Default true when unset (privacy-first).
    final preferStt = sttRaw == null || sttRaw.toLowerCase() != 'false';
    return AgentSettings(
      apiKey: key,
      baseUrl: (base == null || base.trim().isEmpty) ? defaultBaseUrl : base,
      model: (model == null || model.trim().isEmpty) ? defaultModel : model,
      preferOnDeviceStt: preferStt,
    );
  }

  Future<void> save() async {
    await _storage.write(key: _kApiKey, value: apiKey.trim());
    await _storage.write(key: _kBaseUrl, value: normalizedBaseUrl);
    await _storage.write(key: _kModel, value: effectiveModel);
    await _storage.write(
      key: _kPreferOnDeviceStt,
      value: preferOnDeviceStt ? 'true' : 'false',
    );
  }

  Future<void> clearApiKey() async {
    await _storage.delete(key: _kApiKey);
  }
}
