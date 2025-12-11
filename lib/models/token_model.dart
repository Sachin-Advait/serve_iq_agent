class TokenModel {
  final String id;
  final String token;
  final String serviceName;
  final String serviceId;
  final String status;
  final String mobileNumber;
  final bool isTransfer;
  final String? transferCounterName;

  TokenModel({
    this.id = '',
    this.token = '',
    this.serviceName = '',
    this.serviceId = '',
    this.status = '',
    this.mobileNumber = '',
    this.isTransfer = false,
    this.transferCounterName,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      id: json['tokenId'] ?? '',
      token: json['token'] ?? '',
      serviceName: json['serviceName'] ?? '',
      serviceId: json['serviceId'] ?? '',
      status: json['status'] ?? 'WAITING',
      mobileNumber: json["mobileNumber"] ?? '',
      isTransfer: json["isTransfer"] ?? false,
      transferCounterName: json["transferCounterName"] ?? '',
    );
  }
}
