// components/main_panel.dart
import 'package:flutter/material.dart';
import 'package:servelq_agent/common/utils/app_screen_util.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/configs/theme/app_theme.dart';
import 'package:servelq_agent/modules/service_agent/cubit/service_agent_cubit.dart';
import 'package:servelq_agent/modules/service_agent/pages/components/action_buttons.dart';
import 'package:servelq_agent/modules/service_agent/pages/components/widgets.dart';

class MainPanel extends StatelessWidget {
  final ServiceAgentState state;

  const MainPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            if (state.currentToken?.mobileNumber != null &&
                state.currentTokenStatus == CurrentTokenStatus.loaded)
              _buildCurrentTokenInfo(state, context)
            else
              _buildEmptyState(context, state),
            const SizedBox(height: 28),
            ActionButtons(state: state),
            const SizedBox(height: 28),
            _buildHistoryPanel(state),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ServiceAgentState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add_check_circle_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            state.queue.isEmpty
                ? 'No tokens in queue'
                : 'Click "Call Next" to serve the next visitor',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTokenInfo(ServiceAgentState state, BuildContext context) {
    final token = state.currentToken!;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.offWhite.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Visitor',
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
                  label: 'Civil Id',
                  value: token.mobileNumber,
                  icon: AppImages.id,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: InfoField(
                  label: 'Service Type',
                  value: token.serviceName,
                  icon: AppImages.serviceType,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Notes / Documents',
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
              hintText: 'Add notes or attach documents...',
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

  Widget _buildHistoryPanel(ServiceAgentState state) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.offWhite.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Service History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.brownDarker,
            ),
          ),
          20.verticalSpace,
          ...state.recentServices.map(
            (history) => Container(
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
                            history.token,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                history.civilId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                history.service,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
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
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${history.time} mins',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
