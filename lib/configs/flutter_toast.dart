import 'package:flutter/material.dart';
import 'package:servelq_agent/configs/app_colors.dart';
import 'package:servelq_agent/configs/global_keys.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void flutterToast({required String message, Color? color}) {
  final overlayState = GlobalKeys.navigatorKey.currentState?.overlay;

  if (overlayState == null) {
    debugPrint("❌ Overlay not ready");
    return;
  }

  showTopSnackBar(
    overlayState,
    animationDuration: Duration(seconds: 1),
    CustomSnackBar.info(
      backgroundColor: color ?? AppColors.secondary,
      message: message,
      iconPositionLeft: 30,
      iconRotationAngle: 0,
      icon: const Padding(
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.error_outline, color: Colors.white, size: 35),
      ),
      textStyle: TextStyle(fontSize: 22, color: Colors.white),
    ),
  );
}
