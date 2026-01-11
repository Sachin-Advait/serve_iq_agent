import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
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
            'Call Next',
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
                ? 'Complete (${state.completeButtonRemainingSeconds})'
                : 'Complete',
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
            'Recall',
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
                ? 'Transfer (${state.completeButtonRemainingSeconds})'
                : 'Transfer',
            AppImages.transferred,
            AppColors.red,
            () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext dialogContext) {
                  return BlocProvider.value(
                    value: context.read<HomeCubit>(),
                    child: TransferDialog(state: state),
                  );
                },
              );
            },
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
                ? 'Hold (${state.completeButtonRemainingSeconds})'
                : 'Hold',
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
                ? 'No Show (${state.completeButtonRemainingSeconds})'
                : 'No Show',
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
          5.horizontalSpace,
          Text(
            label,
            style: TextStyle(
              color: enabled ? AppColors.white : AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
