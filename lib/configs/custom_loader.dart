import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:servelq_agent/configs/app_colors.dart';

void customLoader() {
  EasyLoading.instance
    ..displayDuration = const Duration(seconds: 15)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..loadingStyle = EasyLoadingStyle.custom
    ..textColor = Colors.black
    ..backgroundColor = AppColors.white
    ..indicatorColor = AppColors.primary
    ..maskColor = AppColors.white.withValues(alpha: .2)
    ..userInteractions = false
    ..animationStyle = EasyLoadingAnimationStyle.offset
    ..dismissOnTap = false
    ..indicatorWidget = SizedBox(
      height: 30,
      width: 25,
      child: LoadingAnimationWidget.threeArchedCircle(
        color: Colors.black,
        size: 23,
      ),
    );
  EasyLoading.show(
    maskType: EasyLoadingMaskType.custom,
    status: 'Please wait...',
  );
}
