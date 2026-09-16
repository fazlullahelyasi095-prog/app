import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/auth_controller.dart';
import 'core/app_router.dart';
import 'core/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/feed/feed_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/app_navigation.dart';

void main() => runApp(const TryHubApp());

class TryHubApp extends StatelessWidget {
  const TryHubApp({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AuthController()..restoreSession(),
    child: Consumer<AuthController>(
      builder: (_, auth, _) => MaterialApp(
        key: ValueKey(auth.user?.id),
        debugShowCheckedModeBanner: false,
        title: 'TryHub',
        theme: AppTheme.dark,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        navigatorObservers: [AppRoutes.observer],
        home: const AuthGate(),
      ),
    ),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) =>
      switch (context.watch<AuthController>().status) {
        AuthStatus.checking => const SplashScreen(),
        AuthStatus.authenticated => const AppNavigation(
          selectedIndex: 0,
          child: FeedScreen(),
        ),
        AuthStatus.unauthenticated => const LoginScreen(),
      };
}
