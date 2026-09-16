import '../api/api_client.dart';
import '../models/user.dart';

class AuthResult {
  final String token;
  final User user;
  const AuthResult(this.token, this.user);
}

class AuthService {
  final _api = ApiClient.instance.dio;

  Future<AuthResult> login(String email, String password) async {
    final response = await _api.post(
      '/auth/login',
      data: {'email': email.trim(), 'password': password},
    );
    return AuthResult(
      response.data['token'].toString(),
      User.fromJson(Map<String, dynamic>.from(response.data['user'])),
    );
  }

  Future<void> register(String username, String email, String password) async {
    await _api.post(
      '/auth/register',
      data: {
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
        'termsAccepted': true,
        'privacyAccepted': true,
      },
    );
  }

  Future<User> profile() async {
    final response = await _api.get('/auth/profile');
    return User.fromJson(Map<String, dynamic>.from(response.data['user']));
  }
}
