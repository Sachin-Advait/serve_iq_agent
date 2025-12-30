// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'service_agent_cubit.dart';

enum ServiceAgentStatus { initial, loading, loaded, error }

enum CurrentTokenStatus { initial, loading, loaded, error }

@immutable
class ServiceAgentState {
  final ServiceAgentStatus status;
  final CurrentTokenStatus currentTokenStatus;
  final List<TokenModel> queue;
  final List<TokenModel> holdQueue;
  final List<ServiceHistory> recentServices;
  final TokenModel? currentToken;
  final CounterModel? counter;
  final List<CounterModel> allCounter;
  final String? errorMessage;
  final int completeButtonRemainingSeconds;
  final bool isCompleteButtonDisabled;

  const ServiceAgentState({
    this.status = ServiceAgentStatus.initial,
    this.currentTokenStatus = CurrentTokenStatus.initial,
    this.queue = const [],
    this.holdQueue = const [],
    this.recentServices = const [],
    this.currentToken,
    this.counter,
    this.allCounter = const [],
    this.errorMessage,
    this.completeButtonRemainingSeconds = 0,
    this.isCompleteButtonDisabled = false,
  });

  ServiceAgentState copyWith({
    ServiceAgentStatus? status,
    CurrentTokenStatus? currentTokenStatus,
    List<TokenModel>? queue,
    List<TokenModel>? holdQueue,
    List<ServiceHistory>? recentServices,
    TokenModel? currentToken,
    CounterModel? counter,
    List<CounterModel>? allCounter,
    String? errorMessage,
    int? completeButtonRemainingSeconds,
    bool? isCompleteButtonDisabled,
  }) {
    return ServiceAgentState(
      status: status ?? this.status,
      currentTokenStatus: currentTokenStatus ?? this.currentTokenStatus,
      queue: queue ?? this.queue,
      holdQueue: holdQueue ?? this.holdQueue,
      recentServices: recentServices ?? this.recentServices,
      currentToken: currentToken ?? this.currentToken,
      counter: counter ?? this.counter,
      allCounter: allCounter ?? this.allCounter,
      errorMessage: errorMessage ?? this.errorMessage,
      completeButtonRemainingSeconds:
          completeButtonRemainingSeconds ?? this.completeButtonRemainingSeconds,
      isCompleteButtonDisabled:
          isCompleteButtonDisabled ?? this.isCompleteButtonDisabled,
    );
  }
}
