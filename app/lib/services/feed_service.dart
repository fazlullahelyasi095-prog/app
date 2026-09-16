import '../api/api_client.dart';
import '../models/feed_video.dart';

class FeedService {
  Future<List<FeedVideo>> load() async {
    final response = await ApiClient.instance.dio.get('/feed');
    return (response.data['videos'] as List? ?? const [])
        .map((item) => FeedVideo.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
