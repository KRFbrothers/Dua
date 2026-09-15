import 'package:flutter_test/flutter_test.dart';

import 'package:dua/main.dart';

void main() {
  testWidgets('Dua home shows branding and mode CTAs', (tester) async {
    await tester.pumpWidget(const DuaApp());
    await tester.pump(); // allow first frame (orb animation starts)

    expect(find.text('Dua'), findsWidgets);
    expect(find.text('ALWAYS WITH YOU'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
  });
}
