// components/action_buttons.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            Icons.play_arrow_rounded,
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
            Icons.check_circle_outline_rounded,
            const Color(0xFF2563EB),
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
            Icons.refresh_rounded,
            const Color(0xFF10B981),
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
            Icons.arrow_forward_rounded,
            const Color(0xFFDC2626),
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
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool enabled = true,
  }) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: const Color(0xFFE5E7EB),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: enabled ? Colors.white : const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
