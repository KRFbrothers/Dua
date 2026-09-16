import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiService {
  // .env se secure API key fetch karne ka method
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // Online AI request handler
  static Future<String> getOnlineResponse(String prompt) async {
    try {
      if (apiKey.isEmpty || apiKey == 'your_secret_api_key_here') {
        return "Error: API Key configure nahi ki gayi hai .env file mein.";
      }
      
      // Yahan aap apni API endpoint (jaise Gemini/OpenAI) integrate kar sakte hain
      // Example placeholder logic:
      return "Online mode active. Response for: $prompt";
    } catch (e) {
      return "Network Error: $e";
    }
  }

  // Offline local fallback handler
  static String getOfflineResponse(String prompt) {
    return "Offline mode: Local processing for '$prompt'";
  }
}
