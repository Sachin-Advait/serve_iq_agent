part of 'login_bloc.dart';

class LoginState extends Equatable {
  const LoginState({
    this.counters = const [],
    this.loadingCounters = true,
    this.selectedCounterId,
    this.submitting = false,
    this.user,
    this.errorMessage,
  });

  final List<CounterOption> counters;
  final bool loadingCounters;
  final String? selectedCounterId;
  final bool submitting;
  final UserModel? user;
  final String? errorMessage;

  CounterOption? get selectedCounter =>
      counters.where((c) => c.id == selectedCounterId).firstOrNull;

  LoginState copyWith({
    List<CounterOption>? counters,
    bool? loadingCounters,
    String? selectedCounterId,
    bool clearSelection = false,
    bool? submitting,
    UserModel? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      counters: counters ?? this.counters,
      loadingCounters: loadingCounters ?? this.loadingCounters,
      selectedCounterId: clearSelection
          ? null
          : (selectedCounterId ?? this.selectedCounterId),
      submitting: submitting ?? this.submitting,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    counters,
    loadingCounters,
    selectedCounterId,
    submitting,
    user,
    errorMessage,
  ];
}
