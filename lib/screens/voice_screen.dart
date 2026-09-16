import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../agent/agent_settings.dart';
import '../agent/llm_client.dart';
import '../agent/prompts.dart';
import '../privacy/data_paths.dart';
import '../theme/dua_colors.dart';
import '../voice/voice_intent_router.dart';
import '../widgets/dua_logo.dart';
import '../widgets/waveform.dart';
import 'apps_list_screen.dart';
import 'file_browser_screen.dart';
import 'media_gallery_screen.dart';
import 'offline_screen.dart';
import 'online_screen.dart';
import 'storage_analysis_screen.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final _speech = SpeechToText();
  final _tts = FlutterTts();
  final _llm = LlmClient();
  bool _ready = false, _listening = false, _busy = false, _onDevice = true;
  String? _locale;
  String _status = 'Initializing…', _user = '', _partial = '';
  String _reply = 'Mic dabao aur bolo — gallery, downloads, ya sawaal.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    unawaited(_speech.stop());
    unawaited(_tts.stop());
    _llm.close();
    super.dispose();
  }

  Future<void> _init() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(.48);
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      _setReply('Microphone permission chahiye. Settings se allow karo.');
      if (mounted) {
        _snack('Microphone permission needed.', 'Settings', openAppSettings);
      }
      return;
    }
    final available = await _speech.initialize(
      onStatus: (s) {
        if (!mounted) return;
        setState(() {
          _status = s;
          if (s == 'done' || s == 'notListening') _listening = false;
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _listening = false;
          _status = 'STT: ${e.errorMsg}';
          if (e.permanent) _onDevice = false;
        });
      },
    );
    if (!available) {
      _setReply(
        'Speech recognition unavailable. Google voice services check karo.',
      );
      return;
    }
    final locales = await _speech.locales();
    for (final id in ['en_IN', 'hi_IN', 'en_US']) {
      if (locales.any((l) => l.localeId == id)) {
        _locale = id;
        break;
      }
    }
    // Privacy: honour Settings → prefer on-device STT (falls back if unavailable).
    final prefs = await AgentSettings.load();
    _onDevice = prefs.preferOnDeviceStt;
    if (!mounted) return;
    setState(() {
      _ready = true;
      _status = prefs.preferOnDeviceStt
          ? 'Ready · on-device STT prefer'
          : 'Ready · system STT';
    });
    await _speak(_reply);
    if (mounted) await _start();
  }

  void _setReply(String value) {
    if (mounted) setState(() => _reply = value);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _toggleMic() async {
    if (!_ready || _busy) return;
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
    } else {
      await _start();
    }
  }

  Future<void> _start() async {
    if (!_ready || _busy) return;
    setState(() {
      _listening = true;
      _partial = '';
      _status = 'Listening…';
    });
    Future<void> listen(bool local) => _speech.listen(
      onResult: _onResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        onDevice: local,
        cancelOnError: false,
        listenMode: ListenMode.confirmation,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 30),
        localeId: _locale,
      ),
    );
    try {
      await listen(_onDevice);
    } catch (_) {
      try {
        _onDevice = false;
        await listen(false);
      } catch (e) {
        if (mounted) {
          setState(() {
            _listening = false;
            _status = 'Listen failed';
            _reply = 'Listening start nahi hua: $e';
          });
        }
      }
    }
  }

  void _onResult(SpeechRecognitionResult r) {
    final words = r.recognizedWords.trim();
    if (!mounted || words.isEmpty) return;
    if (!r.finalResult) {
      setState(() => _partial = words);
      return;
    }
    setState(() {
      _user = words;
      _partial = '';
      _listening = false;
    });
    unawaited(_route(words));
  }

  Future<void> _route(String text) async {
    if (_busy) return;
    setState(() => _busy = true);
    await _speech.stop();
    final route = VoiceIntentRouter.resolve(text);
    _setReply(route.confirmation);
    await _speak(route.confirmation);
    final Widget? target = switch (route.kind) {
      VoiceRouteKind.galleryImages => const MediaGalleryScreen(
        title: 'Images',
        kind: MediaGalleryKind.images,
      ),
      VoiceRouteKind.galleryVideos => const MediaGalleryScreen(
        title: 'Videos',
        kind: MediaGalleryKind.videos,
      ),
      VoiceRouteKind.downloads => const FileBrowserScreen(
        title: 'Downloads',
        mode: FileBrowserMode.downloads,
      ),
      VoiceRouteKind.documents => const FileBrowserScreen(
        title: 'Documents',
        mode: FileBrowserMode.documents,
      ),
      VoiceRouteKind.storage => const FileBrowserScreen(
        title: 'Main storage',
        mode: FileBrowserMode.folder,
      ),
      VoiceRouteKind.audio => const FileBrowserScreen(
        title: 'Audio',
        mode: FileBrowserMode.audio,
      ),
      VoiceRouteKind.apps => const AppsListScreen(),
      VoiceRouteKind.storageAnalysis => const StorageAnalysisScreen(),
      VoiceRouteKind.offlineHome => const OfflineScreen(),
      _ => null,
    };
    if (target != null) {
      assertOfflinePath('Voice→Offline');
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => target),
        );
      }
    } else if (route.kind == VoiceRouteKind.onlineAgent) {
      await _askOnline(route.agentUserText ?? text);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _askOnline(String text) async {
    assertOnlinePath('Voice→Online');
    final settings = await AgentSettings.load();
    if (!settings.hasApiKey) {
      const message = 'API key chahiye. Online Settings mein key set karo.';
      _setReply(message);
      await _speak(message);
      if (mounted) {
        _snack('API key needed for Online replies.', 'Online', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OnlineScreen()),
          );
        });
      }
      return;
    }
    _setReply('Soch rahi hoon…');
    final result = await _llm.chat(
      settings: settings,
      messages: [
        ChatMessage(
          role: 'system',
          content: AgentPrompts.systemFor(agentMode: true),
        ),
        ChatMessage(role: 'user', content: text),
      ],
    );
    final answer = result is LlmSuccess
        ? result.content
        : (result as LlmFailure).message;
    _setReply(answer);
    final spoken = answer.length > 280
        ? '${answer.substring(0, 280)}…'
        : answer;
    await _speak(spoken);
  }

  void _snack(String text, String action, VoidCallback onPressed) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        action: SnackBarAction(label: action, onPressed: onPressed),
      ),
    );
  }

  void _stub(String label) => _snack('$label — coming soon', 'OK', () {});

  Future<void> _end() async {
    await _speech.stop();
    await _tts.stop();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final heard = _partial.isNotEmpty
        ? _partial
        : (_user.isEmpty ? '…' : _user);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -.3),
            radius: 1.2,
            colors: [Color(0xFF141428), DuaColors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: DuaColors.cyanSoft,
                    ),
                    onPressed: _end,
                  ),
                  const Spacer(),
                  const DuaLogo(showTagline: false, fontSize: 28),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              Text(
                _busy ? 'Working…' : (_listening ? 'Listening' : _status),
                style: const TextStyle(
                  color: DuaColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: DuaColors.cyan, width: 1.5),
                    color: DuaColors.surface.withValues(alpha: .6),
                    boxShadow: [
                      BoxShadow(
                        color: DuaColors.cyan.withValues(alpha: .15),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Voice Mode',
                        style: TextStyle(
                          color: DuaColors.cyanSoft,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _onDevice
                            ? 'STT: on-device prefer'
                            : 'STT: system / network may apply',
                        style: const TextStyle(
                          color: DuaColors.textMuted,
                          fontSize: 10,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: NeonWaveform(active: _listening || _busy),
                      ),
                      Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Speaker(name: 'Tum'),
                              Text(
                                '“$heard”',
                                style: const TextStyle(
                                  color: DuaColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const _Speaker(name: 'Dua', dua: true),
                              Text(
                                _reply,
                                style: const TextStyle(
                                  color: DuaColors.textSecondary,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Control(
                    Icons.screen_share_outlined,
                    'Share',
                    () => _stub('Share'),
                  ),
                  _Control(
                    Icons.videocam_outlined,
                    'Video',
                    () => _stub('Video'),
                  ),
                  _Mic(active: _listening, enabled: !_busy, onTap: _toggleMic),
                  _Control(Icons.graphic_eq, 'Pulse', () => _stub('Pulse')),
                  _Control(Icons.call_end, 'End', _end, end: true),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Speaker extends StatelessWidget {
  const _Speaker({required this.name, this.dua = false});
  final String name;
  final bool dua;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      name,
      style: TextStyle(
        color: dua ? DuaColors.cyanSoft : DuaColors.textMuted,
        fontSize: 11,
        letterSpacing: 1,
      ),
    ),
  );
}

class _Control extends StatelessWidget {
  const _Control(this.icon, this.label, this.onTap, {this.end = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool end;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: end ? DuaColors.offlineRed : DuaColors.surfaceElevated,
            border: Border.all(
              color: end ? DuaColors.offlineRed : DuaColors.borderNeon,
            ),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: const TextStyle(color: DuaColors.textMuted, fontSize: 11),
      ),
    ],
  );
}

class _Mic extends StatelessWidget {
  const _Mic({
    required this.active,
    required this.enabled,
    required this.onTap,
  });
  final bool active, enabled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: enabled ? 1 : .5,
    child: Column(
      children: [
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: active ? DuaColors.orbGradient : null,
              color: active ? null : DuaColors.surfaceElevated,
              border: Border.all(color: DuaColors.cyan, width: 2),
            ),
            child: Icon(
              active ? Icons.mic : Icons.mic_off,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          active ? 'Listening' : 'Muted',
          style: const TextStyle(color: DuaColors.textMuted, fontSize: 11),
        ),
      ],
    ),
  );
}
