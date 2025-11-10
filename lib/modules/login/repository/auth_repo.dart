import 'package:servelq_agent/models/user_model.dart';
import 'package:servelq_agent/services/api_client.dart';
import 'package:servelq_agent/services/session_manager.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<UserModel> login({
    required String username,
    required String password,
    required String userType,
  }) async {
    try {
      final response = await _apiClient.postApi(
        'auth/login',
        body: {'email': username, 'password': password},
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final userData = Map<String, dynamic>.from(data);
          UserModel user = UserModel.fromJson(userData);
          SessionManager.saveUsername(user.name);
          SessionManager.saveToken(user.id);
          return user;
        }
      }
      throw Exception('Login failed');
    } catch (e) {
      rethrow;
    }
  }
}
