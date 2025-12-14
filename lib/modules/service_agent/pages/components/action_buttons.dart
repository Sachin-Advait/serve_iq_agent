// components/action_buttons.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/modules/service_agent/cubit/service_agent_cubit.dart';
import 'package:servelq_agent/modules/service_agent/pages/components/transfer_dialog.dart';

class ActionButtons extends StatefulWidget {
  final ServiceAgentState state;

  const ActionButtons({super.key, required this.state});

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  Timer? _completeButtonTimer;
  int _remainingSeconds = 0;
  bool _isCompleteButtonDisabled = false;

  @override
  void dispose() {
    _completeButtonTimer?.cancel();
    super.dispose();
  }

  void _startCompleteButtonTimer() {
    setState(() {
      _isCompleteButtonDisabled = true;
      _remainingSeconds = 20;
    });

    _completeButtonTimer?.cancel();
    _completeButtonTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _isCompleteButtonDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            'Call Next',
            AppImages.callNext,
            const Color(0xFF10B981),
            () async {
              await context.read<ServiceAgentCubit>().callNext();
              _startCompleteButtonTimer();
            },
            enabled:
                widget.state.queue.isNotEmpty &&
                (widget.state.currentToken?.id == null ||
                    widget.state.currentTokenStatus ==
                        CurrentTokenStatus.initial),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context,
            _isCompleteButtonDisabled
                ? 'Complete ($_remainingSeconds)'
                : 'Complete',
            AppImages.complete,
            AppColors.green,
            () => context.read<ServiceAgentCubit>().completeService(),
            enabled:
                !_isCompleteButtonDisabled &&
                widget.state.currentToken?.id != null &&
                widget.state.currentTokenStatus == CurrentTokenStatus.loaded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context,
            'Recall',
            AppImages.recall,
            AppColors.brownDark,
            () async {
              await context.read<ServiceAgentCubit>().recallCurrentToken();
              _startCompleteButtonTimer();
            },
            enabled:
                widget.state.currentToken?.id != null &&
                widget.state.currentTokenStatus == CurrentTokenStatus.loaded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context,
            'Transfer',
            AppImages.transferred,
            AppColors.red,
            () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext dialogContext) {
                  return BlocProvider.value(
                    value: context.read<ServiceAgentCubit>(),
                    child: TransferDialog(state: widget.state),
                  );
                },
              );
            },
            enabled:
                widget.state.currentToken?.id != null &&
                widget.state.currentTokenStatus == CurrentTokenStatus.loaded,
          ),
        ),
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
            height: 33,
            color: enabled ? Colors.white : AppColors.brownDark,
          ),
          15.horizontalSpace,
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
