import 'package:flutter_test/flutter_test.dart';
import 'package:tryhub_app/auth/auth_controller.dart';
import 'package:tryhub_app/core/storage.dart';
import 'package:tryhub_app/models/user.dart';
import 'package:tryhub_app/services/auth_service.dart';

void main() {
  const user = User(id: 7, username: 'tester', email: 'test@example.com');

  test(
    'unavailable secure storage leaves splash without an unhandled error',
    () async {
      final controller = AuthController(
        service: _FakeAuthService(user: user),
        store: _UnavailableStore(),
      );
      await controller.restoreSession();
      expect(controller.status, AuthStatus.unauthenticated);
      expect(controller.user, isNull);
    },
  );

  test('restore without a token is unauthenticated', () async {
    final store = _MemoryAuthStore();
    final controller = AuthController(
      service: _FakeAuthService(user: user),
      store: store,
    );

    await controller.restoreSession();

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.user, isNull);
  });

  test('valid stored token restores the authenticated user', () async {
    final store = _MemoryAuthStore(value: 'stored-token');
    final controller = AuthController(
      service: _FakeAuthService(user: user),
      store: store,
    );

    await controller.restoreSession();

    expect(controller.status, AuthStatus.authenticated);
    expect(controller.user?.id, user.id);
    expect(store.wasCleared, isFalse);
  });

  test('invalid stored token is cleared', () async {
    final store = _MemoryAuthStore(value: 'expired-token');
    final controller = AuthController(
      service: _FakeAuthService(user: user, profileError: Exception('expired')),
      store: store,
    );

    await controller.restoreSession();

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.user, isNull);
    expect(store.wasCleared, isTrue);
  });

  test('login persists the server token and user ID', () async {
    final store = _MemoryAuthStore();
    final controller = AuthController(
      service: _FakeAuthService(user: user),
      store: store,
    );

    await controller.login('test@example.com', 'password');

    expect(controller.status, AuthStatus.authenticated);
    expect(store.value, 'server-token');
    expect(store.userId, '7');
  });

  test('expired session clears authentication', () async {
    final store = _MemoryAuthStore(value: 'stored-token');
    final controller = AuthController(
      service: _FakeAuthService(user: user),
      store: store,
    );
    await controller.restoreSession();

    await controller.expireSession();

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.user, isNull);
    expect(store.wasCleared, isTrue);
  });

  test('logout clears authentication', () async {
    final store = _MemoryAuthStore(value: 'stored-token');
    final controller = AuthController(
      service: _FakeAuthService(user: user),
      store: store,
    );
    await controller.restoreSession();

    await controller.logout();

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.user, isNull);
    expect(store.wasCleared, isTrue);
  });
}

class _UnavailableStore implements AuthStore {
  @override
  Future<String?> token() async => throw StateError('Storage unavailable');
  @override
  Future<void> clear() async => throw StateError('Storage unavailable');
  @override
  Future<void> save(String token, String userId) async =>
      throw StateError('Storage unavailable');
}

class _MemoryAuthStore implements AuthStore {
  _MemoryAuthStore({this.value});
  String? value;
  String? userId;
  bool wasCleared = false;

  @override
  Future<String?> token() async => value;
  @override
  Future<void> save(String token, String id) async {
    value = token;
    userId = id;
  }

  @override
  Future<void> clear() async {
    value = null;
    userId = null;
    wasCleared = true;
  }
}

class _FakeAuthService extends AuthService {
  _FakeAuthService({required this.user, this.profileError});
  final User user;
  final Object? profileError;

  @override
  Future<AuthResult> login(String email, String password) async =>
      AuthResult('server-token', user);

  @override
  Future<User> profile() async {
    if (profileError != null) throw profileError!;
    return user;
  }
}
