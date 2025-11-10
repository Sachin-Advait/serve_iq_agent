class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String branchId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.branchId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      branchId: json['branchId'] ?? '',
    );
  }

  bool get isAgent => role == 'USER';
  bool get isDisplay => role == 'DISPLAY';
}
