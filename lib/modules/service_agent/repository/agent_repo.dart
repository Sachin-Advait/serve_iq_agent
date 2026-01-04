import 'package:servelq_agent/common/constants/api_constants.dart';
import 'package:servelq_agent/models/counter_model.dart';
import 'package:servelq_agent/models/service_history.dart';
import 'package:servelq_agent/models/token_model.dart';
import 'package:servelq_agent/services/api_client.dart';
import 'package:servelq_agent/services/session_manager.dart';

class AgentRepository {
  final ApiClient _apiClient;

  AgentRepository(this._apiClient);

  Future<List<TokenModel>> getQueue() async {
    try {
      final response = await _apiClient.getApi(
        ApiConstants.queue + SessionManager.getCounter(),
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => TokenModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load queue');
    } catch (e) {
      rethrow;
    }
  }

  Future<TokenModel> callToken({String? tokenId}) async {
    try {
      final endpoint = tokenId != null
          ? ApiConstants.callHoldToken + tokenId
          : ApiConstants.callNext + SessionManager.getCounter();

      final response = await _apiClient.postApi(endpoint);

      if (response != null && response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final token = TokenModel.fromJson(data);

          Future.delayed(const Duration(seconds: 15), () {
            startServing(token.id);
          });

          return token;
        }
      }
      throw Exception('Failed to call token');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> startServing(String tokenId) async {
    await _apiClient.postApi(ApiConstants.startServing + tokenId);
  }

  Future<void> completeToken(String tokenId) async {
    final response = await _apiClient.postApi(
      ApiConstants.completeService + tokenId,
    );

    if (response != null && response.statusCode != 200) {}
  }

  Future<List<ServiceHistory>> getRecentTokens() async {
    try {
      final response = await _apiClient.getApi(
        ApiConstants.recentServices + SessionManager.getCounter(),
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => ServiceHistory.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load recent services');
    } catch (e) {
      rethrow;
    }
  }

  Future<CounterModel> getCounter() async {
    final path = ApiConstants.singleCounter + SessionManager.getCounter();
    try {
      final response = await _apiClient.getApi(path);

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return CounterModel.fromJson(data);
        } else {
          throw Exception('Expected a single object but got a different type');
        }
      }

      throw Exception('Failed to load counter details');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CounterModel>> getAllCounters() async {
    const path = ApiConstants.counters;
    try {
      final response = await _apiClient.getApi(path);

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((item) => CounterModel.fromJson(item)).toList();
        } else {
          throw Exception('Expected a list but got a different type');
        }
      }

      throw Exception('Failed to load counters');
    } catch (e) {
      rethrow;
    }
  }

  Future<TokenModel> recallToken(String tokenId) async {
    try {
      final response = await _apiClient.postApi(ApiConstants.recall + tokenId);

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final token = TokenModel.fromJson(data);

          Future.delayed(const Duration(seconds: 15), () {
            startServing(token.id);
          });

          return token;
        } else {
          throw Exception('Expected a token object but got a different type');
        }
      }

      throw Exception('Failed to recall token');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> transferToken(String tokenId, String counterId) async {
    final response = await _apiClient.postApi(
      ApiConstants.transfer,
      body: {"tokenId": tokenId, "toCounterId": counterId},
    );

    if (response == null && response?.statusCode != 200) {
      throw Exception('Failed to complete service');
    }
  }

  Future<void> holdToken(String tokenId) async {
    final response = await _apiClient.postApi(ApiConstants.hold + tokenId);

    if (response == null && response?.statusCode != 200) {
      throw Exception('Failed to complete service');
    }
  }

  Future<void> noShow(String tokenId) async {
    final response = await _apiClient.postApi(ApiConstants.noShow + tokenId);

    if (response == null && response?.statusCode != 200) {
      throw Exception('Failed to complete service');
    }
  }

  Future<TokenModel?> counterActiveToken() async {
    final response = await _apiClient.getApi(
      ApiConstants.activeToken + SessionManager.getCounter(),
    );

    if (response != null && response.statusCode == 200) {
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final token = TokenModel.fromJson(data);
        if (token.status == "CALLING") {
          startServing(token.id);
        }

        return token;
      }
    }
    return null;
  }
}
