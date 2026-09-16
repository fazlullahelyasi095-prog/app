import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/comment.dart';

class BlockStatus {
  final bool isBlocked;
  final bool isBlockedBy;
  const BlockStatus({required this.isBlocked, required this.isBlockedBy});
}

class SocialService {
  SocialService({Dio? api}) : _api = api ?? ApiClient.instance.dio;
  final Dio _api;

  Future<bool> likeStatus(int videoId) async {
    final response = await _api.get('/likes/$videoId/status');
    return response.data['isLiked'] == true;
  }

  Future<bool> toggleLike(int videoId) async {
    final response = await _api.post('/likes/$videoId');
    return response.data['isLiked'] == true;
  }

  Future<int> likeCount(int videoId) async {
    final response = await _api.get('/likes/$videoId/count');
    return int.tryParse('${response.data['likes']}') ?? 0;
  }

  Future<List<VideoComment>> comments(int videoId) async {
    final response = await _api.get('/comments/$videoId');
    return (response.data['comments'] as List? ?? const [])
        .map((item) => VideoComment.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<int> addComment(int videoId, String comment) async {
    final response = await _api.post(
      '/comments/$videoId',
      data: {'comment': comment.trim()},
    );
    return int.parse('${response.data['commentId']}');
  }

  Future<BlockStatus> blockStatus(int userId) async {
    final response = await _api.get('/blocks/$userId');
    return BlockStatus(
      isBlocked: response.data['isBlocked'] == true,
      isBlockedBy: response.data['isBlockedBy'] == true,
    );
  }

  Future<bool> toggleBlock(int userId, bool currentlyBlocked) async {
    final response = currentlyBlocked
        ? await _api.delete('/blocks/$userId')
        : await _api.post('/blocks/$userId');
    return response.data['isBlocked'] == true;
  }

  Future<String> report({
    required String targetType,
    required int targetId,
    required String reason,
    String details = '',
  }) async {
    final response = await _api.post(
      '/reports',
      data: {
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        'details': details.trim(),
      },
    );
    return '${response.data['message'] ?? 'Report submitted'}';
  }
}
