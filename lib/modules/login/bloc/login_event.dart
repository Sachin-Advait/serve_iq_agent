part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class AgentLogin extends LoginEvent {
  final String email;
  final String password;

  const AgentLogin({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class TVDisplayLogin extends LoginEvent {
  final String email;
  final String password;

  const TVDisplayLogin({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}