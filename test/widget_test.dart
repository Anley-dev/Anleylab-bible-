import 'package:flutter_test/flutter_test.dart';

import 'package:amharic_catholic_bible/app/app.dart';

void main() {
  testWidgets('Bible app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AnleyLabBibleApp());

    // Verify that our app starts and displays the home screen welcome text.
    expect(find.text('እንኳን ወደ ANLEYLAB መጽሐፍ ቅዱስ በደህና መጡ።'), findsOneWidget);
  });
}
