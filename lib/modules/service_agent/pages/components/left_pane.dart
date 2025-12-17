import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/configs/theme/app_theme.dart';
import 'package:servelq_agent/modules/service_agent/cubit/service_agent_cubit.dart';
import 'package:servelq_agent/modules/service_agent/pages/components/widgets.dart';

class LeftPane extends StatelessWidget {
  const LeftPane({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceAgentCubit, ServiceAgentState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QueueCard(
                      label: 'Total Waiting',
                      value: state.queue.length.toString(),
                      icon: AppImages.totalWaiting,
                    ),
                    const SizedBox(height: 16),
                    QueueCard(
                      label: 'Avg Wait Time',
                      value: (state.counter?.avgSecond ?? 0).toString(),
                      icon: AppImages.avgWaitingTime,
                    ),

                    if (state.currentTokenStatus ==
                        CurrentTokenStatus.loaded) ...[
                      const SizedBox(height: 24),
                      _buildCurrentTokenCard(state),
                    ],
                    _buildTransferredTokens(state),
                    const SizedBox(height: 24),
                    _buildUpcomingTokens(state, context),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrentTokenCard(ServiceAgentState state) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.tokenPng),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Current Token',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          20.verticalSpace,
          // Safe access
          Text(
            state.currentToken?.token ?? '--',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTokens(ServiceAgentState state, BuildContext context) {
    // Filter out transferred tokens
    final upcomingTokens = state.queue
        .where((token) => !token.isTransfer)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.beige],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              15.horizontalSpace,
              SvgPicture.asset(
                AppImages.avgWaitingTime,
                height: 25,
                color: AppColors.white,
              ),
              10.horizontalSpace,
              Text(
                'Upcoming Tokens',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (upcomingTokens.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightBeige,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SvgPicture.asset(AppImages.noToken, height: 25),
                10.horizontalSpace,
                Text(
                  'No upcoming tokens',
                  style: context.medium.copyWith(
                    fontSize: 14,
                    color: AppColors.brownDeep,
                  ),
                ),
              ],
            ),
          )
        else
          ...upcomingTokens
              .take(6)
              .map(
                (token) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.beige, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        token.token,
                        style: context.bold.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.brownDeep,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          token.serviceName,
                          style: context.medium.copyWith(
                            fontSize: 11,
                            color: AppColors.brownDark,
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildTransferredTokens(ServiceAgentState state) {
    // Filter only transferred tokens
    final transferredTokens = state.queue
        .where((token) => token.isTransfer)
        .toList();
    if (transferredTokens.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDC2626), AppColors.red],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppImages.transferred,
                  color: AppColors.white,
                  height: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'Transferred Tokens',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...transferredTokens
              .take(6)
              .map(
                (token) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFECACA),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        token.token,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.darkRed,
                        ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              token.serviceName,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.brownDeep,
                              ),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'From: Counter ${token.transferCounterName}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.darkRed,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      );
    }
    return SizedBox();
  }
}
