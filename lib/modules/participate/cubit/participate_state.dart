part of 'participate_cubit.dart';

@immutable
abstract class ParticipateState {}

class ParticipateInitial extends ParticipateState {}

class ParticipateLoading extends ParticipateState {}

class ParticipateInProgress extends ParticipateState {
  final int timeLeft;
  final QuizDetails? quizDetails;

  ParticipateInProgress({required this.timeLeft, this.quizDetails});
}

class ParticipateValidationError extends ParticipateState {
  final String message;

  ParticipateValidationError(this.message);
}

class ParticipateAPIError extends ParticipateState {}

class ParticipateSubmitted extends ParticipateState {
  final SubmitQuizDetails submitQuizDetails;

  ParticipateSubmitted({required this.submitQuizDetails});
}
