class QuizModel {
  final bool success;
  final String message;
  final QuizPagination data;

  QuizModel({required this.success, required this.message, required this.data});

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      data: QuizPagination.fromMap(json["data"]),
    );
  }
}

class QuizPagination {
  final int pageNumber;
  final int totalElements;
  final int totalPages;
  final bool last;
  final List<QuizzesSummary> content;

  QuizPagination({
    required this.pageNumber,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.content,
  });

  factory QuizPagination.fromMap(Map<String, dynamic> map) {
    return QuizPagination(
      pageNumber: map['pageNumber'] as int,
      totalElements: map['totalElements'] as int,
      totalPages: map['totalPages'] as int,
      last: map['last'] as bool,
      content: (map['content'] as List)
          .map((e) => QuizzesSummary.fromJson(e))
          .toList(),
    );
  }
}

class QuizzesSummary {
  final String id;
  final String type; // "Quiz" or "Survey"
  final String title;
  final int totalQuestion;
  final bool status;
  final String quizTotalDuration;
  final String quizDuration;
  final bool? isAnnounced;
  final bool? isParticipated;
  final bool? isMandatory;
  final DateTime createdAt;
  final int maxRetake;
  final String visibilityType;

  QuizzesSummary({
    required this.id,
    required this.type,
    required this.title,
    required this.totalQuestion,
    required this.status,
    required this.quizTotalDuration,
    required this.quizDuration,
    this.isAnnounced,
    this.isParticipated,
    this.isMandatory,
    required this.createdAt,
    required this.maxRetake,
    required this.visibilityType,
  });

  factory QuizzesSummary.fromJson(Map<String, dynamic> json) {
    return QuizzesSummary(
      id: json['id'],
      type: json['type'] ?? "",
      title: json['title'] ?? "",
      totalQuestion: json['totalQuestion'] ?? 0,
      status: json['status'] ?? false,
      quizTotalDuration: json['quizTotalDuration']?.toString() ?? '',
      quizDuration: json["quizDuration"] ?? '',
      isAnnounced: json['isAnnounced'] ?? false,
      isParticipated: json['isParticipated'] ?? false,
      isMandatory: json['isMandatory'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      maxRetake: json['maxRetake'] ?? 0,
      visibilityType: json["visibilityType"] ?? "PUBLIC",
    );
  }

  String get statusString => status ? "Active" : "Closed";
}
