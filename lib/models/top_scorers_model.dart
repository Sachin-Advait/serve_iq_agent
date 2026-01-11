class TopScorersModel {
  final bool? success;
  final String? message;
  final TopScorersDetails? data;

  TopScorersModel({this.success, this.message, this.data});

  factory TopScorersModel.fromJson(Map<String, dynamic> json) =>
      TopScorersModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : TopScorersDetails.fromJson(json["data"]),
      );
}

class TopScorersDetails {
  final int? totalAttempts;
  final double? averageScore;
  final int? highestScore;
  final int? maxScore;
  final List<TopScorer>? topScorers;

  TopScorersDetails({
    this.totalAttempts,
    this.averageScore,
    this.highestScore,
    this.maxScore,
    this.topScorers,
  });

  factory TopScorersDetails.fromJson(Map<String, dynamic> json) =>
      TopScorersDetails(
        totalAttempts: json["totalAttempts"],
        averageScore: json["averageScore"]?.toDouble(),
        highestScore: json["highestScore"],
        maxScore: json["maxScore"],
        topScorers: json["topScorers"] == null
            ? []
            : List<TopScorer>.from(
                json["topScorers"]!.map((x) => TopScorer.fromJson(x)),
              ),
      );
}

class TopScorer {
  final int? score;
  final int? maxScore;
  final String? userId;
  final String? username;

  TopScorer({this.score, this.maxScore, this.userId, this.username});

  factory TopScorer.fromJson(Map<String, dynamic> json) => TopScorer(
    score: json["score"],
    maxScore: json["maxScore"],
    userId: json["userId"],
    username: json["username"],
  );
}
