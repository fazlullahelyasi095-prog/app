// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:disgin_tryhub/screens/profile_screen.dart';

void main() {
  testWidgets('Profile screen renders user details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    expect(find.text('TryHub User'), findsOneWidget);
    expect(find.text('@tryhub_user'), findsOneWidget);
    expect(find.text('Followers'), findsOneWidget);
  });
}
