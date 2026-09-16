import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely stored LLM and privacy preferences.
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
  final bool preferOnDeviceStt;

  bool get hasApiKey => apiKey.trim().isNotEmpty;

  String get normalizedBaseUrl {
    var value = baseUrl.trim();
    if (value.isEmpty) value = defaultBaseUrl;
    while (value.length > 1 && value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  String get effectiveModel {
    final value = model.trim();
    return value.isEmpty ? defaultModel : value;
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
    final base = await _storage.read(key: _kBaseUrl) ?? defaultBaseUrl;
    final model = await _storage.read(key: _kModel) ?? defaultModel;
    final sttRaw = await _storage.read(key: _kPreferOnDeviceStt);

    return AgentSettings(
      apiKey: key,
      baseUrl: base.trim().isEmpty ? defaultBaseUrl : base,
      model: model.trim().isEmpty ? defaultModel : model,
      preferOnDeviceStt: sttRaw == null || sttRaw.toLowerCase() != 'false',
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

  Future<void> clearApiKey() => _storage.delete(key: _kApiKey);
}
