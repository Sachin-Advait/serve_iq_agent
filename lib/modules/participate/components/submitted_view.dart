import 'package:flutter/material.dart';
import 'package:servelq_agent/common/widgets/primary_button.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/models/submit_quiz_model.dart';

class SubmittedView extends StatelessWidget {
  const SubmittedView({super.key, required this.submitQuizDetails});

  final SubmitQuizDetails submitQuizDetails;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Icon
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.green.withOpacity(0.2),
                  AppColors.green.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 100,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 40),

          // Score Display
          if (submitQuizDetails.maxScore != 0) ...[
            const Text(
              "Your Final Score",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.taupe,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Text(
                "${submitQuizDetails.score} / ${submitQuizDetails.maxScore}",
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Congratulation Message
          const Text(
            "Congratulations!",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.brownVeryDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Great job, ${submitQuizDetails.username}!",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "You have successfully completed the Quiz",
            style: TextStyle(fontSize: 16, color: AppColors.taupe, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Back Button
          SizedBox(
            width: 300,
            child: PrimaryButton(
              onPressed: () => Navigator.pop(context),
              label: "Back to Home",
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
