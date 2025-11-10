part of 'service_agent_cubit.dart';

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

  const ServiceAgentLoaded({
    required this.queue,
    required this.recentServices,
    this.currentToken,
    required this.counter,
    required this.allCounter,
  });
}

class ServiceAgentError extends ServiceAgentState {
  final String message;

  const ServiceAgentError(this.message);
}
