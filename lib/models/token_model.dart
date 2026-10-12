class TokenModel {
  final String id;
  final String token;
  final String serviceName;
  final String status;
  final String mobileNumber;
  final bool isTransfer;
  final String? transferCounterName;
  final String? transferReason;

  TokenModel({
    this.id = '',
    this.token = '',
    this.serviceName = '',
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
      serviceName: json['serviceName'] ?? '',
      status: json['status'] ?? 'WAITING',
      mobileNumber: json["mobileNumber"] ?? '',
      isTransfer: json["isTransfer"] ?? false,
      transferCounterName: json["transferCounterName"] ?? '',
      transferReason: json["transferReason"],
    );
  }
}
