import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amharic_catholic_bible/core/services/storage_service.dart';
import 'package:amharic_catholic_bible/main.dart';

void main() {
  testWidgets('Bible app smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences to avoid platform channel timeout.
    SharedPreferences.setMockInitialValues({});

    // Initialise storage before the app starts (mirrors main()).
    await StorageService.init();

    // Build the real app root and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify the splash screen renders the brand name and Amharic title.
    expect(find.text('ANLEYLAB'), findsOneWidget);
    expect(find.text('መጽሐፍ ቅዱስ'), findsOneWidget);

    // Allow the splash screen timer to complete and navigate to HomeScreen.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
