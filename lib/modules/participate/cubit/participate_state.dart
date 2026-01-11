part of 'participate_cubit.dart';

@immutable
sealed class ParticipateState {}

class ParticipateInitial extends ParticipateState {}

class ParticipateLoading extends ParticipateState {}

class ParticipateInProgress extends ParticipateState {
  final int currentIndex;
  final int timeLeft;
  final Map<String, dynamic> userAnswers;
  final dynamic selectedAnswer;
  final QuizDetails? quizDetails;

  ParticipateInProgress({
    required this.currentIndex,
    required this.timeLeft,
    required this.userAnswers,
    this.selectedAnswer,
    this.quizDetails,
  });
}

class ParticipateSubmitted extends ParticipateState {
  final SubmitQuizDetails submitQuizDetails;

  ParticipateSubmitted({required this.submitQuizDetails});
}

class ParticipateValidationError extends ParticipateState {
  final String message;
  ParticipateValidationError(this.message);
}

class ParticipateAPIError extends ParticipateState {}
