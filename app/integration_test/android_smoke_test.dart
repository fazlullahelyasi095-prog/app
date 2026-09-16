import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:tryhub_app/auth/auth_controller.dart';
import 'package:tryhub_app/core/app_theme.dart';
import 'package:tryhub_app/screens/auth/login_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android login form validates without changing account data', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthController(),
        child: MaterialApp(theme: AppTheme.dark, home: const LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Welcome to TryHub'), findsOneWidget);
    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
