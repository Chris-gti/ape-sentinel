import 'package:flutter_test/flutter_test.dart';
import 'package:ape_sentinel/main.dart';

void main() {
  testWidgets('ApeSentinel smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ApeSentinelApp());
    expect(find.text('APESENTINEL'), findsOneWidget);
  });
}
