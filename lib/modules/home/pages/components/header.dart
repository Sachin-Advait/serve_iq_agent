import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/configs/theme/app_theme.dart';
import 'package:servelq_agent/modules/home/cubit/home_cubit.dart';
import 'package:servelq_agent/routes/pages.dart';
import 'package:servelq_agent/services/session_manager.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final displayText =
            '${SessionManager.getCounterName()} - ${SessionManager.getCounterCode()}';

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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
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
              PopupMenuButton<String>(
                offset: const Offset(0, 60),
                tooltip: '',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.offWhite,
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.menu, color: AppColors.brownDeep, size: 24),
                ),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'notification',
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: AppColors.brownDeep,
                          size: 20,
                        ),
                        12.horizontalSpace,
                        Text(
                          'Notifications',
                          style: context.medium.copyWith(
                            color: AppColors.brownDarker,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'quiz',
                    child: Row(
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          color: AppColors.brownDeep,
                          size: 20,
                        ),
                        12.horizontalSpace,
                        Text(
                          'Quiz',
                          style: context.medium.copyWith(
                            color: AppColors.brownDarker,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'training',
                    child: Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          color: AppColors.brownDeep,
                          size: 20,
                        ),
                        12.horizontalSpace,
                        Text(
                          'Training',
                          style: context.medium.copyWith(
                            color: AppColors.brownDarker,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    height: 1,
                    enabled: false,
                    child: Divider(color: AppColors.lightBeige, thickness: 1),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppImages.logout,
                          color: AppColors.red,
                          height: 20,
                        ),
                        12.horizontalSpace,
                        Text(
                          'Logout',
                          style: context.medium.copyWith(
                            color: AppColors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (String value) {
                  switch (value) {
                    case 'notification':
                      // Handle notification action
                      // context.pushNamed('/notifications');
                      break;
                    case 'quiz':
                      // Handle quiz action
                      context.pushNamed(Routes.quiz);
                      break;
                    case 'training':
                      // Handle training action
                      context.pushNamed(Routes.training);
                      break;
                    case 'logout':
                      SessionManager.clearSession();
                      context.goNamed(Routes.login);
                      break;
                  }
                },
              ),
              10.horizontalSpace,
            ],
          ),
        );
      },
    );
  }
}
