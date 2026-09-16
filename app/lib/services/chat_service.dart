import 'package:dio/dio.dart';
import '../api/api_client.dart';

class ChatService {
  ChatService({Dio? api}) : _api = api ?? ApiClient.instance.dio;
  final Dio _api;
  Future<List<Map<String, dynamic>>> conversations() async =>
      _rows((await _api.get('/chat/list')).data);
  Future<int> start(int userId) async => int.parse(
    '${(await _api.post('/chat/start', data: {'userId': userId})).data['id']}',
  );
  Future<List<Map<String, dynamic>>> messages(int id) async =>
      _rows((await _api.get('/chat/$id')).data);
  Future<void> read(int id) async {
    await _api.post('/chat/read', data: {'conversationId': id});
  }

  Future<void> readIncoming(
    int id,
    List<Map<String, dynamic>> messages,
    int? userId,
  ) async {
    // /chat/read emits conversation_updated even when no rows change.
    // Only unread incoming messages need a write when that event refetches.
    if (userId != null &&
        messages.any(
          (message) =>
              '${message['receiverId']}' == '$userId' &&
              message['isRead'] == false,
        )) {
      await read(id);
    }
  }

  Future<Map<String, dynamic>> send(
    int id,
    String message, {
    MultipartFile? media,
  }) async => Map<String, dynamic>.from(
    (await _api.post(
      '/chat/send',
      data: media == null
          ? {'conversationId': id, 'message': message.trim()}
          : FormData.fromMap({
              'conversationId': id,
              'message': message.trim(),
              'media': media,
            }),
    )).data,
  );
  static List<Map<String, dynamic>> _rows(dynamic data) =>
      (data as List).map((row) => Map<String, dynamic>.from(row)).toList();
}
