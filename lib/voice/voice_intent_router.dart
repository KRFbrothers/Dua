/// Keyword / regex intent router for Voice Mode (Hindi + English).
/// Offline phrases navigate local screens; agent phrases go Online / LLM.
library;

enum VoiceRouteKind {
  galleryImages,
  galleryVideos,
  downloads,
  documents,
  storage,
  audio,
  apps,
  storageAnalysis,
  offlineHome,
  onlineAgent,
  unknown,
}

class VoiceRoute {
  const VoiceRoute({
    required this.kind,
    required this.confirmation,
    this.agentUserText,
  });

  final VoiceRouteKind kind;

  /// Short spoken / on-screen confirmation (Hinglish OK).
  final String confirmation;

  /// When [kind] is [VoiceRouteKind.onlineAgent], text to send to the LLM.
  final String? agentUserText;

  bool get isOfflineNav =>
      kind != VoiceRouteKind.onlineAgent && kind != VoiceRouteKind.unknown;
}

abstract final class VoiceIntentRouter {
  static final _gallery = RegExp(
    r'\b(gallery|photos?|images?|tasveer|photo|pics?|pictures?|'
    r'gallery\s*kholo|gallery\s*khole|images?\s*kholo|photos?\s*kholo)\b',
    caseSensitive: false,
  );

  static final _videos = RegExp(
    r'\b(videos?|video\s*gallery|clips?|movies?|'
    r'video\s*kholo|videos?\s*kholo)\b',
    caseSensitive: false,
  );

  static final _downloads = RegExp(
    r'\b(downloads?|download\s*folder|downloaded|'
    r'download\s*kholo|downloads?\s*kholo)\b',
    caseSensitive: false,
  );

  static final _documents = RegExp(
    r'\b(documents?|docs?|pdf|files?|file\s*browser|'
    r'document\s*kholo|docs?\s*kholo|files?\s*kholo)\b',
    caseSensitive: false,
  );

  static final _storage = RegExp(
    r'\b(main\s*storage|storage\s*folder|internal\s*storage|'
    r'storage\s*kholo|folder\s*kholo)\b',
    caseSensitive: false,
  );

  static final _storageAnalysis = RegExp(
    r'\b(storage\s*analysis|disk\s*space|storage\s*stats?|'
    r'kitna\s*space|free\s*space)\b',
    caseSensitive: false,
  );

  static final _audio = RegExp(
    r'\b(audio|music|songs?|mp3|gaane?|'
    r'music\s*kholo|audio\s*kholo|songs?\s*kholo)\b',
    caseSensitive: false,
  );

  static final _apps = RegExp(
    r'\b(apps?|applications?|installed\s*apps?|'
    r'apps?\s*kholo|app\s*list)\b',
    caseSensitive: false,
  );

  static final _offline = RegExp(
    r'\b(offline|local\s*mode|offline\s*(mode|screen|kholo)?)\b',
    caseSensitive: false,
  );

  static final _onlineCue = RegExp(
    r'\b(online|agent|ask\s*(dua|agent)|schedule|meeting|translate|'
    r'summarize|summary|write|draft|email|explain|what\s+is|who\s+is|'
    r'how\s+(do|to|can)|kyun|kya\s+hai|batao|likho|anuvad|tarjuma|'
    r'schedule\s+karo|meeting\s+banao)\b',
    caseSensitive: false,
  );

  /// Resolve spoken text into a navigation / agent route.
  static VoiceRoute resolve(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return const VoiceRoute(
        kind: VoiceRouteKind.unknown,
        confirmation: 'Kuch suna nahi. Phir se bolo?',
      );
    }

    // Prefer specific offline intents before generic "files" / online cues.
    if (_videos.hasMatch(text)) {
      return const VoiceRoute(
        kind: VoiceRouteKind.galleryVideos,
        confirmation: 'Videos khol rahi hoon…',
      );
    }
    if (_gallery.hasMatch(text)) {
      return const VoiceRoute(
        kind: VoiceRouteKind.galleryImages,
        confirmation: 'Gallery khol rahi hoon…',
      );
    }
    if (_downloads.hasMatch(text)) {
      return const VoiceRoute(
        kind: VoiceRouteKind.downloads,
        confirmation: 'Downloads khol rahi hoon…',
      );
    }
    if (_documents.hasMatch(text)) {
      return const VoiceRoute(
        kind: VoiceRouteKind.documents,
        confirmation: 'Documents khol rahi hoon…',
      );
    }
    if (_storageAnalysis.hasMatch(text)) {
      return const VoiceRoute(
        kind: VoiceRouteKind.storageAnalysis,
        confirmation: 'Storage analysis khol rahi hoon…',
      );
    }
    if (_storage.hasMatch(text)) {
      return const VoiceRoute(
        kind: VoiceRouteKind.storage,
        confirmation: 'Storage khol rahi hoon…',
      );
    }
    if (_audio.hasMatch(text)) {
      return const VoiceRoute(
        kind: VoiceRouteKind.audio,
        confirmation: 'Audio khol rahi hoon…',
      );
    }
    if (_apps.hasMatch(text)) {
      return const VoiceRoute(
        kind: VoiceRouteKind.apps,
        confirmation: 'Apps list khol rahi hoon…',
      );
    }
    if (_offline.hasMatch(text)) {
      return const VoiceRoute(
        kind: VoiceRouteKind.offlineHome,
        confirmation: 'Offline mode khol rahi hoon…',
      );
    }
    if (_onlineCue.hasMatch(text)) {
      return VoiceRoute(
        kind: VoiceRouteKind.onlineAgent,
        confirmation: 'Online agent se poochhti hoon…',
        agentUserText: text,
      );
    }

    // Default: treat as a general question for the Online agent.
    return VoiceRoute(
      kind: VoiceRouteKind.onlineAgent,
      confirmation: 'Samajh gayi — Online pe jawab dhoondhti hoon…',
      agentUserText: text,
    );
  }
}
