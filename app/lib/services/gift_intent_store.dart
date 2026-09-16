import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores only a pending delivery request, never a balance or financial result.
/// The server's idempotency key remains unchanged until acknowledgement.
class GiftIntentStore {
  const GiftIntentStore();
  static const _storage = FlutterSecureStorage();
  String _key(int userId, int liveId) => 'pending_gift_${userId}_$liveId';
  Future<Map<String, dynamic>?> load(int userId, int liveId) async {
    final value = await _storage.read(key: _key(userId, liveId));
    return value == null ? null : Map<String, dynamic>.from(jsonDecode(value));
  }

  Future<void> save(int userId, int liveId, Map<String, dynamic> intent) =>
      _storage.write(key: _key(userId, liveId), value: jsonEncode(intent));
  Future<void> clear(int userId, int liveId) =>
      _storage.delete(key: _key(userId, liveId));
}
