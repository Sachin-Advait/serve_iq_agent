part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoadCounters extends LoginEvent {
  const LoadCounters();
}

class SelectCounter extends LoginEvent {
  const SelectCounter(this.counterId);
  final String counterId;
  @override
  List<Object?> get props => [counterId];
}

class AgentLogin extends LoginEvent {
  const AgentLogin({required this.email, required this.password});
  final String email, password;
  @override
  List<Object?> get props => [email, password];
}
