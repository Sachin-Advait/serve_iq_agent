import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:servelq_agent/common/widgets/custom_loader.dart';
import 'package:servelq_agent/common/widgets/flutter_toast.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/models/counter_model.dart';
import 'package:servelq_agent/models/service_history.dart';
import 'package:servelq_agent/models/token_model.dart';
import 'package:servelq_agent/modules/home/repository/home_repo.dart';
import 'package:servelq_agent/services/web_socket_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository agentRepository;
  Timer? _completeButtonTimer;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  HomeCubit(this.agentRepository) : super(const HomeState()) {
    _initializeConnectivityListener();
  }

  void _initializeConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final result = results.isNotEmpty
          ? results.last
          : ConnectivityResult.none;
      _handleConnectivityChange(result);
    });

    // Check initial connectivity
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final result = connectivityResults.isNotEmpty
          ? connectivityResults.last
          : ConnectivityResult.none;
      _handleConnectivityChange(result);
    } catch (e) {
      debugPrint('Error checking initial connectivity: $e');
    }
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    debugPrint('Connectivity changed: $result');

    final isConnected = result != ConnectivityResult.none;
    final previouslyConnected = state.isNetworkConnected;

    emit(
      state.copyWith(
        isNetworkConnected: isConnected,
        connectivityStatus: result,
      ),
    );

    // Handle network state changes
    if (isConnected && !previouslyConnected) {
      debugPrint('Network connection restored');

      // Update state to track network restoration
      emit(state.copyWith(wasNetworkRestored: true));

      // Refresh data when network comes back
      _refreshDataOnNetworkRestore();

      // Check if WebSocket needs reconnection
      if (state.counter != null && !WebSocketService.isConnected) {
        Future.delayed(const Duration(seconds: 2), () {
          if (state.isNetworkConnected && !WebSocketService.isConnected) {
            _retryWebSocketWithNetworkCheck();
          }
        });
      }
    } else if (!isConnected && previouslyConnected) {
      debugPrint('Network connection lost');

      // Update state to show offline mode
      emit(
        state.copyWith(
          wasNetworkRestored: false,
          webSocketStatus: WebSocketStatus.error,
          webSocketErrorMessage: 'No internet connection',
        ),
      );

      // Show toast notification
      if (state.status == HomeStatus.loaded) {
        flutterToast(
          message: 'No internet connection',
          color: AppColors.darkRed,
        );
      }
    }
  }

  Future<void> _refreshDataOnNetworkRestore() async {
    try {
      // Give a small delay for network to stabilize
      await Future.delayed(const Duration(seconds: 2));

      // Refresh only if we're in loaded state
      if (state.status == HomeStatus.loaded) {
        await loadingData();
        flutterToast(message: 'Connection restored');
      }
    } catch (e) {
      debugPrint('Error refreshing data after network restore: $e');
    }
  }

  Future<void> _retryWebSocketWithNetworkCheck() async {
    if (!state.isNetworkConnected) {
      debugPrint('Cannot retry WebSocket: No network connection');
      return;
    }

    emit(state.copyWith(webSocketStatus: WebSocketStatus.connecting));

    // Add a small delay to ensure network is stable
    await Future.delayed(const Duration(seconds: 1));

    await WebSocketService.resetAndRetry();
  }

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
    // Check network connectivity first
    if (!state.isNetworkConnected) {
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          webSocketStatus: WebSocketStatus.error,
          webSocketErrorMessage: 'No internet connection',
        ),
      );

      flutterToast(
        message: 'No internet connection. Please check your network.',
        color: AppColors.darkRed,
      );
      return;
    }

    emit(state.copyWith(status: HomeStatus.loading));

    try {
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
    } catch (e) {
      debugPrint('Error in loadInitialData: $e');

      // Check if error is network-related
      if (!state.isNetworkConnected) {
        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            webSocketStatus: WebSocketStatus.error,
            webSocketErrorMessage: 'No internet connection',
          ),
        );
      } else {
        emit(state.copyWith(status: HomeStatus.error));
      }
    }
  }

  void _handleConnectionStatus(String message, bool isError) {
    debugPrint("WebSocket connection status: $message (error: $isError)");

    if (isError) {
      // Check if error is due to network
      if (!state.isNetworkConnected) {
        emit(
          state.copyWith(
            webSocketStatus: WebSocketStatus.error,
            webSocketErrorMessage: 'No internet connection',
          ),
        );
      } else {
        emit(
          state.copyWith(
            webSocketStatus: WebSocketStatus.error,
            webSocketErrorMessage: message,
          ),
        );
      }
    } else {
      // Emit connected state
      emit(
        state.copyWith(
          webSocketStatus: WebSocketStatus.connected,
          webSocketErrorMessage: null,
          wasNetworkRestored: false,
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
    if (!state.isNetworkConnected) {
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          webSocketStatus: WebSocketStatus.error,
          webSocketErrorMessage: 'No internet connection',
        ),
      );
      return;
    }

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
        HomeState(
          status: HomeStatus.loaded,
          currentTokenStatus: activeToken?.id != null
              ? CurrentTokenStatus.loaded
              : CurrentTokenStatus.initial,
          counter: counter,
          queue: upcomingToken,
          holdQueue: holdToken,
          recentServices: recentServices,
          currentToken: activeToken,
          allCounter: allCounter,
          isNetworkConnected: state.isNetworkConnected,
          connectivityStatus: state.connectivityStatus,
          webSocketStatus: WebSocketService.isConnected
              ? WebSocketStatus.connected
              : WebSocketStatus.error,
          webSocketErrorMessage: state.webSocketErrorMessage,
        ),
      );
    } catch (e) {
      debugPrint('Error loading data: $e');

      // Check if error is network-related
      final isNetworkError =
          e.toString().toLowerCase().contains('socket') ||
          e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connect');

      if (isNetworkError || !state.isNetworkConnected) {
        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            webSocketStatus: WebSocketStatus.error,
            webSocketErrorMessage: 'Network connection issue',
          ),
        );
      } else {
        emit(state.copyWith(status: HomeStatus.error));
      }
    }
  }

  Future<void> queueAPI() async {
    if (state.status != HomeStatus.loaded) return;

    // Check network
    if (!state.isNetworkConnected) {
      flutterToast(message: 'No internet connection', color: AppColors.darkRed);
      return;
    }

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
    // Check network
    if (!state.isNetworkConnected) {
      flutterToast(message: 'No internet connection', color: AppColors.darkRed);
      return;
    }

    try {
      customLoader();

      final nextToken = await agentRepository.callToken(tokenId: tokenId);
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          currentToken: nextToken,
          currentTokenStatus: CurrentTokenStatus.loaded,
        ),
      );

      // Start the timer after calling token
      startCompleteButtonTimer();
    } catch (e) {
      flutterToast(
        message: 'Failed to call token. Please try again.',
        color: AppColors.darkRed,
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> completeToken() async {
    // Check network
    if (!state.isNetworkConnected) {
      flutterToast(message: 'No internet connection', color: AppColors.darkRed);
      return;
    }

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

      if (!state.isNetworkConnected) {
        flutterToast(
          message: 'Operation failed due to network issue',
          color: AppColors.darkRed,
        );
      }

      await loadInitialData();
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> recallToken() async {
    // Check network
    if (!state.isNetworkConnected) {
      flutterToast(message: 'No internet connection', color: AppColors.darkRed);
      return;
    }

    try {
      customLoader();
      final tokenId = state.currentToken!.id;

      final recalledToken = await agentRepository.recallToken(tokenId);

      emit(state.copyWith(currentToken: recalledToken));

      // Restart the timer after recall
      startCompleteButtonTimer();

      flutterToast(message: 'Token successfully recalled');
    } catch (e) {
      flutterToast(
        message: 'Failed to recall token. Please try again.',
        color: AppColors.darkRed,
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> transferToken(String counterId) async {
    // Check network
    if (!state.isNetworkConnected) {
      flutterToast(message: 'No internet connection', color: AppColors.darkRed);
      return;
    }

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
      flutterToast(
        message: 'Error while transferring. Please try again',
        color: AppColors.darkRed,
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> holdToken() async {
    // Check network
    if (!state.isNetworkConnected) {
      flutterToast(message: 'No internet connection', color: AppColors.darkRed);
      return;
    }

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
      flutterToast(
        message: 'Error while holding token. Please try again',
        color: AppColors.darkRed,
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> noShow() async {
    // Check network
    if (!state.isNetworkConnected) {
      flutterToast(message: 'No internet connection', color: AppColors.darkRed);
      return;
    }

    try {
      customLoader();

      final tokenId = state.currentToken!.id;
      await agentRepository.noShow(tokenId);

      // Cancel timer and reset state
      cancelCompleteButtonTimer();

      emit(
        state.copyWith(
          currentTokenStatus: CurrentTokenStatus.initial,
          currentToken: TokenModel(),
          counter: await agentRepository.getCounter(),
        ),
      );
    } catch (e) {
      flutterToast(
        message: 'Unknown Error. Please try again',
        color: AppColors.darkRed,
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> checkActiveToken() async {
    // Check network
    if (!state.isNetworkConnected) {
      flutterToast(message: 'No internet connection', color: AppColors.darkRed);
      return;
    }

    try {
      customLoader();

      if (state.status != HomeStatus.loaded) return;

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

    // Check connectivity first
    await _checkInitialConnectivity();

    await WebSocketService.onAppResumed();
    await loadingData();
  }

  /// Manual retry for WebSocket connection
  Future<void> retryWebSocketConnection() async {
    // Check network first
    if (!state.isNetworkConnected) {
      flutterToast(message: 'No internet connection', color: AppColors.darkRed);

      emit(
        state.copyWith(
          webSocketStatus: WebSocketStatus.error,
          webSocketErrorMessage: 'No internet connection',
        ),
      );
      return;
    }

    emit(state.copyWith(webSocketStatus: WebSocketStatus.connecting));
    await WebSocketService.resetAndRetry();
  }

  /// Check current network status
  Future<void> checkNetworkStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final result = results.isNotEmpty
          ? results.last
          : ConnectivityResult.none;
      _handleConnectivityChange(result);
    } catch (e) {
      debugPrint('Error checking network status: $e');
    }
  }

  @override
  Future<void> close() {
    _completeButtonTimer?.cancel();
    _connectivitySubscription.cancel();
    WebSocketService.disconnect();
    return super.close();
  }
}
