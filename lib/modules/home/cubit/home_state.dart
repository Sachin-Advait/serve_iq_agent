// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'home_cubit.dart';

enum HomeStatus { initial, loading, loaded, error, offline }

enum CurrentTokenStatus { initial, loaded }

enum WebSocketStatus { initial, connecting, connected, error, disconnected }

class HomeState {
  final HomeStatus status;
  final CurrentTokenStatus currentTokenStatus;
  final WebSocketStatus webSocketStatus;
  final String? webSocketErrorMessage;
  final CounterModel? counter;
  final List<TokenModel> queue;
  final List<TokenModel> holdQueue;
  final List<ServiceHistory> recentServices;
  final TokenModel? currentToken;
  final List<CounterModel> allCounter;
  final int completeButtonRemainingSeconds;
  final bool isCompleteButtonDisabled;
  final bool isNetworkConnected;
  final ConnectivityResult connectivityStatus;
  final bool wasNetworkRestored;

  const HomeState({
    this.status = HomeStatus.initial,
    this.currentTokenStatus = CurrentTokenStatus.initial,
    this.webSocketStatus = WebSocketStatus.initial,
    this.webSocketErrorMessage,
    this.counter,
    this.queue = const [],
    this.holdQueue = const [],
    this.recentServices = const [],
    this.currentToken,
    this.allCounter = const [],
    this.completeButtonRemainingSeconds = 0,
    this.isCompleteButtonDisabled = false,
    this.isNetworkConnected = true,
    this.connectivityStatus = ConnectivityResult.none,
    this.wasNetworkRestored = false,
  });

  HomeState copyWith({
    HomeStatus? status,
    CurrentTokenStatus? currentTokenStatus,
    WebSocketStatus? webSocketStatus,
    String? webSocketErrorMessage,
    CounterModel? counter,
    List<TokenModel>? queue,
    List<TokenModel>? holdQueue,
    List<ServiceHistory>? recentServices,
    TokenModel? currentToken,
    List<CounterModel>? allCounter,
    int? completeButtonRemainingSeconds,
    bool? isCompleteButtonDisabled,
    bool? isNetworkConnected,
    ConnectivityResult? connectivityStatus,
    bool? wasNetworkRestored,
  }) {
    return HomeState(
      status: status ?? this.status,
      currentTokenStatus: currentTokenStatus ?? this.currentTokenStatus,
      webSocketStatus: webSocketStatus ?? this.webSocketStatus,
      webSocketErrorMessage:
          webSocketErrorMessage ?? this.webSocketErrorMessage,
      counter: counter ?? this.counter,
      queue: queue ?? this.queue,
      holdQueue: holdQueue ?? this.holdQueue,
      recentServices: recentServices ?? this.recentServices,
      currentToken: currentToken ?? this.currentToken,
      allCounter: allCounter ?? this.allCounter,
      completeButtonRemainingSeconds:
          completeButtonRemainingSeconds ?? this.completeButtonRemainingSeconds,
      isCompleteButtonDisabled:
          isCompleteButtonDisabled ?? this.isCompleteButtonDisabled,
      isNetworkConnected: isNetworkConnected ?? this.isNetworkConnected,
      connectivityStatus: connectivityStatus ?? this.connectivityStatus,
      wasNetworkRestored: wasNetworkRestored ?? this.wasNetworkRestored,
    );
  }
}
