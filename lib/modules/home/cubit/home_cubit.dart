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
import 'package:servelq_agent/models/transfer_reason_model.dart';
import 'package:servelq_agent/modules/home/repository/home_repo.dart';
import 'package:servelq_agent/services/api_client.dart';
import 'package:servelq_agent/services/session_manager.dart';
import 'package:servelq_agent/services/web_socket_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository agentRepository;
  Timer? _completeButtonTimer;
  Timer? _feedbackWatchTimer;

  // The agent's note for the token being served; sent when it's completed.
  String _note = '';
  String? _noteTokenId;

  void updateNote(String tokenId, String note) {
    _noteTokenId = tokenId;
    _note = note;
  }

  bool _socketConnectedOnce = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  HomeCubit(this.agentRepository) : super(const HomeState()) {
    _initializeConnectivityListener();
    _startFeedbackWatch();
  }

  /// While the counter waits for the visitor's rating, re-read it every few
  /// seconds. The server frees it after its feedback timeout and pushes that
  /// over the socket, but a push sent while the socket was reconnecting is
  /// lost, which left the "visitor is writing feedback" screen up until a
  /// page refresh.
  void _startFeedbackWatch() {
    _feedbackWatchTimer?.cancel();
    _feedbackWatchTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (state.counter?.status != 'COMPLETE' || !state.isNetworkConnected) {
        return;
      }
      try {
        final counter = await agentRepository.getCounter();
        if (isClosed || counter.status == state.counter?.status) return;
        emit(
          state.copyWith(
            counter: counter,
            recentServices: await agentRepository.getRecentTokens(),
          ),
        );
      } catch (e) {
        debugPrint('Feedback watch failed: $e');
      }
    });
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
      if (ApiClient.sessionEnded) return;
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
      // Updates pushed while the socket was down are lost, so reload once
      // it's back (the first connect already has fresh data).
      final isReconnect = _socketConnectedOnce;
      _socketConnectedOnce = true;
      if (isReconnect && state.status == HomeStatus.loaded) {
        loadingData();
      }

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

  /// The agent queue carries waiting, hold and no-show tokens; each goes to
  /// its own list.
  (List<TokenModel>, List<TokenModel>, List<TokenModel>) _splitQueue(
    List<TokenModel> queue,
  ) {
    final upcoming = <TokenModel>[];
    final hold = <TokenModel>[];
    final noShow = <TokenModel>[];
    for (final element in queue) {
      if (element.status == "HOLD") {
        hold.add(element);
      } else if (element.status == "NO_SHOW") {
        noShow.add(element);
      } else {
        upcoming.add(element);
      }
    }
    return (upcoming, hold, noShow);
  }

  void _handleUpcomingUpdate(List<dynamic> data) {
    debugPrint("Upcoming queue update received");

    try {
      final List<TokenModel> queue = data
          .map<TokenModel>(
            (json) => TokenModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      final (upcomingToken, holdToken, noShowToken) = _splitQueue(queue);

      emit(
        state.copyWith(
          queue: upcomingToken,
          holdQueue: holdToken,
          noShowQueue: noShowToken,
        ),
      );

      debugPrint("Queue updated with ${queue.length} tokens");
    } catch (e, stackTrace) {
      debugPrint("Error parsing token data: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  Future<void> _handleCounterUpdate(Map<String, dynamic> json) async {
    try {
      // /topic/counter/{id} carries a CounterStatusResponseDTO (counterId,
      // status, paused, enabled, token details), not the full counter, so
      // CounterModel.fromJson can't parse it. Merge the status fields into
      // the counter we already hold; refetch if we don't have one yet.
      final current = state.counter;
      final updatedCounter = current == null
          ? await agentRepository.getCounter()
          : current.copyWith(
              status: json['status'] as String?,
              paused: json['paused'] as bool?,
              enabled: json['enabled'] as bool?,
            );
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

      SessionManager.saveCounterName(counter.name);
      SessionManager.saveCounterCode(counter.code);

      final (upcomingToken, holdToken, noShowToken) = _splitQueue(queue);

      emit(
        HomeState(
          status: HomeStatus.loaded,
          currentTokenStatus: activeToken?.id != null
              ? CurrentTokenStatus.loaded
              : CurrentTokenStatus.initial,
          counter: counter,
          queue: upcomingToken,
          holdQueue: holdToken,
          noShowQueue: noShowToken,
          recentServices: recentServices,
          currentToken: activeToken,
          allCounter: allCounter,
          transferReasons: state.transferReasons,
          isNetworkConnected: state.isNetworkConnected,
          connectivityStatus: state.connectivityStatus,
          webSocketStatus: WebSocketService.isConnected
              ? WebSocketStatus.connected
              : WebSocketStatus.error,
          webSocketErrorMessage: state.webSocketErrorMessage,
        ),
      );
      refreshTransferReasons();
    } catch (e) {
      debugPrint('Error loading data: $e');

      // The login was rejected (expired, signed out by the daily sign-out, or
      // replaced by a login elsewhere): ApiClient has already said so and
      // gone to the login page, so don't add an "An error occurred" toast.
      if (ApiClient.sessionEnded) {
        emit(state.copyWith(status: HomeStatus.initial));
        return;
      }

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
      final (upcomingToken, holdToken, noShowToken) = _splitQueue(queue);

      emit(
        state.copyWith(
          queue: upcomingToken,
          holdQueue: holdToken,
          noShowQueue: noShowToken,
        ),
      );
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
    } on ApiErrorShown {
      // ApiClient already showed the backend's reason (e.g. a 409).
    } catch (e) {
      flutterToast(
        message: 'Failed to call token. Please try again.',
        color: AppColors.darkRed,
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Calls back a no-show visitor who has returned.
  Future<void> callNoShowToken(String tokenId) =>
      _callSpecificToken(() => agentRepository.callNoShowToken(tokenId));

  Future<void> callTransferredToken(String tokenId) =>
      _callSpecificToken(() => agentRepository.callTransferredToken(tokenId));

  Future<void> _callSpecificToken(Future<TokenModel> Function() call) async {
    if (!state.isNetworkConnected) {
      flutterToast(message: 'No internet connection', color: AppColors.darkRed);
      return;
    }

    try {
      customLoader();

      final token = await call();
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          currentToken: token,
          currentTokenStatus: CurrentTokenStatus.loaded,
        ),
      );

      startCompleteButtonTimer();
    } on ApiErrorShown {
      // ApiClient already showed the backend's reason (e.g. a 409).
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
      final note = _noteTokenId == tokenId ? _note.trim() : '';
      await agentRepository.completeToken(
        tokenId,
        note: note.isEmpty ? null : note,
      );
      _note = '';
      _noteTokenId = null;
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
    } on ApiErrorShown {
      // ApiClient already showed the backend's reason (e.g. a 409).
    } catch (e) {
      flutterToast(
        message: 'Failed to recall token. Please try again.',
        color: AppColors.darkRed,
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Loads the transfer reasons the admin set up. Returns null (keeping the
  /// old list) when the call fails, e.g. on a backend without the endpoint.
  Future<List<TransferReasonModel>?> refreshTransferReasons() async {
    try {
      final reasons = await agentRepository.getTransferReasons();
      if (!isClosed) emit(state.copyWith(transferReasons: reasons));
      return reasons;
    } catch (e) {
      debugPrint('Error loading transfer reasons: $e');
      return null;
    }
  }

  /// Re-fetches every counter with who is logged into it, for the transfer
  /// dialog. Returns null (keeping the old list) when the call fails.
  Future<List<CounterModel>?> refreshAllCounters() async {
    try {
      final allCounter = await agentRepository.getAllCounters();
      if (!isClosed) emit(state.copyWith(allCounter: allCounter));
      return allCounter;
    } catch (e) {
      debugPrint('Error refreshing counters: $e');
      return null;
    }
  }

  Future<void> transferToken(String counterId, String reason) async {
    // Check network
    if (!state.isNetworkConnected) {
      flutterToast(message: 'No internet connection', color: AppColors.darkRed);
      return;
    }

    try {
      customLoader();

      final tokenId = state.currentToken!.id;
      await agentRepository.transferToken(tokenId, counterId, reason);

      // Cancel timer and reset state
      cancelCompleteButtonTimer();

      emit(
        state.copyWith(
          currentTokenStatus: CurrentTokenStatus.initial,
          currentToken: TokenModel(),
          counter: await agentRepository.getCounter(),
        ),
      );

      flutterToast(message: 'Token successfully transferred');
    } on ApiErrorShown {
      // ApiClient already showed the backend's reason (e.g. a 409).
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
    } on ApiErrorShown {
      // ApiClient already showed the backend's reason (e.g. a 409).
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
    } on ApiErrorShown {
      // ApiClient already showed the backend's reason (e.g. a 409).
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
        final (upcomingToken, holdToken, noShowToken) = _splitQueue(
          updatedQueue,
        );

        emit(
          state.copyWith(
            queue: upcomingToken,
            holdQueue: holdToken,
            noShowQueue: noShowToken,
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

  /// Toggle the agent's serving/break status — pauses or resumes the counter.
  Future<void> toggleServingStatus(bool value) async {
    // Check network
    if (!state.isNetworkConnected) {
      flutterToast(message: 'No internet connection', color: AppColors.darkRed);
      return;
    }

    try {
      final updatedCounter = value
          ? await agentRepository.resumeCounter()
          : await agentRepository.pauseCounter();

      if (updatedCounter == null) return;

      emit(state.copyWith(counter: updatedCounter));
      flutterToast(
        message: value ? 'You are now serving' : 'You are now on break',
      );
    } catch (e) {
      debugPrint('Error updating serving status: $e');
      flutterToast(
        message: 'Failed to update status. Please try again.',
        color: AppColors.darkRed,
      );
    }
  }

  /// Logout: closes the counter on the backend, then clears local session.
  /// Returns true on success so the UI can decide whether to navigate.
  /// If the backend refuses (e.g. a token is still in progress) the session is
  /// kept: clearing it would leave the counter held by this agent with no way
  /// back in from the login page.
  Future<bool> logout() async {
    if (state.isNetworkConnected) {
      final released = await agentRepository.logoutCounter();
      if (!released) return false;
    }
    SessionManager.clearSession();
    return true;
  }

  @override
  Future<void> close() {
    _completeButtonTimer?.cancel();
    _feedbackWatchTimer?.cancel();
    _connectivitySubscription.cancel();
    WebSocketService.disconnect();
    return super.close();
  }
}
