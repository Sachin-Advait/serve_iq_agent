class ServiceHistory {
  final String token;
  final String civilId;
  final String service;
  final int time;
  final int seconds;
  final String note;

  ServiceHistory({
    required this.token,
    required this.civilId,
    required this.service,
    required this.time,
    this.seconds = 0,
    this.note = '',
  });

  factory ServiceHistory.fromJson(Map<String, dynamic> json) {
    final minutes = (json['timeTakenInMinutes'] as num?)?.toInt() ?? 0;
    return ServiceHistory(
      token: json['token'] ?? '',
      civilId: json['civilId'] ?? '',
      service: json['serviceName'] ?? '',
      time: minutes,
      seconds: (json['timeTakenInSeconds'] as num?)?.toInt() ?? minutes * 60,
      note: json['note'] ?? '',
    );
  }
}
