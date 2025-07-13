// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:nitymulya/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NitiMulyaApp());

    // Verify that our app loads with the main title.
    expect(find.text('নীতি মূল্য'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Verify that the market prices title is shown.
    expect(find.text('প্রতিদিনের খুচরা বাজার দর'), findsOneWidget);
  });
}
