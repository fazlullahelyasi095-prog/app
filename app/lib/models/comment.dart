class VideoComment {
  final int id;
  final String text;
  final String username;
  final String? profilePicture;
  final DateTime? createdAt;

  const VideoComment({
    required this.id,
    required this.text,
    required this.username,
    this.profilePicture,
    this.createdAt,
  });

  factory VideoComment.fromJson(Map<String, dynamic> json) => VideoComment(
    id: int.parse('${json['id']}'),
    text: '${json['comment'] ?? ''}',
    username: '${json['username'] ?? ''}',
    profilePicture: json['profile_picture']?.toString(),
    createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
  );
}
