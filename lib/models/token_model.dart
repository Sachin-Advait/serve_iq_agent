class TokenModel {
  final String id;
  final String token;

  /// Arabic form of [token]: number then Arabic letter (001أ)
  final String arabicToken;
  final String serviceName;
  final String serviceArabicName;
  final String status;
  final String mobileNumber;
  final bool isTransfer;
  final String? transferCounterName;
  final String? transferReason;

  TokenModel({
    this.id = '',
    this.token = '',
    this.arabicToken = '',
    this.serviceName = '',
    this.serviceArabicName = '',
    this.status = '',
    this.mobileNumber = '',
    this.isTransfer = false,
    this.transferCounterName,
    this.transferReason,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      id: json['tokenId'] ?? json['id'],
      token: json['token'] ?? '',
      arabicToken: json['arabicToken'] ?? '',
      serviceName: json['serviceName'] ?? '',
      serviceArabicName: json['serviceArabicName'] ?? '',
      status: json['status'] ?? 'WAITING',
      mobileNumber: json["mobileNumber"] ?? '',
      isTransfer: json["isTransfer"] ?? false,
      transferCounterName: json["transferCounterName"] ?? '',
      transferReason: json["transferReason"],
    );
  }

  /// The ticket number in the app's language: 001أ in Arabic when the
  /// server sent one. Show it left to right so the number stays first.
  String tokenIn(String languageCode) =>
      languageCode == 'ar' && arabicToken.isNotEmpty ? arabicToken : token;

  /// The service name in the app's language; English when there is no
  /// Arabic name (older tokens, or a service without one).
  String serviceNameIn(String languageCode) =>
      languageCode == 'ar' && serviceArabicName.isNotEmpty
      ? serviceArabicName
      : serviceName;
}
