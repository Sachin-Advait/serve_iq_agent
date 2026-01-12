import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:servelq_agent/common/constants/api_constants.dart';
import 'package:servelq_agent/common/utils/get_it.dart';
import 'package:servelq_agent/common/widgets/custom_loader.dart';
import 'package:servelq_agent/models/quiz_details_model.dart';
import 'package:servelq_agent/models/submit_quiz_model.dart';
import 'package:servelq_agent/services/api_client.dart';
import 'package:servelq_agent/services/session_manager.dart';

part 'participate_state.dart';

class ParticipateCubit extends Cubit<ParticipateState> {
  ParticipateCubit() : super(ParticipateInitial());

  final ApiClient apiClient = getIt<ApiClient>();

  Timer? _timer;
  late DateTime _quizStartTime;

  int timeLeft = 0;
  QuizDetails? quizSurveyData;

  /// Fetch quiz details
  Future<void> getQuizSurveyDetails(String quizId) async {
    emit(ParticipateLoading());

    try {
      final response = await apiClient.getApi('${ApiConstants.quiz}/$quizId');

      if (response != null && response.statusCode == 200) {
        final responseData = QuizDetailsModel.fromJson(response.data);
        quizSurveyData = responseData.data;
        _emitProgress();
        startQuiz(quizSurveyData?.quizDuration ?? '10', quizId);
      } else {
        emit(ParticipateValidationError("Failed to load quiz details"));
      }
    } catch (err) {
      emit(ParticipateValidationError("Failed to fetch quiz: $err"));
    }
  }

  void startQuiz(String quizDuration, String quizId) {
    final durationMinutes = int.tryParse(quizDuration) ?? 10;
    final totalSeconds = durationMinutes * 60;

    final savedStartTime = SessionManager.getQuizStartTime(quizId);

    if (savedStartTime == null) {
      _quizStartTime = DateTime.now();
      SessionManager.saveQuizStartTime(quizId, _quizStartTime);
    } else {
      _quizStartTime = savedStartTime;
    }

    void updateTime() {
      final elapsed = DateTime.now().difference(_quizStartTime).inSeconds;
      timeLeft = totalSeconds - elapsed;

      if (timeLeft <= 0) {
        timeLeft = 0;
        submitAllAnswers(quizId, {}, {});
      } else {
        _emitProgress();
      }
    }

    updateTime();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => updateTime());
  }

  /// Submit all answers at once (for web list view)
  Future<void> submitAllAnswers(
    String quizId,
    Map<String, dynamic> answers,
    Map<String, TextEditingController> textControllers,
  ) async {
    try {
      _timer?.cancel();
      customLoader();

      if (quizSurveyData == null) {
        emit(ParticipateValidationError("Quiz data not loaded"));
        return;
      }

      final questions = quizSurveyData!.definitionJson.pages[0].elements;
      final isSurvey = quizSurveyData!.type.toLowerCase() == "survey";

      // Validate for surveys - all questions must be answered
      if (isSurvey) {
        for (final question in questions) {
          if (!answers.containsKey(question.name) ||
              answers[question.name] == null) {
            EasyLoading.dismiss();
            emit(
              ParticipateValidationError(
                "Please answer all questions before submitting",
              ),
            );
            _emitProgress();
            return;
          }

          // Check for empty text answers
          if (question.type == "text" || question.type == "comment") {
            final textAnswer = textControllers[question.name]?.text ?? '';
            if (textAnswer.trim().isEmpty) {
              EasyLoading.dismiss();
              emit(
                ParticipateValidationError(
                  "Please answer all questions before submitting",
                ),
              );
              _emitProgress();
              return;
            }
          }
        }
      }

      // Build the final answers map
      final Map<String, dynamic> finalAnswers = {};

      for (final question in questions) {
        final answer = answers[question.name];

        // Skip unanswered questions for quizzes (not surveys)
        if (answer == null && !isSurvey) {
          continue;
        }

        // Format the answer based on question type
        if (question.type == "text" || question.type == "comment") {
          finalAnswers[question.name] =
              textControllers[question.name]?.text ?? '';
        } else if (question.type == "checkbox") {
          // Convert list to comma-separated string or keep as list based on your API
          finalAnswers[question.name] =
              (answer as List<String>?)?.join(',') ?? '';
        } else if (question.type == "rating") {
          finalAnswers[question.name] = (answer as double?)?.toString() ?? '0';
        } else if (question.type == "boolean") {
          if (isSurvey) {
            finalAnswers[question.name] = (answer as bool?) == true
                ? "Yes"
                : "No";
          } else {
            finalAnswers[question.name] = answer?.toString() ?? '';
          }
        } else {
          finalAnswers[question.name] = answer?.toString() ?? '';
        }
      }

      // Calculate elapsed time
      final elapsed = DateTime.now().difference(_quizStartTime);

      // Submit to API
      final response = await apiClient.postApi(
        '${ApiConstants.submit}$quizId',
        body: {
          "userId": SessionManager.getUserId(),
          "finishTime": elapsed.inSeconds,
          "answers": finalAnswers,
        },
      );

      if (response != null && response.statusCode == 200) {
        final responseData = SubmitQuizModel.fromJson(response.data);
        await SessionManager.clearQuizStartTime(quizId);

        emit(ParticipateSubmitted(submitQuizDetails: responseData.data));
      } else {
        emit(
          ParticipateValidationError(
            "Failed to submit quiz. Please try again.",
          ),
        );
        _emitProgress();
      }
    } catch (e) {
      emit(
        ParticipateValidationError("Error submitting quiz: ${e.toString()}"),
      );
      _emitProgress();
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _emitProgress() {
    emit(
      ParticipateInProgress(timeLeft: timeLeft, quizDetails: quizSurveyData),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
