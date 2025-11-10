class ServiceHistory {
  final String token;
  final String civilId;
  final String service;
  final int time;

  ServiceHistory({
    required this.token,
    required this.civilId,
    required this.service,
    required this.time,
  });

  factory ServiceHistory.fromJson(Map<String, dynamic> json) {
    return ServiceHistory(
      token: json['token'] ?? '',
      civilId: json['civilId'] ?? '',
      service: json['serviceName'] ?? '',
      time: json['timeTakenInMinutes'] ?? 0,
    );
  }
}
