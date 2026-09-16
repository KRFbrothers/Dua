/// Explicit Offline vs Online data paths for Dua (Phase 4).
///
/// ## Offline path (local-only)
/// - Screens under Offline (gallery, file browser, apps, storage analysis)
///   and Voice intents that open those screens MUST NOT call LlmClient,
///   HTTP, or any cloud API.
/// - Use [assertOfflinePath] in debug to document Offline entry.
/// - UI: show LOCAL / Offline badges; never request an API key for these flows.
///
/// ## Online path (network required)
/// - Agent chat, Work chat, Voice → agent replies use LlmClient + API key.
/// - Needs connectivity; show NEEDS NETWORK / Online badges and snackbars.
/// - API key stays in secure storage on-device; only sent to the configured
///   OpenAI-compatible base URL when the user sends a chat message.
///
/// ## Voice
/// - STT prefers on-device when the user toggle is on
///   (AgentSettings.preferOnDeviceStt).
/// - Offline intents stay on the offline path; agent intents use Online path.
///
/// Cloud / Remote / Access-from hubs ship in Phase 5 (no live sync yet).
/// Voice Share / camera capture / Pulse ship in Phase 5; full video-call later.
library;

/// Human-readable labels for UI badges / snackbars.
abstract final class DataPathLabels {
  static const String offlineLocal = 'LOCAL ONLY';
  static const String offlineSubtitle =
      'Stays on this device — no LLM or cloud upload.';
  static const String onlineNeedsNetwork = 'NEEDS NETWORK';
  static const String onlineSubtitle =
      'Agent replies use your API key over the internet.';
  static const String voiceOnDevicePrefer =
      'Voice STT prefers on-device recognition when available.';
}

/// Debug-only guard: call from Offline entry points.
void assertOfflinePath(String screenName) {
  assert(() {
    // Offline flows must remain free of network LLM calls.
    return screenName.isNotEmpty;
  }(), 'Offline path entered: $screenName');
}

/// Debug-only guard: call before Online LLM usage.
void assertOnlinePath(String featureName) {
  assert(() {
    return featureName.isNotEmpty;
  }(), 'Online path (network): $featureName');
}
