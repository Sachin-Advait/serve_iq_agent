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
        'agent/counter/queue/${SessionManager.getCounter()}',
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

  Future<TokenModel> callNext() async {
    try {
      final response = await _apiClient.postApi(
        'agent/counter/call-next/${SessionManager.getCounter()}',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        TokenModel? token;

        if (data is Map<String, dynamic>) {
          token = TokenModel.fromJson(data);

          // Call startServing after 4 seconds
          Future.delayed(const Duration(seconds: 4), () {
            startServing(token!.id);
          });

          return token;
        }
      }

      throw Exception('Failed to call next token');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> startServing(String tokenId) async {
    try {
      final response = await _apiClient.postApi(
        'agent/token/start-serving/$tokenId',
      );

      if (response != null && response.statusCode != 200) {
        throw Exception('Failed to start serving');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeService(String tokenId) async {
    try {
      final response = await _apiClient.postApi(
        'agent/token/complete/$tokenId',
      );

      if (response != null && response.statusCode != 200) {
        throw Exception('Failed to complete service');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ServiceHistory>> getRecentServices() async {
    try {
      final response = await _apiClient.getApi('agent/recent-services');

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

  // Fetch a single counter by session counter ID
  Future<CounterModel> getCounter() async {
    final path = "counters/${SessionManager.getCounter()}";
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

  // Fetch all counters
  Future<List<CounterModel>> getAllCounters() async {
    const path = "counters";
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
}
