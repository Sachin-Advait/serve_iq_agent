import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.chat_bubble_outline, size: 20),
            label: const Text('Chat with Admin'),
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.trending_up, size: 20),
            label: const Text('Service Performance'),
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.logout, size: 20),
            label: const Text('Logout'),
            onPressed: () => context.go('/'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}
