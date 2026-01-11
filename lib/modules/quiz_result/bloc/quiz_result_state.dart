part of 'quiz_result_bloc.dart';

@immutable
sealed class QuizResultState {}

class QuizResultsInitial extends QuizResultState {}

class QuizResultsLoading extends QuizResultState {}

class QuizResultsLoaded extends QuizResultState {
  final QuizResultDetails result;
  final TopScorersDetails leaderboard;
  QuizResultsLoaded({required this.result, required this.leaderboard});
}

class QuizResultsError extends QuizResultState {
  final String message;
  QuizResultsError(this.message);
}
