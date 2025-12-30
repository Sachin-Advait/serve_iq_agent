class CounterModel {
  final String id;
  final String code;
  final String name;
  final bool enabled;
  final bool paused;
  final String status;
  final String? userId;
  final String? username;
  final double avgSecond;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CounterModel({
    required this.id,
    required this.code,
    required this.name,
    required this.enabled,
    required this.paused,
    required this.status,
    this.userId,
    this.username,
    required this.avgSecond,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      enabled: json['enabled'],
      paused: json['paused'],
      status: json['status'],
      userId: json['userId'],
      username: json['username'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      avgSecond: json['avgSeconds'] ?? 10,
    );
  }
}
