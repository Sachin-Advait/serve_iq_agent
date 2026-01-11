import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:servelq_agent/common/constants/api_constants.dart';
import 'package:servelq_agent/common/utils/get_it.dart';
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
  int currentIndex = 0;
  dynamic selectedAnswer;
  Map<String, dynamic> userAnswers = {};

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
        startQuiz(response.data!.quizDuration ?? '10', quizId);
      } else {
        emit(ParticipateValidationError("Failed to load quiz details"));
      }
    } catch (err) {
      emit(ParticipateValidationError("Failed to fetch quizzes: $err"));
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
        submitQuiz(quizId);
      } else {
        _emitProgress();
      }
    }

    updateTime();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => updateTime());
  }

  void nextQuestion(
    List<QuestionElement> questions,
    String quizSurveyId, {
    String? textAnswer,
  }) {
    final currentQ = questions[currentIndex];

    // Validation & save answer
    if (currentQ.type == "text" || currentQ.type == "comment") {
      if (textAnswer == null || textAnswer.trim().isEmpty) {
        emit(
          ParticipateValidationError("Please enter your answer or press Skip"),
        );
        return;
      }
      userAnswers[currentQ.name] = textAnswer.trim();
    } else {
      if (selectedAnswer == null) {
        emit(
          ParticipateValidationError("Please select an answer or press Skip"),
        );
        return;
      }
      userAnswers[currentQ.name] = selectedAnswer;
    }

    // Move to next or submit
    if (currentIndex < questions.length - 1) {
      currentIndex++;
      selectedAnswer = null;
      _emitProgress();
    } else {
      submitQuiz(quizSurveyId);
    }
  }

  void prevQuestion() {
    if (currentIndex > 0) {
      currentIndex--;
      selectedAnswer = null;
      _emitProgress();
    }
  }

  void skipQuestion(int total, String quizSurveyId) {
    if (currentIndex < total - 1) {
      currentIndex++;
      selectedAnswer = null;
      _emitProgress();
    } else {
      submitQuiz(quizSurveyId);
    }
  }

  void selectAnswer(dynamic choice) {
    selectedAnswer = choice;
    _emitProgress();
  }

  void toggleAnswer(String choice) {
    if (selectedAnswer == null || selectedAnswer is! List) {
      selectedAnswer = <String>[];
    }
    final list = List<String>.from(selectedAnswer as List);

    if (list.contains(choice)) {
      list.remove(choice);
    } else {
      list.add(choice);
    }
    selectedAnswer = list;

    _emitProgress();
  }

  Future<void> submitQuiz(String quizSurveyId) async {
    try {
      _timer?.cancel();
      EasyLoading.show();

      final elapsed = DateTime.now().difference(_quizStartTime);
      final finishTime = "PT${elapsed.inMinutes}M${elapsed.inSeconds % 60}S";

      final response = await apiClient.postApi(
        '${ApiConstants.submit}$quizSurveyId',
        body: {
          "userId": SessionManager.getUserId(),
          "finishTime": finishTime,
          "answers": userAnswers,
        },
      );

      if (response != null && response.statusCode == 200) {
        final responseData = SubmitQuizModel.fromJson(response.data);
        await SessionManager.clearQuizStartTime(quizSurveyId);

        emit(ParticipateSubmitted(submitQuizDetails: responseData.data));
      }
    } catch (e) {
      emit(ParticipateAPIError());
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _emitProgress() {
    emit(
      ParticipateInProgress(
        currentIndex: currentIndex,
        timeLeft: timeLeft,
        userAnswers: userAnswers,
        selectedAnswer: selectedAnswer,
        quizDetails: quizSurveyData,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
