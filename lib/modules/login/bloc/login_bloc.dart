import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:servelq_agent/models/counter_option.dart';
import 'package:servelq_agent/models/user_model.dart';
import 'package:servelq_agent/modules/login/repository/auth_repo.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this.authRepository) : super(const LoginState()) {
    on<LoadCounters>(_onLoadCounters);
    on<SelectCounter>(_onSelectCounter);
    on<AgentLogin>(_onAgentLogin);
  }

  final AuthRepository authRepository;

  Future<void> _onLoadCounters(
    LoadCounters event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(loadingCounters: true));
    try {
      final counters = await authRepository.fetchCounters();
      final stillValid =
          state.selectedCounterId != null &&
          counters.any((c) => c.id == state.selectedCounterId);
      emit(
        state.copyWith(
          counters: counters,
          loadingCounters: false,
          clearSelection: !stillValid,
        ),
      );
    } catch (_) {
      emit(state.copyWith(counters: const [], loadingCounters: false));
    }
  }

  void _onSelectCounter(SelectCounter event, Emitter<LoginState> emit) {
    emit(state.copyWith(selectedCounterId: event.counterId));
  }

  Future<void> _onAgentLogin(AgentLogin event, Emitter<LoginState> emit) async {
    final counterId = state.selectedCounterId;
    if (counterId == null) {
      emit(state.copyWith(errorMessage: 'Please select a counter'));
      return;
    }
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      final user = await authRepository.login(
        username: event.email,
        password: event.password,
        counterId: counterId,
      );
     
      emit(state.copyWith(submitting: false, user: user));
    } catch (e) {
      emit(
        state.copyWith(
          submitting: false,
          errorMessage: e is LoginErrorShown ? null : e.toString(),
        ),
      );
      add(const LoadCounters());
    }
  }
}
