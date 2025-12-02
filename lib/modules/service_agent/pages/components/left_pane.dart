import 'package:flutter/material.dart';
import 'package:servelq_agent/modules/service_agent/cubit/service_agent_cubit.dart';
import 'package:servelq_agent/modules/service_agent/pages/components/widgets.dart';

class LeftPane extends StatelessWidget {
  final ServiceAgentLoaded state;

  const LeftPane({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
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
                    color: Colors.blue,
                    icon: Icons.people_outline,
                  ),
                  const SizedBox(height: 16),
                  QueueCard(
                    label: 'Avg Wait Time',
                    value: "5", // Replace with actual calculation
                    color: Colors.teal,
                    icon: Icons.access_time,
                  ),
                  const SizedBox(height: 24),
                  if (state.currentToken != null) _buildCurrentTokenCard(state),
                  const SizedBox(height: 24),
                  _buildUpcomingTokens(state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTokenCard(ServiceAgentLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Token',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.currentToken!.token,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTokens(ServiceAgentLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Tokens',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...state.queue
            .take(3)
            .map(
              (token) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      token.token,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        token.serviceName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
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
}
