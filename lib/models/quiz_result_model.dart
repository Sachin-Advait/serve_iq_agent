class QuizResultModel {
  final bool? success;
  final String? message;
  final QuizResultDetails? data;

  QuizResultModel({this.success, this.message, this.data});

  factory QuizResultModel.fromJson(Map<String, dynamic> json) =>
      QuizResultModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : QuizResultDetails.fromJson(json["data"]),
      );
}

class QuizResultDetails {
  final String id;
  final String username;
  final int score;
  final int maxScore;
  final DateTime submittedAt;
  final String finishTime;
  final Map<String, QuizAnswer> answers;

  QuizResultDetails({
    required this.id,
    required this.username,
    required this.score,
    required this.maxScore,
    required this.submittedAt,
    required this.finishTime,
    required this.answers,
  });

  factory QuizResultDetails.fromJson(Map<String, dynamic> json) {
    return QuizResultDetails(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      maxScore: (json['maxScore'] as num?)?.toInt() ?? 0,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : DateTime.now(),
      finishTime: json['finishTime'] ?? '',
      answers: (json['answers'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, QuizAnswer.fromJson(value)),
      ),
    );
  }
}

class QuizAnswer {
  final List<QuizChoice> choices;
  final String type;
  final String arabicTitle;
  final dynamic selectedOptions;
  final String? correctAnswer;
  final int? mark;

  QuizAnswer({
    required this.choices,
    required this.type,
    required this.arabicTitle,
    this.selectedOptions,
    this.correctAnswer,
    this.mark,
  });

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      choices: (json['choices'] as List? ?? [])
          .map((choice) => QuizChoice.fromJson(choice))
          .toList(),
      type: json['type'] ?? '',
      arabicTitle: json['arabicTitle'] ?? '',
      selectedOptions: json['selectedOptions'],
      correctAnswer: json['correctAnswer'],
      mark: json['mark'],
    );
  }
}

class QuizChoice {
  final String text;
  final bool isSelect;

  QuizChoice({required this.text, required this.isSelect});

  factory QuizChoice.fromJson(Map<String, dynamic> json) {
    return QuizChoice(
      text: json['text'] ?? '',
      isSelect: json['isSelect'] ?? json['correct'] ?? false,
    );
  }
}
