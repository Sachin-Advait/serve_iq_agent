class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String branchId;
  final String counterId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.branchId,
    required this.counterId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      branchId: json['branchId'] ?? '',
      counterId: json['counterId'] ?? '',
    );
  }

  bool get isAgent => role == 'USER';
  bool get isDisplay => role == 'DISPLAY';
}
