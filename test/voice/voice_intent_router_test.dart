import 'package:dua/voice/voice_intent_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceIntentRouter', () {
    test('gallery phrases → images', () {
      for (final phrase in [
        'Dua, gallery kholo',
        'open gallery',
        'show photos',
        'images kholo',
      ]) {
        final r = VoiceIntentRouter.resolve(phrase);
        expect(r.kind, VoiceRouteKind.galleryImages, reason: phrase);
        expect(r.confirmation.toLowerCase(), contains('gallery'));
      }
    });

    test('downloads / documents / storage', () {
      expect(
        VoiceIntentRouter.resolve('open downloads').kind,
        VoiceRouteKind.downloads,
      );
      expect(
        VoiceIntentRouter.resolve('documents kholo').kind,
        VoiceRouteKind.documents,
      );
      expect(
        VoiceIntentRouter.resolve('main storage').kind,
        VoiceRouteKind.storage,
      );
      expect(
        VoiceIntentRouter.resolve('storage analysis').kind,
        VoiceRouteKind.storageAnalysis,
      );
    });

    test('online / agent phrases', () {
      final schedule = VoiceIntentRouter.resolve('schedule a meeting tomorrow');
      expect(schedule.kind, VoiceRouteKind.onlineAgent);
      expect(schedule.agentUserText, isNotNull);

      final translate = VoiceIntentRouter.resolve('translate this to Hindi');
      expect(translate.kind, VoiceRouteKind.onlineAgent);

      final general = VoiceIntentRouter.resolve('What is photosynthesis?');
      expect(general.kind, VoiceRouteKind.onlineAgent);
    });

    test('empty → unknown', () {
      expect(VoiceIntentRouter.resolve('   ').kind, VoiceRouteKind.unknown);
    });
  });
}
