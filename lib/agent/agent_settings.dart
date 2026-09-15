import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely stored LLM settings (API key never hardcoded).
class AgentSettings {
  AgentSettings({
    this.apiKey = '',
    this.baseUrl = defaultBaseUrl,
    this.model = defaultModel,
  });

  static const String defaultBaseUrl = 'https://api.openai.com/v1';
  static const String defaultModel = 'gpt-4o-mini';

  static const _kApiKey = 'dua_llm_api_key';
  static const _kBaseUrl = 'dua_llm_base_url';
  static const _kModel = 'dua_llm_model';

  final String apiKey;
  final String baseUrl;
  final String model;

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
  }) {
    return AgentSettings(
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
    );
  }

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<AgentSettings> load() async {
    final key = await _storage.read(key: _kApiKey) ?? '';
    final base = await _storage.read(key: _kBaseUrl);
    final model = await _storage.read(key: _kModel);
    return AgentSettings(
      apiKey: key,
      baseUrl: (base == null || base.trim().isEmpty) ? defaultBaseUrl : base,
      model: (model == null || model.trim().isEmpty) ? defaultModel : model,
    );
  }

  Future<void> save() async {
    await _storage.write(key: _kApiKey, value: apiKey.trim());
    await _storage.write(key: _kBaseUrl, value: normalizedBaseUrl);
    await _storage.write(key: _kModel, value: effectiveModel);
  }

  Future<void> clearApiKey() async {
    await _storage.delete(key: _kApiKey);
  }
}
