import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../core/storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  AuthController({AuthService? service, AuthStore? store})
    : _service = service ?? AuthService(),
      _store = store ?? const SecureAuthStore() {
    ApiClient.instance.onUnauthorized = expireSession;
  }
  final AuthService _service;
  final AuthStore _store;
  AuthStatus status = AuthStatus.checking;
  User? user;

  Future<void> restoreSession() async {
    try {
      final token = await _store.token();
      if (token == null || token.isEmpty) {
        status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }
      user = await _service.profile();
      status = AuthStatus.authenticated;
    } catch (_) {
      try {
        await _store.clear();
      } catch (_) {
        // Storage can be unavailable too; still leave the splash screen safely.
      }
      user = null;
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final result = await _service.login(email, password);
    await _store.save(result.token, result.user.id.toString());
    user = result.user;
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> expireSession() async {
    if (status == AuthStatus.unauthenticated && user == null) return;
    await _store.clear();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
