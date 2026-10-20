import 'package:flutter/material.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';

/// The logo, decoded at the exact pixel size it is drawn at. The source is
/// much larger than any place it is shown, and letting the browser shrink it
/// on the fly makes the fine detail grainy or blurred at small sizes.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return Image.asset(
      AppImages.logo,
      height: height,
      cacheHeight: (height * pixelRatio).round(),
      filterQuality: FilterQuality.medium,
    );
  }
}
