part of 'service_agent_cubit.dart';

enum ServiceAgentStatus { initial, loading, loaded, error }

enum CurrentTokenStatus { initial, loaded }

enum WebSocketStatus { initial, connecting, connected, error }

class ServiceAgentState {
  final ServiceAgentStatus status;
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

  const ServiceAgentState({
    this.status = ServiceAgentStatus.initial,
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
  });

  ServiceAgentState copyWith({
    ServiceAgentStatus? status,
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
  }) {
    return ServiceAgentState(
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
    );
  }
}
