import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:tryhub_app/auth/auth_controller.dart';
import 'package:tryhub_app/core/app_theme.dart';
import 'package:tryhub_app/screens/auth/login_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('iOS Keychain can save, read and delete an isolated test value', (
    tester,
  ) async {
    const storage = FlutterSecureStorage();
    final key = 'tryhub_ios_smoke_${DateTime.now().microsecondsSinceEpoch}';
    try {
      await storage.write(key: key, value: 'keychain-roundtrip');
      expect(await storage.read(key: key), 'keychain-roundtrip');
      await storage.delete(key: key);
      expect(await storage.read(key: key), isNull);
    } finally {
      await storage.delete(key: key);
    }
  });

  testWidgets(
    'iOS login validates without authenticating or changing accounts',
    (tester) async {
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
    },
  );
}
