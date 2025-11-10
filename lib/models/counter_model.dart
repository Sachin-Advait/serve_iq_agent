class CounterModel {
  final String id;
  final String name;
  final String? counter;
  final String code;

  CounterModel({
    required this.id,
    required this.name,
    this.counter,
    required this.code,
  });

  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      counter: json['counter'],
      code: json['code'] ?? '',
    );
  }
}
