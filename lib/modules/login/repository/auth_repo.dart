import 'package:servelq_agent/common/constants/api_constants.dart';
import 'package:servelq_agent/common/widgets/flutter_toast.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/models/counter_option.dart';
import 'package:servelq_agent/models/user_model.dart';
import 'package:servelq_agent/services/api_client.dart';
import 'package:servelq_agent/services/session_manager.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<List<CounterOption>> fetchCounters() async {
    final response = await _apiClient.getApi(ApiConstants.authCounters);
    if (response == null || response.statusCode != 200) return [];
    return (response.data as List)
        .map((e) => CounterOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> login({
    required String username,
    required String password,
    required String counterId,
  }) async {
    try {
      final response = await _apiClient.postApi(
        ApiConstants.login,
        body: {'email': username, 'password': password, 'counterId': counterId},
      );

      if (response != null && response.statusCode == 200) {
        final responseData = AuthResponse.fromJson(response.data);
        // Only AGENT accounts may use the agent app
        if (responseData.user.role != 'AGENT') {
          // The server has already signed this account in (and may have given
          // it the counter); sign it straight out again so nothing is left held.
          await SessionManager.saveToken(responseData.token);
          await _apiClient.postApi(ApiConstants.logout);
          await SessionManager.saveToken('');
          flutterToast(message: 'not_authorised_login', color: AppColors.red);
          throw const LoginErrorShown();
        }
        SessionManager.saveUsername(responseData.user.name);
        SessionManager.saveToken(responseData.token);
        SessionManager.savebranch(responseData.user.branchId);
        SessionManager.saveCounter(responseData.user.counterId);
        SessionManager.saveUserId(responseData.user.id);
        ApiClient.sessionEnded = false;
        return responseData.user;
      }
      // ApiClient has already shown the backend's reason.
      throw const LoginErrorShown();
    } catch (e) {
      rethrow;
    }
  }
}

class LoginErrorShown implements Exception {
  const LoginErrorShown();
}
