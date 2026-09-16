import 'package:flutter_test/flutter_test.dart';
import 'package:tryhub_app/models/feed_video.dart';

void main() {
  test('parses the exact backend feed fields', () {
    final video = FeedVideo.fromJson({
      'id': 12,
      'user_id': 7,
      'video_url': 'uploads/example.mp4',
      'caption': 'Backend caption',
      'username': 'creator',
      'profile_picture': 'uploads/profile/creator.png',
      'likes': '15',
      'followers': 9,
      'comments': '4',
    });

    expect(video.id, 12);
    expect(video.userId, 7);
    expect(video.url, 'uploads/example.mp4');
    expect(video.caption, 'Backend caption');
    expect(video.username, 'creator');
    expect(video.profilePicture, 'uploads/profile/creator.png');
    expect(video.likes, 15);
    expect(video.followers, 9);
    expect(video.comments, 4);
  });
}
