class SubmitQuizModel {
  final bool success;
  final String message;
  final SubmitQuizDetails data;

  SubmitQuizModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SubmitQuizModel.fromJson(Map<String, dynamic> json) {
    return SubmitQuizModel(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      data: SubmitQuizDetails.fromJson(json['data']),
    );
  }
}

class SubmitQuizDetails {
  final String id;
  final String quizSurveyId;
  final String userId;
  final String username;
  final Map<String, dynamic> answers;
  final int score;
  final int maxScore;
  final String finishTime; // e.g. "PT1H"
  final DateTime submittedAt;

  SubmitQuizDetails({
    required this.id,
    required this.quizSurveyId,
    required this.userId,
    required this.username,
    required this.answers,
    required this.score,
    required this.maxScore,
    required this.finishTime,
    required this.submittedAt,
  });

  factory SubmitQuizDetails.fromJson(Map<String, dynamic> json) {
    return SubmitQuizDetails(
      id: json['id'],
      quizSurveyId: json['quizSurveyId'],
      userId: json['userId'],
      username: json['username'],
      answers: Map<String, dynamic>.from(json['answers']),
      score: json['score'] ?? 0,
      maxScore: json['maxScore'] ?? 0,
      finishTime: json['finishTime'] ?? "",
      submittedAt: DateTime.parse(json['submittedAt']),
    );
  }
}
