import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/modules/service_agent/cubit/service_agent_cubit.dart';
import 'package:servelq_agent/services/session_manager.dart';

class Header extends StatelessWidget {
  final ServiceAgentState state;

  const Header({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final branch = state.counter;
    final displayText = '${branch?.name} - ${branch?.code}';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(AppImages.logo),
              ),
              const SizedBox(width: 16),
              Text(
                displayText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'Agent: ${SessionManager.getUsername()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.circle,
                      color: Color(0xFF86EFAC),
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Online',
                      style: TextStyle(color: Color(0xFF86EFAC), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () {},
                iconSize: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
