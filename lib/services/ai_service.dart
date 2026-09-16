import '../agent/agent_settings.dart';

class AiService {
  static Future<String> getOnlineResponse(String prompt) async {
    final settings = await AgentSettings.load();

    if (!settings.hasApiKey) {
      return 'Error: API key not configured. Open Settings and save your key.';
    }

    return 'Online mode active. Response for: $prompt';
  }

  static String getOfflineResponse(String prompt) {
    return "Offline mode: Local processing for '$prompt'";
  }
}
