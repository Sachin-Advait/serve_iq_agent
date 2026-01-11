part of 'quiz_result_bloc.dart';

@immutable
sealed class QuizResultEvent {}

class LoadQuizResults extends QuizResultEvent {
  final String quizId;
  final String userId;

  LoadQuizResults({required this.quizId, required this.userId});
}

class LoadLeaderboard extends QuizResultEvent {}
