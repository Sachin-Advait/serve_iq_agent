// components/action_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/modules/service_agent/cubit/service_agent_cubit.dart';
import 'package:servelq_agent/modules/service_agent/pages/components/transfer_dialog.dart';

class ActionButtons extends StatelessWidget {
  final ServiceAgentState state;

  const ActionButtons({super.key, required this.state});

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
            () => context.read<ServiceAgentCubit>().callNext(),
            enabled:
                state.queue.isNotEmpty &&
                (state.currentToken?.id == null ||
                    state.currentTokenStatus == CurrentTokenStatus.initial),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context,
            'Complete',
            Icons.check_circle_outline_rounded,
            const Color(0xFF2563EB),
            () => context.read<ServiceAgentCubit>().completeService(),
            enabled:
                state.currentToken?.id != null &&
                state.currentTokenStatus == CurrentTokenStatus.loaded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context,
            'Recall',
            Icons.refresh_rounded,
            const Color(0xFF10B981),
            () => context.read<ServiceAgentCubit>().recallCurrentToken(),
            enabled:
                state.currentToken?.id != null &&
                state.currentTokenStatus == CurrentTokenStatus.loaded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context,
            'Transfer',
            Icons.arrow_forward_rounded,
            Color(0xFFDC2626),
            () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext dialogContext) {
                  return BlocProvider.value(
                    value: context.read<ServiceAgentCubit>(),
                    child: TransferDialog(state: state),
                  );
                },
              );
            },
            enabled:
                state.currentToken?.id != null &&
                state.currentTokenStatus == CurrentTokenStatus.loaded,
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
