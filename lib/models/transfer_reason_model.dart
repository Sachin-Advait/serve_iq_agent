import 'package:flutter/widgets.dart';
import 'package:servelq_agent/common/constants/app_strings.dart';
import 'package:servelq_agent/configs/lang/localization_cubit.dart';

/// A reason the agent picks when transferring a token. The admin manages the
/// list; the token stores [code].
class TransferReasonModel {
  final String code;
  final String titleEn;
  final String titleAr;

  const TransferReasonModel({
    required this.code,
    required this.titleEn,
    required this.titleAr,
  });

  factory TransferReasonModel.fromJson(Map<String, dynamic> json) =>
      TransferReasonModel(
        code: json['code'] ?? '',
        titleEn: json['titleEn'] ?? '',
        titleAr: json['titleAr'] ?? '',
      );

  String title(String languageCode) =>
      languageCode == 'ar' && titleAr.isNotEmpty ? titleAr : titleEn;
}

/// Title of a transfer reason in the current language: from the list the
/// admin manages, else the built-in translation for the original codes, else
/// the code itself.
String transferReasonTitle(
  BuildContext context,
  String code,
  List<TransferReasonModel> reasons,
) {
  final languageCode = context.currentLocale.languageCode;
  for (final reason in reasons) {
    if (reason.code == code) return reason.title(languageCode);
  }
  return context.tr(AppStrings.transferReason(code));
}
