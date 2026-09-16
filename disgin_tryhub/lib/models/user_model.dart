class UserModel {
  final int id;
  final String username;
  final String name;
  final String avatar;
  final String bio;

  int followers;
  int following;
  int likes;

  bool isFollowing;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.avatar,
    required this.bio,
    required this.followers,
    required this.following,
    required this.likes,
    this.isFollowing = false,
  });
}
