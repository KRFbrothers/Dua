import 'package:dua/privacy/data_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('data path labels are non-empty', () {
    expect(DataPathLabels.offlineLocal, isNotEmpty);
    expect(DataPathLabels.onlineNeedsNetwork, isNotEmpty);
    expect(DataPathLabels.voiceOnDevicePrefer, contains('on-device'));
  });

  test('assert helpers accept names in debug', () {
    assertOfflinePath('test');
    assertOnlinePath('test');
  });
}
