// components/main_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/common/constants/app_strings.dart';
import 'package:servelq_agent/common/utils/app_screen_util.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/lang/localization_cubit.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/configs/theme/app_theme.dart';
import 'package:servelq_agent/modules/home/cubit/home_cubit.dart';
import 'package:servelq_agent/modules/home/pages/components/action_buttons.dart';
import 'package:servelq_agent/modules/home/pages/components/widgets.dart';
import 'package:servelq_agent/models/service_history.dart';

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
                  value: token.mobileNumber.isEmpty ? "-" : token.mobileNumber,
                  icon: AppImages.id,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: InfoField(
                  label: context.tr(AppStrings.serviceType),
                  value: token.serviceNameIn(
                    context.currentLocale.languageCode,
                  ),
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
            // A fresh field for each visitor
            key: ValueKey('note-${token.id}'),
            maxLines: 3,
            maxLength: 1000,
            textInputAction: TextInputAction.done,
            onChanged: (value) =>
                context.read<HomeCubit>().updateNote(token.id, value),
            decoration: InputDecoration(
              counterText: '',
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
                : ListView.builder(
                    // Two per row; each row grows to fit the longest text.
                    itemCount: (state.recentServices.length + 1) ~/ 2,
                    itemBuilder: (context, row) {
                      final items = state.recentServices
                          .skip(row * 2)
                          .take(2)
                          .toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: _historyTile(context, items[0])),
                              const SizedBox(width: 12),
                              Expanded(
                                child: items.length > 1
                                    ? _historyTile(context, items[1])
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Token on top, full service name below, minutes on the side.
  Widget _historyTile(BuildContext context, ServiceHistory item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBeige.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.brownDeep.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: AppColors.primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.token,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                    fontSize: 15,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: AppColors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _historyLine(
                            Icons.room_service_outlined,
                            item.service,
                            const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.brownDeep,
                            ),
                          ),
                          if (item.civilId.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            _historyLine(
                              Icons.badge_outlined,
                              item.civilId,
                              const TextStyle(
                                fontSize: 13,
                                color: AppColors.taupe,
                              ),
                            ),
                          ],
                          if (item.note.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            _historyLine(
                              Icons.sticky_note_2_outlined,
                              item.note,
                              const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: AppColors.brownDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 15,
                            color: AppColors.green,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.time > 0
                                ? '${item.time} ${context.tr(AppStrings.mins)}'
                                : '${item.seconds} ${context.tr(AppStrings.secs)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyLine(IconData icon, String text, TextStyle style) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: AppColors.taupe),
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}
