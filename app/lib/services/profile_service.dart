import '../api/api_client.dart';
import '../models/feed_video.dart';
import '../models/user.dart';

class UserProfile {
  final User user;
  final List<FeedVideo> videos;
  const UserProfile(this.user, this.videos);
}

class ProfileService {
  final _api = ApiClient.instance.dio;

  Future<UserProfile> load(int userId) async {
    final response = await _api.get('/user/$userId');
    final userJson = Map<String, dynamic>.from(response.data['user']);
    final videos = (response.data['videos'] as List? ?? const []).map((item) {
      final json = Map<String, dynamic>.from(item);
      json.addAll({
        'user_id': userId,
        'username': userJson['username'],
        'profile_picture': userJson['profile_picture'],
        'followers': userJson['followers'],
      });
      return FeedVideo.fromJson(json);
    }).toList();
    return UserProfile(User.fromJson(userJson), videos);
  }

  Future<bool> followStatus(int userId) async {
    final response = await _api.get('/follow/status/$userId');
    return response.data['isFollowing'] == true;
  }

  Future<bool> toggleFollow(int userId) async {
    final response = await _api.post('/follow/$userId');
    return response.data['isFollowing'] == true;
  }
}
