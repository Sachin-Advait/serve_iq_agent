import 'package:servelq_agent/models/display_token.dart';
import 'package:servelq_agent/services/api_client.dart';

class TVDisplayRepository {
  final ApiClient _apiClient;

  TVDisplayRepository(this._apiClient);

  Future<TVDisplayResponse> getDisplayData(String branchId) async {
    // try {
    final response = await _apiClient.getApi('tv-display/branch/$branchId');

    if (response != null && response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return TVDisplayResponse.fromJson(data);
      }
    }
    throw Exception('Failed to load display data');
    // } catch (e) {
    //   rethrow;
    // }
  }
}
