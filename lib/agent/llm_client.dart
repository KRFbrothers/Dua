import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'agent_settings.dart';

class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  final String role; // system | user | assistant
  final String content;

  Map<String, String> toJson() => {'role': role, 'content': content};
}

sealed class LlmResult {}

class LlmSuccess extends LlmResult {
  LlmSuccess(this.content);
  final String content;
}

class LlmFailure extends LlmResult {
  LlmFailure(this.message, {this.needsSettings = false, this.offline = false});
  final String message;
  final bool needsSettings;
  final bool offline;
}

/// OpenAI-compatible chat completions client (OpenAI / Groq / OpenRouter).
/// Online data path only — never call from Offline screens/services.
class LlmClient {
  LlmClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<LlmResult> chat({
    required AgentSettings settings,
    required List<ChatMessage> messages,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    if (!settings.hasApiKey) {
      return LlmFailure(
        'API key missing. Open Settings (gear) to paste your key.',
        needsSettings: true,
      );
    }

    final uri = Uri.parse('${settings.normalizedBaseUrl}/chat/completions');

    try {
      final response = await _http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${settings.apiKey.trim()}',
            },
            body: jsonEncode({
              'model': settings.effectiveModel,
              'messages': messages.map((m) => m.toJson()).toList(),
              'temperature': 0.7,
            }),
          )
          .timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = body['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) {
          return LlmFailure('Empty response from the model.');
        }
        final message = choices.first['message'] as Map<String, dynamic>?;
        final content = (message?['content'] as String?)?.trim() ?? '';
        if (content.isEmpty) {
          return LlmFailure('Model returned no text.');
        }
        return LlmSuccess(content);
      }

      final errDetail = _extractError(response.body);
      if (response.statusCode == 401 || response.statusCode == 403) {
        return LlmFailure(
          'Auth failed (${response.statusCode}). Check API key in Settings. $errDetail'
              .trim(),
          needsSettings: true,
        );
      }
      return LlmFailure(
        'API error ${response.statusCode}: $errDetail'.trim(),
      );
    } on TimeoutException {
      return LlmFailure('Request timed out. Try again.');
    } on http.ClientException catch (e) {
      return LlmFailure(
        'Network error: ${e.message}. Check connectivity.',
        offline: true,
      );
    } catch (e) {
      final s = e.toString();
      if (s.contains('SocketException') ||
          s.contains('Failed host lookup') ||
          s.contains('Network is unreachable')) {
        return LlmFailure(
          'No network. Online agent needs internet.',
          offline: true,
        );
      }
      return LlmFailure('Something went wrong: $e');
    }
  }

  String _extractError(String body) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      final err = map['error'];
      if (err is Map && err['message'] != null) {
        return err['message'].toString();
      }
      if (err is String) return err;
      if (map['message'] != null) return map['message'].toString();
    } catch (_) {
      /* raw body fallback */
    }
    final trimmed = body.trim();
    if (trimmed.isEmpty) return 'Unknown error';
    return trimmed.length > 200 ? '${trimmed.substring(0, 200)}…' : trimmed;
  }

  void close() => _http.close();
}
