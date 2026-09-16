import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tryhub_app/services/chat_service.dart';

void main() {
  test('chat attachments use the existing multipart media field', () async {
    final adapter = _Adapter();
    final service = ChatService(api: Dio()..httpClientAdapter = adapter);
    await service.send(
      12,
      ' caption ',
      media: MultipartFile.fromBytes(
        [1, 2, 3],
        filename: 'photo.jpg',
        contentType: DioMediaType.parse('image/jpeg'),
      ),
    );
    final request = adapter.requests.single;
    expect(request.path, '/chat/send');
    final form = request.data as FormData;
    expect(Map.fromEntries(form.fields), {
      'conversationId': '12',
      'message': 'caption',
    });
    expect(form.files.single.key, 'media');
    expect(form.files.single.value.filename, 'photo.jpg');
    expect(form.files.single.value.contentType.toString(), 'image/jpeg');
    expect(request.contentType, startsWith('multipart/form-data'));
  });
  test(
    'read updates settle after the server broadcasts conversation_updated',
    () async {
      final adapter = _Adapter();
      final service = ChatService(api: Dio()..httpClientAdapter = adapter);
      await service.readIncoming(12, [
        {'receiverId': 9, 'isRead': false},
        {'receiverId': 7, 'isRead': false},
      ], 9);
      // The event refetch now contains the server's updated read state.
      await service.readIncoming(12, [
        {'receiverId': 9, 'isRead': true},
        {'receiverId': 7, 'isRead': false},
      ], 9);
      await service.readIncoming(12, [], 9);
      await service.readIncoming(12, [
        {'receiverId': 9, 'isRead': false},
      ], null);
      expect(adapter.requests.length, 1);
      expect(adapter.requests.single.path, '/chat/read');
      expect(adapter.requests.single.data, {'conversationId': 12});
    },
  );
  test('chat preserves the existing request and response contracts', () async {
    final adapter = _Adapter();
    final service = ChatService(api: Dio()..httpClientAdapter = adapter);
    expect(await service.start(9), 12);
    expect((await service.send(12, ' hello '))['message'], 'hello');
    await service.read(12);
    expect(adapter.requests.map((r) => '${r.method} ${r.path}'), [
      'POST /chat/start',
      'POST /chat/send',
      'POST /chat/read',
    ]);
    expect(adapter.requests[0].data, {'userId': 9});
    expect(adapter.requests[1].data, {
      'conversationId': 12,
      'message': 'hello',
    });
    expect(adapter.requests[2].data, {'conversationId': 12});
  });
  test('a rejected message is not reported as sent', () async {
    final service = ChatService(
      api: Dio()..httpClientAdapter = _Adapter(fail: true),
    );
    await expectLater(service.send(12, 'hello'), throwsA(isA<DioException>()));
  });
}

class _Adapter implements HttpClientAdapter {
  _Adapter({this.fail = false});
  final bool fail;
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      fail
          ? '{"message":"Forbidden"}'
          : switch (options.path) {
              '/chat/start' => '{"id":12}',
              '/chat/send' => '{"id":21,"conversationId":12,"message":"hello"}',
              _ => '{"success":true}',
            },
      fail ? 403 : 200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
