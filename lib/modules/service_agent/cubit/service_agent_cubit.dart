import 'dart:async';

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
  Timer? _completeButtonTimer;

  ServiceAgentCubit(this.agentRepository) : super(const ServiceAgentState());

  void startCompleteButtonTimer() {
    _completeButtonTimer?.cancel();

    emit(
      state.copyWith(
        completeButtonRemainingSeconds: 20,
        isCompleteButtonDisabled: true,
      ),
    );

    _completeButtonTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newSeconds = state.completeButtonRemainingSeconds - 1;

      if (newSeconds <= 0) {
        emit(
          state.copyWith(
            completeButtonRemainingSeconds: 0,
            isCompleteButtonDisabled: false,
          ),
        );
        timer.cancel();
      } else {
        emit(state.copyWith(completeButtonRemainingSeconds: newSeconds));
      }
    });
  }

  void cancelCompleteButtonTimer() {
    _completeButtonTimer?.cancel();
    emit(
      state.copyWith(
        completeButtonRemainingSeconds: 0,
        isCompleteButtonDisabled: false,
      ),
    );
  }

  Future<void> loadInitialData() async {
    emit(state.copyWith(status: ServiceAgentStatus.loading));
    await loadingData();
    emit(state.copyWith(webSocketStatus: WebSocketStatus.connecting));

    // After counter is loaded → initialize WebSocket
    if (state.counter != null) {
      await WebSocketService.connect(
        counterId: state.counter!.id,
        onUpcomingUpdate: _handleUpcomingUpdate,
        onCounterUpdate: _handleCounterUpdate,
        onConnectionStatus: _handleConnectionStatus,
      );
    }
  }

  void _handleConnectionStatus(String message, bool isError) {
    debugPrint("WebSocket connection status: $message (error: $isError)");

    if (isError) {
      // Emit error state with connection message
      emit(
        state.copyWith(
          webSocketStatus: WebSocketStatus.error,
          webSocketErrorMessage: message,
        ),
      );
    } else {
      // Emit connected state
      emit(
        state.copyWith(
          webSocketStatus: WebSocketStatus.connected,
          webSocketErrorMessage: null,
        ),
      );
    }
  }

  void _handleUpcomingUpdate(List<dynamic> data) {
    debugPrint("Upcoming queue update received");

    try {
      final List<TokenModel> queue = data
          .map<TokenModel>(
            (json) => TokenModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      List<TokenModel> upcomingToken = [];
      List<TokenModel> holdToken = [];

      for (var element in queue) {
        if (element.status == "HOLD") {
          holdToken.add(element);
        } else {
          upcomingToken.add(element);
        }
      }

      emit(state.copyWith(queue: upcomingToken, holdQueue: holdToken));

      debugPrint("Queue updated with ${queue.length} tokens");
    } catch (e, stackTrace) {
      debugPrint("Error parsing token data: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  Future<void> _handleCounterUpdate(Map<String, dynamic> json) async {
    try {
      final updatedCounter = CounterModel.fromJson(json);
      final updatedRecentServices = await agentRepository.getRecentTokens();

      emit(
        state.copyWith(
          counter: updatedCounter,
          recentServices: updatedRecentServices,
        ),
      );

      debugPrint("Counter status updated: ${updatedCounter.status}");
    } catch (e) {
      debugPrint("Error handling counter update: $e");
    }
  }

  Future<void> loadingData() async {
    try {
      final counterFuture = agentRepository.getCounter();
      final queueFuture = agentRepository.getQueue();
      final recentServicesFuture = agentRepository.getRecentTokens();
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

      List<TokenModel> upcomingToken = [];
      List<TokenModel> holdToken = [];

      for (var element in queue) {
        if (element.status == "HOLD") {
          holdToken.add(element);
        } else {
          upcomingToken.add(element);
        }
      }

      emit(
        ServiceAgentState(
          status: ServiceAgentStatus.loaded,
          currentTokenStatus: activeToken?.id != null
              ? CurrentTokenStatus.loaded
              : CurrentTokenStatus.initial,
          counter: counter,
          queue: upcomingToken,
          holdQueue: holdToken,
          recentServices: recentServices,
          currentToken: activeToken,
          allCounter: allCounter,
        ),
      );
    } catch (e) {
      debugPrint('Error loading data: $e');
      emit(ServiceAgentState(status: ServiceAgentStatus.error));
    }
  }

  Future<void> queueAPI() async {
    if (state.status != ServiceAgentStatus.loaded) return;

    try {
      final queue = await agentRepository.getQueue();
      List<TokenModel> upcomingToken = [];
      List<TokenModel> holdToken = [];

      for (var element in queue) {
        if (element.status == "HOLD") {
          holdToken.add(element);
        } else {
          upcomingToken.add(element);
        }
      }

      emit(state.copyWith(queue: upcomingToken, holdQueue: holdToken));
    } catch (e) {
      debugPrint('Error fetching queue: $e');
    }
  }

  Future<void> callToken({String? tokenId}) async {
    try {
      customLoader();

      final nextToken = await agentRepository.callToken(tokenId: tokenId);
      emit(
        state.copyWith(
          status: ServiceAgentStatus.loaded,
          currentToken: nextToken,
          currentTokenStatus: CurrentTokenStatus.loaded,
        ),
      );

      // Start the timer after calling token
      startCompleteButtonTimer();
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> completeToken() async {
    try {
      customLoader();
      final tokenId = state.currentToken!.id;

      // Complete the current service
      await agentRepository.completeToken(tokenId);
      final counter = await agentRepository.getCounter();

      // Cancel timer and reset state
      cancelCompleteButtonTimer();

      emit(
        state.copyWith(
          currentTokenStatus: CurrentTokenStatus.initial,
          counter: counter,
          currentToken: TokenModel(),
        ),
      );
    } catch (e) {
      debugPrint('Error completing token: $e');
      await loadInitialData();
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> recallToken() async {
    try {
      customLoader();
      final tokenId = state.currentToken!.id;

      final recalledToken = await agentRepository.recallToken(tokenId);

      emit(state.copyWith(currentToken: recalledToken));

      // Restart the timer after recall
      startCompleteButtonTimer();

      flutterToast(message: 'Token successfully recalled');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> transferToken(String counterId) async {
    try {
      customLoader();

      final tokenId = state.currentToken!.id;
      await agentRepository.transferToken(tokenId, counterId);

      // Cancel timer and reset state
      cancelCompleteButtonTimer();

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

  Future<void> holdToken() async {
    try {
      customLoader();

      final tokenId = state.currentToken!.id;
      await agentRepository.holdToken(tokenId);
      final counter = await agentRepository.getCounter();

      // Cancel timer and reset state
      cancelCompleteButtonTimer();

      emit(
        state.copyWith(
          currentTokenStatus: CurrentTokenStatus.initial,
          currentToken: TokenModel(),
          counter: counter,
        ),
      );
    } catch (e) {
      flutterToast(message: 'Error while holding token. Please try again');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> checkActiveToken() async {
    try {
      customLoader();

      if (state.status != ServiceAgentStatus.loaded) return;

      final activeToken = await agentRepository.counterActiveToken();

      if (state.currentToken?.id != activeToken?.id) {
        final updatedQueue = await agentRepository.getQueue();
        List<TokenModel> upcomingToken = [];
        List<TokenModel> holdToken = [];

        for (var element in updatedQueue) {
          if (element.status == "HOLD") {
            holdToken.add(element);
          } else {
            upcomingToken.add(element);
          }
        }

        emit(
          state.copyWith(
            queue: upcomingToken,
            holdQueue: holdToken,
            currentToken: activeToken,
          ),
        );

        if (activeToken != null) {
          flutterToast(message: 'Active token loaded: ${activeToken.token}');
        }
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Handle app resume
  Future<void> onAppResumed() async {
    debugPrint('App resumed from background');
    await WebSocketService.onAppResumed();
    await loadingData();
  }

  /// Manual retry for WebSocket connection
  Future<void> retryWebSocketConnection() async {
    emit(state.copyWith(webSocketStatus: WebSocketStatus.connecting));
    await WebSocketService.resetAndRetry();
  }

  @override
  Future<void> close() {
    _completeButtonTimer?.cancel();
    WebSocketService.disconnect();
    return super.close();
  }
}
