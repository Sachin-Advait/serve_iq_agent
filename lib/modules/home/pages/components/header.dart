import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/common/constants/app_strings.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/lang/localization_cubit.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/configs/theme/app_theme.dart';
import 'package:servelq_agent/modules/home/cubit/home_cubit.dart';
import 'package:servelq_agent/routes/pages.dart';
import 'package:servelq_agent/services/session_manager.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current route location
    final currentRoute = GoRouterState.of(context).uri.toString();
    final isOnHomePage =
        currentRoute == Routes.agent || currentRoute == '/${Routes.agent}';

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

              // Home Button - Only visible when NOT on home page
              if (!isOnHomePage) ...[
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      context.goNamed(Routes.agent);
                    },
                    child: Image.asset(
                      AppImages.home,
                      height: 25,
                      color: AppColors.brownVeryDark,
                    ),
                  ),
                ),
                20.horizontalSpace,
              ],

              // Language Toggle
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () =>
                      context.read<LocalizationCubit>().toggleLanguage(),
                  child: Image.asset(
                    AppImages.translation,
                    height: 30,
                    color: AppColors.brownVeryDark,
                  ),
                ),
              ),
              20.horizontalSpace,

              // Agent Status
              BlocBuilder<LocalizationCubit, LocalizationState>(
                builder: (context, localizationState) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: localizationState.locale.languageCode == "en"
                          ? AppColors.white
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${context.trNoListen(AppStrings.agent)}: ${SessionManager.getUsername()}',
                          style: context.medium.copyWith(
                            color: localizationState.locale.languageCode == "en"
                                ? AppColors.brownDark
                                : AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        8.horizontalSpace,
                        const Icon(
                          Icons.circle,
                          color: AppColors.green,
                          size: 10,
                        ),
                        4.horizontalSpace,
                        Text(
                          context.trNoListen(AppStrings.online),
                          style: context.medium.copyWith(
                            color: AppColors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              10.horizontalSpace,

              // Menu Button
              PopupMenuButton<String>(
                offset: const Offset(0, 60),
                tooltip: '',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.offWhite,
                icon: BlocBuilder<LocalizationCubit, LocalizationState>(
                  builder: (context, localizationState) {
                    return Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: localizationState.locale.languageCode == "en"
                            ? AppColors.white
                            : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu,
                        color: localizationState.locale.languageCode == "en"
                            ? AppColors.brownDark
                            : AppColors.white,
                        size: 24,
                      ),
                    );
                  },
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
                          context.trNoListen(AppStrings.notifications),
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
                    enabled: !_isOnRoute(currentRoute, Routes.quiz),
                    child: Row(
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          color: _isOnRoute(currentRoute, Routes.quiz)
                              ? AppColors.taupe
                              : AppColors.brownDeep,
                          size: 20,
                        ),
                        12.horizontalSpace,
                        Text(
                          context.trNoListen(AppStrings.quiz),
                          style: context.medium.copyWith(
                            color: _isOnRoute(currentRoute, Routes.quiz)
                                ? AppColors.taupe
                                : AppColors.brownDarker,
                            fontSize: 14,
                          ),
                        ),
                        if (_isOnRoute(currentRoute, Routes.quiz)) ...[
                          4.horizontalSpace,
                          Icon(
                            Icons.check_circle,
                            color: AppColors.green,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'training',
                    enabled: !_isOnRoute(currentRoute, Routes.training),
                    child: Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          color: _isOnRoute(currentRoute, Routes.training)
                              ? AppColors.taupe
                              : AppColors.brownDeep,
                          size: 20,
                        ),
                        12.horizontalSpace,
                        Text(
                          context.trNoListen(AppStrings.training),
                          style: context.medium.copyWith(
                            color: _isOnRoute(currentRoute, Routes.training)
                                ? AppColors.taupe
                                : AppColors.brownDarker,
                            fontSize: 14,
                          ),
                        ),
                        if (_isOnRoute(currentRoute, Routes.training)) ...[
                          4.horizontalSpace,
                          Icon(
                            Icons.check_circle,
                            color: AppColors.green,
                            size: 16,
                          ),
                        ],
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
                          context.trNoListen(AppStrings.logout),
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
                      // Only navigate if not already on quiz page
                      if (!_isOnRoute(currentRoute, Routes.quiz)) {
                        context.pushNamed(Routes.quiz);
                      }
                      break;
                    case 'training':
                      // Only navigate if not already on training page
                      if (!_isOnRoute(currentRoute, Routes.training)) {
                        context.pushNamed(Routes.training);
                      }
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

  /// Helper method to check if current route matches the target route
  bool _isOnRoute(String currentRoute, String targetRoute) {
    // Normalize the current route by removing leading slash
    final normalizedCurrent = currentRoute.startsWith('/')
        ? currentRoute.substring(1)
        : currentRoute;

    // Split the route into segments
    final segments = normalizedCurrent.split('/');

    // For routes like "/agent/quiz" or "/agent/quiz/participate"
    // We check if the route contains the target as a segment
    // This prevents false positives like "quiz" matching "quizzes"

    // Check if target route exists as a complete segment in the path
    return segments.contains(targetRoute);
  }
}
