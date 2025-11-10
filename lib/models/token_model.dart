class TokenModel {
  final String id;
  final String token;
  final String serviceName;
  final String serviceCode;
  final String status;
  final int waitingCount;
  final DateTime createdAt;
  final DateTime estimatedTime;
  final String civilId;

  TokenModel({
    required this.id,
    required this.token,
    required this.serviceName,
    required this.serviceCode,
    required this.status,
    required this.waitingCount,
    required this.createdAt,
    required this.estimatedTime,
    required this.civilId,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      id: json['tokenId'] ?? '',
      token: json['token'] ?? '',
      serviceName: json['serviceName'] ?? '',
      serviceCode: json['serviceCode'] ?? '',
      status: json['status'] ?? 'WAITING',
      waitingCount: json['waitingCount'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      estimatedTime:
          DateTime.tryParse(json['estimatedTime'] ?? '') ?? DateTime.now(),
      civilId: json["civilId"] ?? '',
    );
  }

  /// Derived computed field: human-readable remaining time
  String get formattedWaitTime {
    final diff = estimatedTime.difference(DateTime.now()).inMinutes;
    if (diff <= 0) return "Now";
    if (diff < 60) {
      return "$diff min";
    } else {
      final hours = diff ~/ 60;
      final minutes = diff % 60;
      return minutes > 0 ? "$hours h $minutes min" : "$hours h";
    }
  }
}
