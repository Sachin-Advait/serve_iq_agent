import 'package:flutter/material.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/models/training_model.dart';

class MaterialCardWidget extends StatelessWidget {
  final TrainingAssignment material;
  final VoidCallback? onViewMaterial;

  const MaterialCardWidget({
    super.key,
    required this.material,
    this.onViewMaterial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildTitle(),
                const SizedBox(height: 12),
                _buildAssignmentInfo(),
                const SizedBox(height: 12),
                _buildDateAndDuration(),
                const SizedBox(height: 12),
                _buildProgressBar(),
              ],
            ),
          ),
          _buildViewButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String statusText(int progress) {
      if (progress >= 100) {
        return 'Completed';
      } else if (progress > 0) {
        return 'In Progress';
      } else {
        return 'Start';
      }
    }

    Color statusBgColor(int progress) {
      if (progress >= 100) {
        return AppColors.green.withValues(alpha: .2);
      } else if (progress > 0) {
        return AppColors.primary.withValues(alpha: .2);
      } else {
        return AppColors.blue.withValues(alpha: .2);
      }
    }

    Color statusTextColor(int progress) {
      if (progress >= 100) {
        return AppColors.green;
      } else if (progress > 0) {
        return AppColors.primary;
      } else {
        return AppColors.blue;
      }
    }

    return Row(
      children: [
        Icon(
          material.type == TrainingType.video
              ? Icons.play_circle_outline
              : Icons.description_outlined,
          color: AppColors.blue,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          material.type! == TrainingType.video ? 'Video' : 'Document',
          style: const TextStyle(
            color: AppColors.blue,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusBgColor(material.progress ?? 0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            statusText(material.progress ?? 0),
            style: TextStyle(
              color: statusTextColor(material.progress ?? 0),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      material.title!,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.brownVeryDark,
      ),
    );
  }

  Widget _buildAssignmentInfo() {
    return Row(
      children: [
        Text(
          '${material.progress}% completed',
          style: const TextStyle(fontSize: 12, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildDateAndDuration() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 12, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          '${material.dueDate!.month}/${material.dueDate!.day}/${material.dueDate!.year}',
          style: const TextStyle(fontSize: 12, color: AppColors.primary),
        ),
        const Spacer(),
        ...[
          const Icon(Icons.access_time, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            material.duration!,
            style: const TextStyle(fontSize: 12, color: AppColors.primary),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (material.progress ?? 0) / 100,
            backgroundColor: AppColors.beige,
            valueColor: AlwaysStoppedAnimation<Color>(
              material.progress == 100
                  ? const Color(0xFF4CAF50)
                  : AppColors.blue,
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${material.progress}% Complete',
          style: TextStyle(
            fontSize: 11,
            color: material.progress == 100
                ? const Color(0xFF4CAF50)
                : AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildViewButton() {
    return InkWell(
      onTap: onViewMaterial,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_outlined, color: AppColors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'View Material',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
