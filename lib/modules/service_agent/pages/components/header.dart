import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/configs/theme/app_theme.dart';
import 'package:servelq_agent/modules/service_agent/cubit/service_agent_cubit.dart';
import 'package:servelq_agent/services/session_manager.dart';

class Header extends StatelessWidget {
  final ServiceAgentState state;

  const Header({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final branch = state.counter;
    final displayText = '${branch?.name} - ${branch?.code}';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(AppImages.logo, height: 80),
          160.horizontalSpace,
          Text(
            displayText,
            style: context.semiBold.copyWith(
              color: AppColors.brownDeep,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              SessionManager.clearSession();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: AppColors.lightBeige,
              padding: const EdgeInsets.symmetric(vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppImages.logout,
                    color: AppColors.white,
                    height: 40,
                  ),
                  10.horizontalSpace,
                  Text(
                    'Logout',
                    style: context.semiBold.copyWith(
                      color: AppColors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          20.horizontalSpace,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  'Agent: ${SessionManager.getUsername()}',
                  style: context.medium.copyWith(
                    color: AppColors.brownDarker,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                8.horizontalSpace,
                const Icon(Icons.circle, color: AppColors.green, size: 10),
                4.horizontalSpace,
                Text(
                  'Online',
                  style: context.medium.copyWith(
                    color: AppColors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          10.horizontalSpace,
          SvgPicture.asset(
            AppImages.notification,
            height: 80,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }
}
