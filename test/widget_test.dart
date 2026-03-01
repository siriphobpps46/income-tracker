import 'package:flutter_test/flutter_test.dart';
import 'package:income_tracker/main.dart';

void main() {
  testWidgets('Smoke test for Income Tracker Welcome Screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title is present.
    expect(find.text('INCOME TRACKER'), findsOneWidget);

    // Verify that the start button exists.
    expect(find.text('เริ่มใช้งาน'), findsOneWidget);

    // Verify that counter-related values do not exist.
    expect(find.text('0'), findsNothing);
  });
}
