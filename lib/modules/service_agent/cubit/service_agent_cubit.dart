import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:servelq_agent/common/widgets/custom_loader.dart';
import 'package:servelq_agent/common/widgets/flutter_toast.dart';
import 'package:servelq_agent/models/counter_model.dart';
import 'package:servelq_agent/models/service_history.dart';
import 'package:servelq_agent/models/token_model.dart';
import 'package:servelq_agent/modules/service_agent/repository/agent_repo.dart';
import 'package:servelq_agent/services/web_socket_service.dart';

part 'service_agent_state.dart';

class ServiceAgentCubit extends Cubit<ServiceAgentState> {
  final AgentRepository agentRepository;

  ServiceAgentCubit(this.agentRepository) : super(const ServiceAgentState());

  Future<void> loadInitialData() async {
    emit(state.copyWith(status: ServiceAgentStatus.loading));
    await loadingData();

    // After counter is loaded → initialize WebSocket
    if (state.counter != null) {
      WebSocketService.connect(
        counterId: state.counter!.id,
        onUpcomingUpdate: (data) {
          debugPrint("Upcoming queue update received");

          try {
            final List<TokenModel> queue = data
                .map<TokenModel>(
                  (json) => TokenModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();

            // Actually update the state
            emit(state.copyWith(queue: queue));

            debugPrint("Queue updated with ${queue.length} tokens");
          } catch (e, stackTrace) {
            debugPrint("Error parsing token data: $e");
            debugPrint("StackTrace: $stackTrace");
            debugPrint("Data type: ${data.runtimeType}");
            debugPrint(
              "First item type: ${data.isNotEmpty ? data.first.runtimeType : 'empty'}",
            );
          }
        },
        onCounterUpdate: (json) async {
          final updatedCounter = CounterModel.fromJson(json);

          final updatedRecentServices = await agentRepository
              .getRecentServices();

          emit(
            state.copyWith(
              counter: updatedCounter,
              recentServices: updatedRecentServices,
            ),
          );

          debugPrint("Counter status updated: ${updatedCounter.status}");
        },
      );
    }
  }

  Future<void> loadingData() async {
    try {
      final counterFuture = agentRepository.getCounter();
      final queueFuture = agentRepository.getQueue();
      final recentServicesFuture = agentRepository.getRecentServices();
      final allCounterFuture = agentRepository.getAllCounters();
      final activeTokenFuture = agentRepository.counterActiveToken();

      final results = await Future.wait([
        counterFuture,
        queueFuture,
        recentServicesFuture,
        allCounterFuture,
        activeTokenFuture,
      ]);

      final counter = results[0] as CounterModel;
      final queue = results[1] as List<TokenModel>;
      final recentServices = results[2] as List<ServiceHistory>;
      final allCounter = results[3] as List<CounterModel>;
      final activeToken = results[4] as TokenModel?;

      emit(
        ServiceAgentState(
          status: ServiceAgentStatus.loaded,
          currentTokenStatus: activeToken?.id != null
              ? CurrentTokenStatus.loaded
              : CurrentTokenStatus.initial,
          counter: counter,
          queue: queue,
          recentServices: recentServices,
          currentToken: activeToken,
          allCounter: allCounter,
        ),
      );
    } catch (e) {
      emit(ServiceAgentState(status: ServiceAgentStatus.error));
    }
  }

  Future<void> queueAPI() async {
    if (state.status != ServiceAgentStatus.loaded) return;
    final queue = await agentRepository.getQueue();
    emit(state.copyWith(queue: queue));
  }

  Future<void> callNext() async {
    try {
      customLoader();

      final nextToken = await agentRepository.callNext();
      emit(
        state.copyWith(
          status: ServiceAgentStatus.loaded,
          currentToken: nextToken,
          currentTokenStatus: CurrentTokenStatus.loaded,
        ),
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> completeService() async {
    try {
      customLoader();
      final tokenId = state.currentToken!.id;

      // Complete the current service
      await agentRepository.completeService(tokenId);
      final counter = await agentRepository.getCounter();

      emit(
        state.copyWith(
          currentTokenStatus: CurrentTokenStatus.initial,
          counter: counter,
          currentToken: TokenModel(),
        ),
      );
    } catch (e) {
      await loadInitialData();
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> recallCurrentToken() async {
    try {
      customLoader();
      final tokenId = state.currentToken!.id;

      final recalledToken = await agentRepository.recallToken(tokenId);

      emit(state.copyWith(currentToken: recalledToken));
      flutterToast(message: 'Token successfully recalled');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> transferService(String counterId) async {
    try {
      customLoader();

      final tokenId = state.currentToken!.id;
      await agentRepository.transferService(tokenId, counterId);

      emit(
        state.copyWith(
          currentTokenStatus: CurrentTokenStatus.initial,
          currentToken: TokenModel(),
        ),
      );

      flutterToast(message: 'Token successfully transferred');
      await queueAPI();
    } catch (e) {
      flutterToast(message: 'Error while transfering. Please try again');
    } finally {
      EasyLoading.dismiss();
    }
  }

  // New method to check for active token manually
  Future<void> checkActiveToken() async {
    try {
      customLoader();

      if (state.status != ServiceAgentStatus.loaded) return;

      final activeToken = await agentRepository.counterActiveToken();

      if (state.currentToken?.id != activeToken?.id) {
        // If we have a new active token different from current
        final updatedQueue = await agentRepository.getQueue();

        emit(state.copyWith(currentToken: activeToken, queue: updatedQueue));
        if (activeToken != null) {
          flutterToast(message: 'Active token loaded: ${activeToken.token}');
        }
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Future<void> close() {
    WebSocketService.disconnect();
    return super.close();
  }
}
