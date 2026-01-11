import 'package:flutter/material.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: AppColors.brownDarker),
          ),
        ],
      ),
    );
  }
}
