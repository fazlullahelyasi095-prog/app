class User {
  final int id;
  final String username;
  final String? email;
  final String? profilePicture;
  final int followers;
  final int following;

  const User({
    required this.id,
    required this.username,
    this.email,
    this.profilePicture,
    this.followers = 0,
    this.following = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: int.parse('${json['id']}'),
    username: '${json['username'] ?? ''}',
    email: json['email']?.toString(),
    profilePicture: json['profile_picture']?.toString(),
    followers: int.tryParse('${json['followers'] ?? 0}') ?? 0,
    following: int.tryParse('${json['following'] ?? 0}') ?? 0,
  );
}
