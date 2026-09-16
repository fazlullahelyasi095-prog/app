class FeedVideo {
  final int id;
  final int userId;
  final String url;
  final String caption;
  final String username;
  final String? profilePicture;
  final int likes;
  final int comments;
  final int followers;

  const FeedVideo({
    required this.id,
    required this.userId,
    required this.url,
    required this.caption,
    required this.username,
    required this.likes,
    required this.comments,
    required this.followers,
    this.profilePicture,
  });

  factory FeedVideo.fromJson(Map<String, dynamic> json) => FeedVideo(
    id: int.parse('${json['id']}'),
    userId: int.parse('${json['user_id']}'),
    url: '${json['video_url'] ?? ''}',
    caption: '${json['caption'] ?? ''}',
    username: '${json['username'] ?? ''}',
    profilePicture: json['profile_picture']?.toString(),
    likes: int.tryParse('${json['likes'] ?? 0}') ?? 0,
    comments: int.tryParse('${json['comments'] ?? 0}') ?? 0,
    followers: int.tryParse('${json['followers'] ?? 0}') ?? 0,
  );
}
