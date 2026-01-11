import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/common/constants/api_constants.dart';
import 'package:servelq_agent/common/utils/get_it.dart';
import 'package:servelq_agent/models/quiz_result_model.dart';
import 'package:servelq_agent/models/top_scorers_model.dart';
import 'package:servelq_agent/services/api_client.dart';

part 'quiz_result_event.dart';
part 'quiz_result_state.dart';

class QuizResultBloc extends Bloc<QuizResultEvent, QuizResultState> {
  QuizResultBloc() : super(QuizResultsInitial()) {
    on<LoadQuizResults>(_onLoadQuizResults);
  }

  final ApiClient apiClient = getIt<ApiClient>();

  Future<void> _onLoadQuizResults(
    LoadQuizResults event,
    Emitter<QuizResultState> emit,
  ) async {
    // try {
    emit(QuizResultsLoading());

    final response = await apiClient.getApi(
      '${ApiConstants.result}${event.quizId}',
      queryParameters: {"userId": event.userId},
    );

    final topResponse = await apiClient.getApi(
      '${ApiConstants.topScorer}${event.quizId}',
    );

    if (response != null && response.statusCode == 200 && topResponse != null) {
      final resultResponse = QuizResultModel.fromJson(response.data);
      final topScorerResponse = TopScorersModel.fromJson(topResponse.data);
      emit(
        QuizResultsLoaded(
          result: resultResponse.data!,
          leaderboard: topScorerResponse.data!,
        ),
      );
    }
    // } catch (e) {
    //   emit(QuizResultsError("Failed to load results"));
    // }
  }
}
