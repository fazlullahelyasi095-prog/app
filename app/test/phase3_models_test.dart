import 'package:flutter_test/flutter_test.dart';
import 'package:tryhub_app/models/comment.dart';
import 'package:tryhub_app/models/feed_ad.dart';

void main() {
  test('parses the existing comment response', () {
    final comment = VideoComment.fromJson({
      'id': 3,
      'comment': 'Hello',
      'created_at': '2026-09-06T10:00:00.000Z',
      'username': 'viewer',
      'profile_picture': 'uploads/profile/viewer.png',
    });

    expect(comment.id, 3);
    expect(comment.text, 'Hello');
    expect(comment.username, 'viewer');
    expect(comment.profilePicture, 'uploads/profile/viewer.png');
    expect(comment.createdAt, DateTime.parse('2026-09-06T10:00:00.000Z'));
  });

  test('parses the existing ad delivery response', () {
    final ad = FeedAd.fromJson({
      'id': 8,
      'title': 'Campaign',
      'description': 'Description',
      'image': 'https://example.com/ad.png',
      'destination_url': 'https://example.com',
      'call_to_action': 'Learn more',
      'campaign_name': 'Autumn',
      'deliveryToken': 'signed-delivery-token',
    });

    expect(ad.id, 8);
    expect(ad.title, 'Campaign');
    expect(ad.image, 'https://example.com/ad.png');
    expect(ad.campaignName, 'Autumn');
    expect(ad.deliveryToken, 'signed-delivery-token');
  });
}
