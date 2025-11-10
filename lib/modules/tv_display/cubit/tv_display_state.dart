part of 'tv_display_cubit.dart';

abstract class TVDisplayState {
  const TVDisplayState();
}

class TVDisplayInitial extends TVDisplayState {}

class TVDisplayLoading extends TVDisplayState {}

class TVDisplayLoaded extends TVDisplayState {
  final List<DisplayToken> latestCalls;
  final List<DisplayToken> nowServing;
  final List<String> upcomingTokens;
  final String? branchName;

  const TVDisplayLoaded({
    required this.latestCalls,
    required this.nowServing,
    required this.upcomingTokens,
    this.branchName,
  });
}

class TVDisplayError extends TVDisplayState {
  final String message;

  const TVDisplayError(this.message);
}
