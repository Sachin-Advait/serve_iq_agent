part of 'quiz_cubit.dart';

@immutable
sealed class QuizState {}

final class QuizInitial extends QuizState {}

final class QuizLoading extends QuizState {}

final class QuizLoaded extends QuizState {
  final List<QuizzesSummary> quizzes;
  final List<QuizzesSummary> filtered;
  final String? searchQuery;
  final String? selectedStatus;
  final String? selectedType;
  final String? selectedSort;
  final String? selectedParticipation;
  final DateTime? selectedDate;

  QuizLoaded({
    required this.quizzes,
    required this.filtered,
    this.searchQuery,
    this.selectedStatus,
    this.selectedType,
    this.selectedSort,
    this.selectedParticipation,
    this.selectedDate,
  });

  QuizLoaded copyWith({
    List<QuizzesSummary>? quizzes,
    List<QuizzesSummary>? filtered,
    String? searchQuery,
    String? selectedStatus,
    String? selectedType,
    String? selectedSort,
    String? selectedParticipation,
    DateTime? selectedDate,
  }) {
    return QuizLoaded(
      quizzes: quizzes ?? this.quizzes,
      filtered: filtered ?? this.filtered,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedType: selectedType ?? this.selectedType,
      selectedSort: selectedSort ?? this.selectedSort,
      selectedParticipation:
          selectedParticipation ?? this.selectedParticipation,
      selectedDate: selectedDate,
    );
  }
}

final class QuizError extends QuizState {
  final String message;
  QuizError(this.message);
}
