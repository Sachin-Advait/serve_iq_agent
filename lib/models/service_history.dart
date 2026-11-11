class ServiceHistory {
  final String token;

  /// Arabic form of [token] (001أ)
  final String arabicToken;
  final String civilId;
  final String service;

  /// Arabic service name; empty for older tokens or a service without one.
  final String serviceArabicName;
  final int time;
  final int seconds;
  final String note;

  ServiceHistory({
    required this.token,
    this.arabicToken = '',
    required this.civilId,
    required this.service,
    this.serviceArabicName = '',
    required this.time,
    this.seconds = 0,
    this.note = '',
  });

  factory ServiceHistory.fromJson(Map<String, dynamic> json) {
    final minutes = (json['timeTakenInMinutes'] as num?)?.toInt() ?? 0;
    return ServiceHistory(
      token: json['token'] ?? '',
      arabicToken: json['arabicToken'] ?? '',
      civilId: json['civilId'] ?? '',
      service: json['serviceName'] ?? '',
      serviceArabicName: json['serviceArabicName'] ?? '',
      time: minutes,
      seconds: (json['timeTakenInSeconds'] as num?)?.toInt() ?? minutes * 60,
      note: json['note'] ?? '',
    );
  }

  /// The ticket number to show: the English one (A001) in both languages.
  String tokenIn(String languageCode) => token;

  /// The service name in the app's language; English when there is no
  /// Arabic name.
  String serviceIn(String languageCode) =>
      languageCode == 'ar' && serviceArabicName.isNotEmpty
      ? serviceArabicName
      : service;
}
