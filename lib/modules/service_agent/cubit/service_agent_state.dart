part of 'service_agent_cubit.dart';

class ServiceAgent {
  final Token? currentToken;
  final List<Token> queue;
  final List<ServiceHistory> history;
  final bool isPaused;

  ServiceAgent({
    this.currentToken,
    required this.queue,
    required this.history,
    this.isPaused = false,
  });

  ServiceAgent copyWith({
    Token? currentToken,
    List<Token>? queue,
    List<ServiceHistory>? history,
    bool? isPaused,
  }) {
    return ServiceAgent(
      currentToken: currentToken ?? this.currentToken,
      queue: queue ?? this.queue,
      history: history ?? this.history,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}
