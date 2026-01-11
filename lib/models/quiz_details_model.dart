class QuizSurveyResponse {
  final bool success;
  final String message;
  final QuizDetails? data;

  QuizSurveyResponse({required this.success, required this.message, this.data});

  factory QuizSurveyResponse.fromJson(Map<String, dynamic> json) {
    return QuizSurveyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? QuizDetails.fromJson(json['data']) : null,
    );
  }
}

class QuizDetails {
  final String id;
  final String type;
  final String title;
  final DefinitionJson definitionJson;
  final Map<String, dynamic>? answerKey;
  final int? maxScore;
  final String? quizDuration;
  final bool? isMandatory;
  final bool? isParticipated;
  final DateTime createdAt;
  final int? maxRetake;

  QuizDetails({
    required this.id,
    required this.type,
    required this.title,
    required this.definitionJson,
    this.answerKey,
    this.maxScore,
    this.quizDuration,
    this.isMandatory,
    this.isParticipated,
    required this.createdAt,
    this.maxRetake,
  });

  factory QuizDetails.fromJson(Map<String, dynamic> json) {
    return QuizDetails(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      definitionJson: DefinitionJson.fromJson(json['definitionJson']),
      answerKey: json['answerKey'] != null
          ? Map<String, dynamic>.from(json['answerKey'])
          : null,
      maxScore: json['maxScore'],
      quizDuration: json['quizDuration'],
      isMandatory: json['isMandatory'],
      isParticipated: json['isParticipated'],
      createdAt: DateTime.parse(json['createdAt']),
      maxRetake: json['maxRetake'],
    );
  }
}

class DefinitionJson {
  final List<PageElement> pages;

  DefinitionJson({required this.pages});

  factory DefinitionJson.fromJson(Map<String, dynamic> json) {
    return DefinitionJson(
      pages: (json['pages'] as List<dynamic>)
          .map((e) => PageElement.fromJson(e))
          .toList(),
    );
  }
}

class PageElement {
  final List<QuestionElement> elements;

  PageElement({required this.elements});

  factory PageElement.fromJson(Map<String, dynamic> json) {
    return PageElement(
      elements: (json['elements'] as List<dynamic>)
          .map((e) => QuestionElement.fromJson(e))
          .toList(),
    );
  }
}

/// Question definition
class QuestionElement {
  final String
  type; // radiogroup, checkbox, text, comment, dropdown, rating, boolean
  final String name;
  final String title;
  final List<String>? choices;
  final dynamic correctAnswer;

  QuestionElement({
    required this.type,
    required this.name,
    required this.title,
    this.choices,
    this.correctAnswer,
  });

  factory QuestionElement.fromJson(Map<String, dynamic> json) {
    return QuestionElement(
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      choices: json['choices'] != null
          ? List<String>.from(json['choices'])
          : null,
      correctAnswer: json['correctAnswer'],
    );
  }
}
