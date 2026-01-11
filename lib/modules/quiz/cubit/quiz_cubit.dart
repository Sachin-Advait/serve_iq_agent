import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/common/constants/api_constants.dart';
import 'package:servelq_agent/common/utils/get_it.dart';
import 'package:servelq_agent/models/quiz_model.dart';
import 'package:servelq_agent/services/api_client.dart';

part 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit() : super(QuizInitial());

  final ApiClient apiClient = getIt<ApiClient>();

  Future<void> getQuizzes() async {
    emit(QuizLoading());
    final response = await apiClient.getApi(ApiConstants.quiz);
    if (response != null && response.statusCode == 200) {
      final responseData = QuizModel.fromJson(response.data);

      emit(
        QuizLoaded(
          quizzes: responseData.data.content,
          filtered: responseData.data.content,
        ),
      );
    }
  }

  void _applyFilters(QuizLoaded current) {
    var filtered = current.quizzes;

    // 🔎 Search filter
    if (current.searchQuery != null && current.searchQuery!.isNotEmpty) {
      filtered = filtered
          .where(
            (quiz) => quiz.title.toLowerCase().contains(
              current.searchQuery!.toLowerCase(),
            ),
          )
          .toList();
    }

    // 📌 Status filter
    if (current.selectedStatus != null &&
        current.selectedStatus != "All Status") {
      filtered = filtered
          .where((q) => q.statusString == (current.selectedStatus))
          .toList();
    }

    // 📌 Type filter
    if (current.selectedType != null && current.selectedType != "All Types") {
      filtered = filtered.where((q) => q.type == current.selectedType).toList();
    }

    // 📌 Participation filter
    if (current.selectedParticipation != null &&
        current.selectedParticipation != "All") {
      filtered = filtered
          .where(
            (q) => current.selectedParticipation == "Participated"
                ? q.isParticipated == true
                : q.isParticipated == false,
          )
          .toList();
    }

    // 📌 Date filter
    if (current.selectedDate != null) {
      filtered = filtered
          .where(
            (q) =>
                q.createdAt.year == current.selectedDate!.year &&
                q.createdAt.month == current.selectedDate!.month &&
                q.createdAt.day == current.selectedDate!.day,
          )
          .toList();
    }

    // 📌 Sort
    if (current.selectedSort != null) {
      if (current.selectedSort == "Latest") {
        filtered = [...filtered]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (current.selectedSort == "Oldest") {
        filtered = [...filtered]
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }
    }

    emit(current.copyWith(filtered: filtered));
  }

  void search(String query) {
    if (state is QuizLoaded) {
      final current = state as QuizLoaded;
      final updated = current.copyWith(searchQuery: query);
      _applyFilters(updated);
    }
  }

  void setFilter({
    String? status,
    String? type,
    String? sort,
    String? participation,
    DateTime? date,
  }) {
    if (state is QuizLoaded) {
      final current = state as QuizLoaded;

      // local filtering logic (until API integration is added)
      var filtered = current.quizzes;

      if (status != null && status != "All Status") {
        filtered = filtered.where((q) => q.statusString == status).toList();
      }
      if (type != null && type != "All Types") {
        filtered = filtered.where((q) => q.type == type).toList();
      }
      if (participation != null && participation != "All") {
        filtered = filtered
            .where(
              (q) => participation == "Participated"
                  ? q.isParticipated == true
                  : q.isParticipated == false,
            )
            .toList();
      }
      if (sort != null) {
        if (sort == "Latest") {
          filtered = [...filtered]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          filtered = [...filtered]
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }
      }
      // date filter (example)
      if (date != null) {
        filtered = filtered
            .where(
              (q) =>
                  q.createdAt.year == date.year &&
                  q.createdAt.month == date.month &&
                  q.createdAt.day == date.day,
            )
            .toList();
      }

      emit(
        current.copyWith(
          filtered: filtered,
          selectedStatus: status ?? current.selectedStatus,
          selectedType: type ?? current.selectedType,
          selectedSort: sort ?? current.selectedSort,
          selectedParticipation: participation ?? current.selectedParticipation,
          selectedDate: date ?? current.selectedDate,
        ),
      );
    }
  }

  /// Reset filters
  void resetFilters() {
    if (state is QuizLoaded) {
      final current = state as QuizLoaded;
      final reset = current.copyWith(
        searchQuery: "",
        selectedStatus: "All Status",
        selectedType: "All Types",
        selectedSort: "Sort by",
        selectedParticipation: "All",
        selectedDate: null,
      );
      _applyFilters(reset);
    }
  }
}
