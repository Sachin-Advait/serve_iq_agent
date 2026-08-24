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
}

class AuthResponse {
  final String token;
  final int expiresInSeconds;
  final String tokenType;
  final UserModel user;

  AuthResponse({
    required this.token,
    required this.expiresInSeconds,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      expiresInSeconds: json['expiresInSeconds'] ?? 0,
      tokenType: json['tokenType'] ?? 'Bearer',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}
