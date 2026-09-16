import '../agent/agent_settings.dart';
import '../agent/llm_client.dart';

/// Compatibility facade for callers that need a one-shot online request.
/// The interactive Online and Voice screens use [LlmClient] directly.
class AiService {
  static Future<LlmResult> getOnlineResponse(String prompt) async {
    final settings = await AgentSettings.load();
    if (!settings.hasApiKey) {
      return LlmFailure(
        'API key missing. Open Settings and save your key.',
        needsSettings: true,
      );
    }

    final client = LlmClient();
    try {
      return await client.chat(
        settings: settings,
        messages: [ChatMessage(role: 'user', content: prompt)],
      );
    } finally {
      client.close();
    }
  }

  static String getOfflineResponse(String prompt) {
    return "Offline mode: Local processing for '$prompt'";
  }
}
