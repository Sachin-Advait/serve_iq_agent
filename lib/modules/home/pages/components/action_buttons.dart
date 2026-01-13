import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:servelq_agent/common/constants/app_strings.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/lang/localization_cubit.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/modules/home/cubit/home_cubit.dart';
import 'package:servelq_agent/modules/home/pages/components/transfer_dialog.dart';

class ActionButtons extends StatelessWidget {
  final HomeState state;

  const ActionButtons({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            context.tr(AppStrings.actionCallNext),
            AppImages.callNext,
            AppColors.green,
            () => context.read<HomeCubit>().callToken(),
            enabled:
                state.queue.isNotEmpty &&
                (state.currentToken?.id == null ||
                    state.currentTokenStatus == CurrentTokenStatus.initial) &&
                state.counter!.status == 'IDLE',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            context,
            state.isCompleteButtonDisabled
                ? '${context.tr(AppStrings.actionComplete)} (${state.completeButtonRemainingSeconds})'
                : context.tr(AppStrings.actionComplete),
            AppImages.complete,
            AppColors.green,
            () => context.read<HomeCubit>().completeToken(),
            enabled:
                !state.isCompleteButtonDisabled &&
                state.currentToken?.id != null &&
                state.currentTokenStatus == CurrentTokenStatus.loaded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            context,
            context.tr(AppStrings.actionRecall),
            AppImages.recall,
            AppColors.brownDark,
            () => context.read<HomeCubit>().recallToken(),
            enabled:
                state.currentToken?.id != null &&
                state.currentTokenStatus == CurrentTokenStatus.loaded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            context,
            state.isCompleteButtonDisabled
                ? '${context.tr(AppStrings.actionTransfer)} (${state.completeButtonRemainingSeconds})'
                : context.tr(AppStrings.actionTransfer),
            AppImages.transferred,
            AppColors.red,
            () => _openTransferDialog(context),
            enabled:
                !state.isCompleteButtonDisabled &&
                state.currentToken?.id != null &&
                state.currentTokenStatus == CurrentTokenStatus.loaded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            context,
            state.isCompleteButtonDisabled
                ? '${context.tr(AppStrings.actionHold)} (${state.completeButtonRemainingSeconds})'
                : context.tr(AppStrings.actionHold),
            AppImages.hold,
            AppColors.blue,
            () => context.read<HomeCubit>().holdToken(),
            enabled:
                !state.isCompleteButtonDisabled &&
                state.currentToken?.id != null &&
                state.currentTokenStatus == CurrentTokenStatus.loaded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            context,
            state.isCompleteButtonDisabled
                ? '${context.tr(AppStrings.actionNoShow)} (${state.completeButtonRemainingSeconds})'
                : context.tr(AppStrings.actionNoShow),
            AppImages.noShow,
            AppColors.brownVeryDark,
            () => context.read<HomeCubit>().noShow(),
            enabled:
                !state.isCompleteButtonDisabled &&
                state.currentToken?.id != null &&
                state.currentTokenStatus == CurrentTokenStatus.loaded,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  void _openTransferDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<HomeCubit>(),
        child: TransferDialog(state: context.read<HomeCubit>().state),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    String icon,
    Color color,
    VoidCallback onPressed, {
    bool enabled = true,
  }) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: AppColors.lightBeige,
        padding: const EdgeInsets.symmetric(vertical: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            height: 28,
            color: enabled ? Colors.white : AppColors.brownDark,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
