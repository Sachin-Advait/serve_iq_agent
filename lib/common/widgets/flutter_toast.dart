import 'package:flutter/material.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/common/utils/global_keys.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

// Requests that fail together (e.g. after the tab sat open and the login
// expired or the network dropped) each raise the same toast; show it once.
String? _lastMessage;
DateTime _lastShownAt = DateTime.fromMillisecondsSinceEpoch(0);

void flutterToast({required String message, Color? color}) {
  final now = DateTime.now();
  if (message == _lastMessage &&
      now.difference(_lastShownAt) < const Duration(seconds: 3)) {
    return;
  }
  _lastMessage = message;
  _lastShownAt = now;

  final overlayState = GlobalKeys.navigatorKey.currentState?.overlay;

  if (overlayState == null) {
    debugPrint("❌ Overlay not ready");
    return;
  }

  showTopSnackBar(
    overlayState,
    animationDuration: Duration(seconds: 1),
    CustomSnackBar.info(
      backgroundColor: color ?? AppColors.primary,
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
