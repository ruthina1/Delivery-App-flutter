// This is a basic Flutter widget test for Burger Knight app.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BurgerKnightApp());

    // Allow animations to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify the app launches (splash screen shows burger emoji)
    expect(find.text('🍔'), findsWidgets);
  });
}
