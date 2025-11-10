import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:servelq_agent/models/user_model.dart';
import 'package:servelq_agent/modules/login/repository/auth_repo.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc(this.authRepository) : super(LoginInitial()) {
    on<AgentLogin>(_onAgentLogin);
    on<TVDisplayLogin>(_onTVDisplayLogin);
  }

  Future<void> _onAgentLogin(AgentLogin event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final user = await authRepository.login(
        username: event.email,
        password: event.password,
        userType: 'agent',
      );
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }

  Future<void> _onTVDisplayLogin(
    TVDisplayLogin event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final user = await authRepository.login(
        username: event.email,
        password: event.password,
        userType: 'display',
      );
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
