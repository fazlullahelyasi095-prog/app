import 'package:flutter/material.dart';

import '../screens/profile/profile_screen.dart';
import '../screens/upload/create_post_screen.dart';
import '../chat/chat_screen.dart';
import '../live/live_screen.dart';
import '../wallet/wallet_screen.dart';
import '../screens/notifications_screen.dart';
import '../widgets/app_navigation.dart';

abstract final class AppRoutes {
  static final observer = RouteObserver<ModalRoute<void>>();
  static const profile = '/profile';
  static const createPost = '/create-post';
  static const chat = '/chat';
  static const live = '/live';
  static const wallet = '/wallet';
  static const notifications = '/notifications';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case chat:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              const AppNavigation(selectedIndex: 3, child: ChatScreen()),
        );
      case live:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              const AppNavigation(selectedIndex: 1, child: LiveListScreen()),
        );
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case profile:
        final userId = settings.arguments;
        if (userId is int) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => AppNavigation(
              selectedIndex: 4,
              child: ProfileScreen(userId: userId),
            ),
          );
        }
        return _errorRoute('A valid profile ID is required.');
      case createPost:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              const AppNavigation(selectedIndex: 2, child: CreatePostScreen()),
        );
      default:
        return _errorRoute('Page not found.');
    }
  }

  static Route<void> _errorRoute(String message) => MaterialPageRoute(
    builder: (_) => Scaffold(body: Center(child: Text(message))),
  );
}
