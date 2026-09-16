import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tryhub_app/core/storage.dart';
import 'package:tryhub_app/services/gift_intent_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  const store = GiftIntentStore();
  const intent = {
    'liveId': 12,
    'receiverId': 9,
    'giftId': 3,
    'operationKey': 'unchanged-key',
    'idempotencyKey': 'unchanged-key',
  };
  test(
    'pending gifts survive logout with the original idempotency key',
    () async {
      await SecureStore.save('token', '7');
      await store.save(7, 12, intent);
      await SecureStore.clear();
      expect(await SecureStore.token(), isNull);
      expect(await SecureStore.userId(), isNull);
      expect(await store.load(7, 12), intent);
    },
  );
  test('pending gifts are isolated between users and live rooms', () async {
    await store.save(7, 12, intent);
    expect(await store.load(8, 12), isNull);
    expect(await store.load(7, 13), isNull);
    await store.clear(7, 12);
    expect(await store.load(7, 12), isNull);
  });
}
