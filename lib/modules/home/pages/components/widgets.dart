import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:servelq_agent/common/utils/app_screen_util.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/configs/theme/app_theme.dart';

class QueueCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const QueueCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightBeige,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brownDark, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(icon, height: 20, color: AppColors.brownDeep),
              14.horizontalSpace,
              Text(
                label,
                style: context.medium.copyWith(
                  color: AppColors.brownDeep,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: context.bold.copyWith(
              color: AppColors.brownDeep,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoField extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const InfoField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(icon, height: 18, color: AppColors.brownDark),
            10.horizontalSpace,
            Text(
              label,
              style: context.semiBold.copyWith(
                fontSize: 13,
                color: AppColors.brownDarker,
              ),
            ),
          ],
        ),
        10.verticalSpace,
        Text(
          value,
          style: context.semiBold.copyWith(
            fontSize: 14,
            color: AppColors.brownDeep,
          ),
        ),
      ],
    );
  }
}
