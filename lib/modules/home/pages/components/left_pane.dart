import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:servelq_agent/common/constants/app_strings.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/lang/localization_cubit.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/configs/theme/app_theme.dart';
import 'package:servelq_agent/models/transfer_reason_model.dart';
import 'package:servelq_agent/modules/home/cubit/home_cubit.dart';
import 'package:servelq_agent/modules/home/pages/components/widgets.dart';

class LeftPane extends StatelessWidget {
  const LeftPane({super.key});

  // avgSeconds from the backend is actually minutes (e.g. 4.5 = 4m 30s).
  String _formatMinutes(double minutes) {
    final totalSeconds = (minutes * 60).round();
    if (totalSeconds <= 0) return '0s';
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) return '${h}h';
    if (m > 0) return '${m}m';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
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
                      label: context.tr(AppStrings.queueTotalWaiting),
                      value: state.queue.length.toString(),
                      icon: AppImages.totalWaiting,
                    ),
                    const SizedBox(height: 16),
                    QueueCard(
                      label: context.tr(AppStrings.queueAvgWaitTime),
                      value: _formatMinutes(state.counter?.avgSecond ?? 0),
                      icon: AppImages.avgWaitingTime,
                    ),

                    if (state.currentTokenStatus ==
                        CurrentTokenStatus.loaded) ...[
                      const SizedBox(height: 24),
                      _buildCurrentTokenCard(state, context),
                    ],
                    const SizedBox(height: 20),
                    _buildHoldTokens(state, context),
                    _buildNoShowTokens(state, context),
                    _buildTransferredTokens(state, context),
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

  Widget _buildCurrentTokenCard(HomeState state, BuildContext context) {
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
            context.tr(AppStrings.queueCurrentToken),
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

  Widget _buildHoldTokens(HomeState state, BuildContext context) {
    if (state.holdQueue.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.blue, AppColors.darkBlue],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppImages.hold,
                  color: AppColors.white,
                  height: 28,
                ),
                SizedBox(width: 8),
                Text(
                  context.tr(AppStrings.queueHoldTokens),
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
          ...state.holdQueue
              .take(6)
              .map(
                (token) => _tokenTile(
                  context,
                  token: token.token,
                  text: token.serviceNameIn(context.currentLocale.languageCode),
                  background: const Color(0xFFE9F6F7),
                  border: AppColors.darkBlue,
                  tokenColor: AppColors.blue,
                  textColor: AppColors.blue,
                  onTap: _canCallNow(state)
                      ? () => context.read<HomeCubit>().callToken(
                          tokenId: token.id,
                        )
                      : null,
                ),
              ),
          const SizedBox(height: 10),
        ],
      );
    }
    return SizedBox();
  }

  // Visitors marked no-show today. If one comes back, the agent taps the
  // token to call it to this counter.
  Widget _buildNoShowTokens(HomeState state, BuildContext context) {
    if (state.noShowQueue.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.warmGray, AppColors.brownDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                AppImages.noShow,
                color: AppColors.white,
                height: 28,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr(AppStrings.queueNoShowTokens),
                style: const TextStyle(
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
        ...state.noShowQueue
            .take(6)
            .map(
              (token) => _tokenTile(
                context,
                token: token.token,
                text: token.serviceNameIn(context.currentLocale.languageCode),
                background: AppColors.lightBeige,
                border: AppColors.brownDark,
                tokenColor: AppColors.brownDeep,
                textColor: AppColors.brownDark,
                onTap: _canCallNow(state)
                    ? () => context.read<HomeCubit>().callNoShowToken(token.id)
                    : null,
              ),
            ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildUpcomingTokens(HomeState state, BuildContext context) {
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
            borderRadius: BorderRadius.circular(12),
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
                context.tr(AppStrings.queueUpcomingTokens),
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
                  context.tr(AppStrings.queueNoUpcomingTokens),
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
                (token) => _tokenTile(
                  context,
                  token: token.token,
                  text: token.serviceNameIn(context.currentLocale.languageCode),
                  background: AppColors.offWhite,
                  border: AppColors.beige,
                  tokenColor: AppColors.brownDeep,
                  textColor: AppColors.brownDark,
                ),
              ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTransferredTokens(HomeState state, BuildContext context) {
    // Filter only transferred tokens
    final transferredTokens = state.queue
        .where((token) => token.isTransfer)
        .toList();
    if (transferredTokens.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDC2626), AppColors.red],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
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
                  context.tr(AppStrings.queueTransferredTokens),
                  style: context.medium.copyWith(
                    fontSize: 15,
                    color: AppColors.white,
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
                (token) => _tokenTile(
                  context,
                  token: token.token,
                  text: token.serviceNameIn(context.currentLocale.languageCode),
                  background: const Color(0xFFFEF2F2),
                  border: const Color(0xFFFECACA),
                  tokenColor: AppColors.darkRed,
                  textColor: AppColors.brownDeep,
                  onTap: _canCallNow(state)
                      ? () => context.read<HomeCubit>().callTransferredToken(
                          token.id,
                        )
                      : null,
                  details: [
                    if ((token.transferCounterName ?? '').isNotEmpty)
                      _detailLine(
                        Icons.swap_horiz_rounded,
                        '${context.tr(AppStrings.queueFromCounter)} ${token.transferCounterName}',
                        AppColors.darkRed,
                        bold: true,
                      ),
                    if (token.transferReason != null)
                      _detailLine(
                        Icons.info_outline_rounded,
                        transferReasonTitle(
                          context,
                          token.transferReason!,
                          state.transferReasons,
                        ),
                        AppColors.brownDeep,
                      ),
                  ],
                ),
              ),
          const SizedBox(height: 10),
        ],
      );
    }
    return SizedBox();
  }

  // Same rule the hold and no-show lists already used: only call a token
  // when nothing is on screen and the counter is idle.
  bool _canCallNow(HomeState state) =>
      (state.currentToken?.id == null ||
          state.currentTokenStatus == CurrentTokenStatus.initial) &&
      state.counter?.status == 'IDLE';

  /// Queue entry: the token number on top, the full service name under it,
  /// then any extra lines. Tappable entries show a call icon.
  Widget _tokenTile(
    BuildContext context, {
    required String token,
    required String text,
    required Color background,
    required Color border,
    required Color tokenColor,
    required Color textColor,
    VoidCallback? onTap,
    List<Widget> details = const [],
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        token,
                        style: context.bold.copyWith(
                          fontSize: 20,
                          color: tokenColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (onTap != null)
                      Icon(Icons.campaign_rounded, size: 20, color: tokenColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: context.medium.copyWith(
                    fontSize: 12,
                    height: 1.3,
                    color: textColor,
                  ),
                ),
                for (final d in details) ...[const SizedBox(height: 6), d],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailLine(
    IconData icon,
    String text,
    Color color, {
    bool bold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              height: 1.3,
              color: color,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
