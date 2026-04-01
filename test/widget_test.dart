import 'package:flutter_test/flutter_test.dart';
import 'package:aran/main.dart';
import 'package:aran/screens/sos_trigger_screen.dart';

void main() {
  testWidgets('SOS Trigger Screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AranApp());
    expect(find.byType(SosTriggerScreen), findsOneWidget);
    expect(find.text('SOS'), findsOneWidget);
  });
}
