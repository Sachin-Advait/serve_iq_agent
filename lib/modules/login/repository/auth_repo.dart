import 'package:servelq_agent/common/constants/api_constants.dart';
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
        ApiConstants.login,
        body: {'email': username, 'password': password},
      );

      if (response != null && response.statusCode == 200) {
        final responseData = AuthResponse.fromJson(response.data);
        SessionManager.saveUsername(responseData.user.name);
        SessionManager.saveToken(responseData.token);
        SessionManager.savebranch(responseData.user.branchId);
        SessionManager.saveCounter(responseData.user.counterId);
        SessionManager.saveUserId(responseData.user.id);
        return responseData.user;
      }
      throw Exception('Login failed');
    } catch (e) {
      rethrow;
    }
  }
}
