import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AuthStore {
  Future<String?> token();
  Future<void> save(String token, String userId);
  Future<void> clear();
}

class SecureAuthStore implements AuthStore {
  const SecureAuthStore();

  @override
  Future<String?> token() => SecureStore.token();

  @override
  Future<void> save(String token, String userId) =>
      SecureStore.save(token, userId);

  @override
  Future<void> clear() => SecureStore.clear();
}

class SecureStore {
  static const _storage = FlutterSecureStorage();
  static Future<String?> token() => _storage.read(key: 'token');
  static Future<String?> userId() => _storage.read(key: 'userId');

  static Future<void> save(String token, String userId) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'userId', value: userId);
  }

  static Future<void> clear() async {
    // Pending gifts are namespaced per user and must survive reauthentication.
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'userId');
  }
}
