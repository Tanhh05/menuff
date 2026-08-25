import 'package:flutter_test/flutter_test.dart';
import 'package:menuff/main.dart';

void main() {
  testWidgets('iOS Menu UI renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify header title "FREE FIRE" exists
    expect(find.text('FREE FIRE'), findsOneWidget);

    // Verify menu options exist
    expect(find.text('AIMBOT'), findsOneWidget);
    expect(find.text('ĐẦU'), findsOneWidget);
    expect(find.text('CỔ'), findsOneWidget);
    expect(find.textContaining('AIM RADIUS'), findsOneWidget);
    expect(find.text('ESP LINE'), findsOneWidget);
    expect(find.text('ESP Box'), findsOneWidget);
    expect(find.text('ESP HP'), findsOneWidget);
    expect(find.text('ESP TÊN'), findsOneWidget);
  });
}
