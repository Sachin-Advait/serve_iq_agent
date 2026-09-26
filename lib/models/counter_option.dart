class CounterOption {
  const CounterOption({
    required this.id,
    required this.code,
    required this.name,
    required this.occupied,
    this.branchName,
    this.occupiedByName,
  });

  final String id, code, name;
  final String? branchName, occupiedByName;
  final bool occupied;

  String get label =>
      occupied ? '$name ($code) — in use by $occupiedByName' : '$name ($code)';

  factory CounterOption.fromJson(Map<String, dynamic> j) => CounterOption(
    id: j['id'] as String,
    code: j['code'] as String,
    name: j['name'] as String,
    branchName: j['branchName'] as String?,
    occupiedByName: j['occupiedByName'] as String?,
    occupied: j['occupied'] as bool? ?? false,
  );
}
