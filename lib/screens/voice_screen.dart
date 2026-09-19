import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import '../theme/dua_colors.dart';
import '../voice/voice_intent_router.dart';
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
  late final stt.SpeechToText _speech;
  late final FlutterTts _tts;
  late final ImagePicker _imagePicker;

  String _transcript = '';
  String _status = 'Tap the mic and speak';
  bool _speechReady = false;
  bool _pulse = false;
  XFile? _capturedVideo;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _imagePicker = ImagePicker();
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_speech.isListening) {
      await _speech.stop();
      if (mounted) setState(() => _status = 'Paused');
      return;
    }

    if (!_speechReady) {
      // Explicitly request microphone permission before initializing
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        if (mounted) setState(() => _status = 'Microphone permission denied');
        return;
      }

      _speechReady = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'notListening') setState(() => _status = 'Ready');
        },
        onError: (error) {
          if (mounted) {
            setState(() => _status = 'Speech recognition unavailable (Check Emulator settings)');
          }
        },
      );
    }

    if (!_speechReady) {
      setState(() => _status = 'Microphone or Speech Service is unavailable');
      return;
    }

    setState(() {
      _transcript = '';
      _status = 'Listening...';
    });
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => _transcript = result.recognizedWords);
        if (result.finalResult) _handleTranscript(result.recognizedWords);
      },
    );
  }

  Future<void> _handleTranscript(String text) async {
    final route = VoiceIntentRouter.resolve(text);
    setState(() => _status = route.confirmation);
    await _tts.speak(route.confirmation);

    if (!mounted || route.kind == VoiceRouteKind.unknown) return;
    if (route.kind == VoiceRouteKind.onlineAgent) {
      final connectivity = await Connectivity().checkConnectivity();
      if (!mounted) return;
      if (connectivity.contains(ConnectivityResult.none)) {
        _showMessage('Online agent needs an internet connection.');
        return;
      }
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const OnlineScreen()));
      return;
    }

    final Widget? page = switch (route.kind) {
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
      VoiceRouteKind.onlineAgent || VoiceRouteKind.unknown => null,
    };
    if (page != null && mounted) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    }
  }

  Future<void> _captureVideoPreview() async {
    final video = await _imagePicker.pickVideo(source: ImageSource.camera);
    if (video != null && mounted) {
      setState(() => _capturedVideo = video);
    }
  }

  Future<void> _shareTranscript() async {
    if (_transcript.trim().isEmpty) {
      _showMessage('There is no transcript to share yet.');
      return;
    }
    await SharePlus.instance.share(ShareParams(text: _transcript));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listening = _speech.isListening;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Mode'),
        actions: [
          IconButton(
            tooltip: 'Share transcript',
            onPressed: _shareTranscript,
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: 'Camera preview',
            onPressed: _captureVideoPreview,
            icon: const Icon(Icons.videocam_outlined),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(gradient: DuaColors.neonGradient),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: DuaColors.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              const Text(
                'Speak naturally',
                style: TextStyle(
                  color: DuaColors.textPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _status,
                style: const TextStyle(color: DuaColors.textSecondary),
              ),
              const SizedBox(height: 36),
              Expanded(
                child: Center(
                  child: CustomPaint(
                    size: const Size(double.infinity, 150),
                    painter: _WaveformPainter(
                      active: listening,
                      intensified: _pulse,
                    ),
                  ),
                ),
              ),
              if (_capturedVideo != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Video preview captured: ${_capturedVideo!.name}',
                    style: const TextStyle(color: DuaColors.cyanSoft),
                  ),
                ),
              if (_transcript.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: DuaColors.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _transcript,
                    style: const TextStyle(
                      color: DuaColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    tooltip: 'Pulse',
                    onPressed: () => setState(() => _pulse = !_pulse),
                    icon: Icon(
                      Icons.graphic_eq,
                      color: _pulse ? DuaColors.cyan : DuaColors.textSecondary,
                      size: 30,
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: 'voice-mic',
                    onPressed: _toggleListening,
                    backgroundColor: listening
                        ? DuaColors.offlineRed
                        : DuaColors.cyan,
                    child: Icon(listening ? Icons.mic : Icons.mic_none),
                  ),
                  IconButton(
                    tooltip: 'End',
                    onPressed: () async {
                      await _speech.stop();
                      if (mounted) setState(() => _status = 'Session ended');
                    },
                    icon: const Icon(
                      Icons.stop_circle_outlined,
                      color: DuaColors.offlineRed,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({required this.active, required this.intensified});

  final bool active;
  final bool intensified;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DuaColors.cyan
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final center = size.height / 2;
    final amplitude = active ? (intensified ? 52.0 : 30.0) : 10.0;
    for (var index = 0; index < 25; index++) {
      final x = (index + 1) * size.width / 26;
      final height = amplitude * (0.35 + (index % 5) / 5);
      canvas.drawLine(
        Offset(x, center - height),
        Offset(x, center + height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      active != oldDelegate.active || intensified != oldDelegate.intensified;
}
