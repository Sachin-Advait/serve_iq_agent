part of 'service_agent_cubit.dart';

@immutable
abstract class ServiceAgentState {
  const ServiceAgentState();
}

class ServiceAgentInitial extends ServiceAgentState {}

class ServiceAgentLoading extends ServiceAgentState {}

class ServiceAgentLoaded extends ServiceAgentState {
  final List<TokenModel> queue;
  final List<ServiceHistory> recentServices;
  final TokenModel? currentToken;
  final CounterModel counter;
  final List<CounterModel> allCounter;
  final bool showReview;

  const ServiceAgentLoaded({
    required this.queue,
    required this.recentServices,
    this.currentToken,
    required this.counter,
    required this.allCounter,
    required this.showReview,
  });

  ServiceAgentLoaded copyWith({
    List<TokenModel>? queue,
    List<ServiceHistory>? recentServices,
    TokenModel? currentToken,
    CounterModel? counter,
    List<CounterModel>? allCounter,
    bool? showReview,
  }) {
    return ServiceAgentLoaded(
      queue: queue ?? this.queue,
      recentServices: recentServices ?? this.recentServices,
      currentToken: currentToken ?? this.currentToken,
      counter: counter ?? this.counter,
      allCounter: allCounter ?? this.allCounter,
      showReview: showReview ?? this.showReview,
    );
  }
}

class ServiceAgentError extends ServiceAgentState {
  final String message;

  const ServiceAgentError(this.message);
}
