part of 'service_agent_cubit.dart';

class ServiceAgent {
  final Token? currentToken;
  final List<Token> queue;
  final List<ServiceHistory> history;

  ServiceAgent({this.currentToken, required this.queue, required this.history});

  ServiceAgent copyWith({
    Token? currentToken,
    List<Token>? queue,
    List<ServiceHistory>? history,
  }) {
    return ServiceAgent(
      currentToken: currentToken,
      queue: queue ?? this.queue,
      history: history ?? this.history,
    );
  }
}
