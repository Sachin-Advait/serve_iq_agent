enum TrainingType { all, video, document }

TrainingType trainingTypeFromString(String value) {
  switch (value) {
    case 'video':
      return TrainingType.video;
    case 'document':
      return TrainingType.document;
    default:
      return TrainingType.video;
  }
}

class TrainingModel {
  final bool? success;
  final String? message;
  final List<TrainingAssignment>? data;

  TrainingModel({this.success, this.message, this.data});

  factory TrainingModel.fromJson(Map<String, dynamic> json) => TrainingModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null
        ? []
        : List<TrainingAssignment>.from(
            json["data"]!.map((x) => TrainingAssignment.fromJson(x)),
          ),
  );
}

class TrainingAssignment {
  final String? assignmentId;
  final String? trainingId;
  final String? title;
  final String? type;
  final String? duration;
  final String? cloudinaryUrl;
  final String? cloudinaryFormat;
  final String? cloudinaryResourceType;
  final int? progress;
  final String? status;
  final DateTime? dueDate;

  TrainingAssignment({
    this.assignmentId,
    this.trainingId,
    this.title,
    this.type,
    this.duration,
    this.cloudinaryUrl,
    this.cloudinaryFormat,
    this.cloudinaryResourceType,
    this.progress,
    this.status,
    this.dueDate,
  });

  factory TrainingAssignment.fromJson(Map<String, dynamic> json) =>
      TrainingAssignment(
        assignmentId: json["assignmentId"],
        trainingId: json["trainingId"],
        title: json["title"],
        type: json["type"],
        duration: json["duration"],
        cloudinaryUrl: json["cloudinaryUrl"],
        cloudinaryFormat: json["cloudinaryFormat"],
        cloudinaryResourceType: json["cloudinaryResourceType"],
        progress: json["progress"],
        status: json["status"],
        dueDate: json["dueDate"] == null
            ? null
            : DateTime.parse(json["dueDate"]),
      );
}
