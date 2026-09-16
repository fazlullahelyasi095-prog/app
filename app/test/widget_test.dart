import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tryhub_app/screens/splash_screen.dart';

void main() {
  testWidgets('splash identifies TryHub', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('TryHub'), findsOneWidget);
  });
}
