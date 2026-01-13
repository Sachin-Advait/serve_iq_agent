// components/main_panel.dart
import 'package:flutter/material.dart';
import 'package:servelq_agent/common/constants/app_strings.dart';
import 'package:servelq_agent/common/utils/app_screen_util.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/lang/localization_cubit.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/configs/theme/app_theme.dart';
import 'package:servelq_agent/modules/home/cubit/home_cubit.dart';
import 'package:servelq_agent/modules/home/pages/components/action_buttons.dart';
import 'package:servelq_agent/modules/home/pages/components/widgets.dart';

class MainPanel extends StatelessWidget {
  final HomeState state;

  const MainPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 20),
          if (state.currentToken?.mobileNumber != null &&
              state.currentTokenStatus == CurrentTokenStatus.loaded)
            _buildCurrentTokenInfo(state, context)
          else
            _buildEmptyState(context, state),
          const SizedBox(height: 28),
          ActionButtons(state: state),
          const SizedBox(height: 28),
          Expanded(child: _buildHistoryPanel(state, context)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeState state) {
    String message;

    if (state.counter?.status == "COMPLETE") {
      message = context.tr(AppStrings.visitorWritingFeedback);
    } else if (state.queue.isEmpty) {
      message = context.tr(AppStrings.noTokensInQueue);
    } else {
      message = context.tr(AppStrings.clickCallNextToServe);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.offWhite.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add_check_circle_outlined,
            size: 80,
            color: AppColors.brownDark,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTokenInfo(HomeState state, BuildContext context) {
    final token = state.currentToken!;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.offWhite.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(AppStrings.currentVisitor),
            style: context.semiBold.copyWith(
              fontSize: 20,
              color: AppColors.brownDarker,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: InfoField(
                  label: context.tr(AppStrings.mobileNumber),
                  value: token.mobileNumber,
                  icon: AppImages.id,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: InfoField(
                  label: context.tr(AppStrings.serviceType),
                  value: token.serviceName,
                  icon: AppImages.serviceType,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            context.tr(AppStrings.notesDocuments),
            style: context.semiBold.copyWith(
              fontSize: 12,
              color: AppColors.brownDarker,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: context.tr(AppStrings.addNotesOrAttachDocuments),
              hintStyle: const TextStyle(color: AppColors.taupe),
              filled: true,
              fillColor: AppColors.lightBeige.withValues(alpha: .8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.beige),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.beige),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel(HomeState state, BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
      decoration: BoxDecoration(
        color: AppColors.offWhite.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(AppStrings.recentServiceHistory),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.brownDarker,
            ),
          ),
          20.verticalSpace,
          Expanded(
            child: state.recentServices.isEmpty
                ? Center(
                    child: ListView(
                      children: [
                        Center(
                          child: Icon(
                            Icons.history,
                            size: 64,
                            color: AppColors.brownDarker.withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.tr(AppStrings.noServiceHistoryYet),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brownDarker.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr(AppStrings.recentServicesWillAppearHere),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.brownDarker.withValues(alpha: 0.4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : state.recentServices.length > 3
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 6,
                        ),
                    itemCount: state.recentServices.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      state.recentServices[index].token,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          state.recentServices[index].civilId,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: AppColors.brownVeryDark,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          state.recentServices[index].service,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.brownDarker,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${state.recentServices[index].time} ${context.tr(AppStrings.mins)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: state.recentServices.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      state.recentServices[index].token,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.recentServices[index].civilId,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: AppColors.brownVeryDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          state.recentServices[index].service,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.brownDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${state.recentServices[index].time} ${context.tr(AppStrings.mins)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
