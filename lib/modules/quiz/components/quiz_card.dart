import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/common/widgets/primary_button.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/configs/theme/app_theme.dart';
import 'package:servelq_agent/models/quiz_model.dart';
import 'package:servelq_agent/routes/pages.dart';

class QuizSurveryCard extends StatelessWidget {
  const QuizSurveryCard({super.key, required this.quiz});

  final QuizzesSummary quiz;

  String formatDurationFromSeconds(int totalSeconds) {
    if (totalSeconds < 60) {
      return '$totalSeconds sec';
    }

    final minutes = totalSeconds ~/ 60;
    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    if (hours < 24) {
      return '$hours hr';
    }

    final days = hours ~/ 24;
    return '$days day${days > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  quiz.title,
                  style: context.medium.copyWith(fontSize: 17),
                ),
              ),

              const SizedBox(width: 10),

              if (quiz.visibilityType == "PRIVATE")
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: AppColors.brownDarker,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Private',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brownDarker,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _InfoChip(
                icon: Icons.timer_outlined,
                label: formatDurationFromSeconds(
                  int.parse(quiz.quizTotalDuration),
                ),
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.quiz_outlined,
                label: "${quiz.totalQuestion} questions",
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: quiz.status
                  ? Colors.green.withValues(alpha: 0.1)
                  : AppColors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: quiz.status ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  quiz.status ? "Open" : "Closed",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: quiz.status ? Colors.green.shade700 : AppColors.red,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: PrimaryButton(
              color: quiz.status
                  ? (quiz.isParticipated == true && quiz.maxRetake > 1
                        ? AppColors.darkBlue
                        : quiz.maxRetake == 0
                        ? AppColors.beige
                        : AppColors.primary)
                  : AppColors.beige,
              label:
                  quiz.isParticipated == true &&
                      quiz.maxRetake > 1 &&
                      quiz.status
                  ? "Re-attempt"
                  : quiz.status == false && quiz.isParticipated == false
                  ? "Not Participated"
                  : quiz.isParticipated == true
                  ? "Participated"
                  : quiz.status == false
                  ? "Closed"
                  : "Participate",
              onPressed: () async {
                if (quiz.status == false) return;

                if (quiz.status &&
                    (quiz.isParticipated == false ||
                        (quiz.isParticipated == true && quiz.maxRetake > 1))) {
                  context.pushNamed(
                    Routes.participate,
                    extra: {"quizId": quiz.id, "isMandatory": quiz.isMandatory},
                  );
                }
              },
            ),
          ),

          if (quiz.isAnnounced == true &&
              quiz.isParticipated == true &&
              !quiz.status &&
              quiz.visibilityType == "PUBLIC")
            Container(
              padding: const EdgeInsets.only(top: 5),
              width: MediaQuery.of(context).size.width,
              child: PrimaryButton(
                color: AppColors.brownVeryDark,
                label: "See Result",
                onPressed: () => context.pushNamed(
                  Routes.result,
                  extra: {"quizId": quiz.id, "title": quiz.title},
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom widget for info chips
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
