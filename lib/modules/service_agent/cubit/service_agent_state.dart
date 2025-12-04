part of 'service_agent_cubit.dart';

enum ServiceAgentStatus { initial, loading, loaded, error }

enum CurrentTokenStatus { initial, loading, loaded, error }

@immutable
class ServiceAgentState {
  final ServiceAgentStatus status;
  final CurrentTokenStatus currentTokenStatus;
  final List<TokenModel> queue;
  final List<ServiceHistory> recentServices;
  final TokenModel? currentToken;
  final CounterModel? counter;
  final List<CounterModel> allCounter;
  final bool showReview;
  final String? errorMessage;

  const ServiceAgentState({
    this.status = ServiceAgentStatus.initial,
    this.currentTokenStatus = CurrentTokenStatus.initial,
    this.queue = const [],
    this.recentServices = const [],
    this.currentToken,
    this.counter,
    this.allCounter = const [],
    this.showReview = false,
    this.errorMessage,
  });

  ServiceAgentState copyWith({
    ServiceAgentStatus? status,
    CurrentTokenStatus? currentTokenStatus,
    List<TokenModel>? queue,
    List<ServiceHistory>? recentServices,
    TokenModel? currentToken,
    CounterModel? counter,
    List<CounterModel>? allCounter,
    bool? showReview,
    String? errorMessage,
  }) {
    return ServiceAgentState(
      status: status ?? this.status,
      currentTokenStatus: currentTokenStatus ?? this.currentTokenStatus,
      queue: queue ?? this.queue,
      recentServices: recentServices ?? this.recentServices,
      currentToken: currentToken ?? this.currentToken,
      counter: counter ?? this.counter,
      allCounter: allCounter ?? this.allCounter,
      showReview: showReview ?? this.showReview,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
