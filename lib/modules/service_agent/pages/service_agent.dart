import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/configs/flutter_toast.dart';
import 'package:servelq_agent/modules/service_agent/cubit/service_agent_cubit.dart';
import 'package:servelq_agent/modules/service_agent/pages/components/bottom_bar.dart';
import 'package:servelq_agent/modules/service_agent/pages/components/error_screen.dart';
import 'package:servelq_agent/modules/service_agent/pages/components/header.dart';
import 'package:servelq_agent/modules/service_agent/pages/components/left_pane.dart';
import 'package:servelq_agent/modules/service_agent/pages/components/loading_screen.dart';
import 'package:servelq_agent/modules/service_agent/pages/components/main_panel.dart';

class ServiceAgentScreen extends StatefulWidget {
  const ServiceAgentScreen({super.key});

  @override
  State<ServiceAgentScreen> createState() => _ServiceAgentScreenState();
}

class _ServiceAgentScreenState extends State<ServiceAgentScreen> {
  Timer? _callNextTimer;

  @override
  void initState() {
    super.initState();
    // Load initial data when screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceAgentCubit>().loadInitialData();
      final cubit = context.read<ServiceAgentCubit>();

      _startAutoCallNext(cubit);
    });
  }

  void _startAutoCallNext(ServiceAgentCubit cubit) {
    _callNextTimer?.cancel();
    _callNextTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final currentState = cubit.state;
      if (currentState is ServiceAgentLoaded) {
        await cubit.queueAPI();
      }
    });
  }

  @override
  void dispose() {
    _callNextTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceAgentCubit, ServiceAgentState>(
      listener: (context, state) {
        if (state is ServiceAgentError) {
          flutterToast(message: state.message);
        }
      },
      child: BlocBuilder<ServiceAgentCubit, ServiceAgentState>(
        builder: (context, state) {
          if (state is ServiceAgentInitial || state is ServiceAgentLoading) {
            return const LoadingScreen();
          }

          if (state is ServiceAgentLoaded) {
            return _buildLoadedScreen(context, state);
          }

          if (state is ServiceAgentError) {
            return ErrorScreen(
              message: state.message,
              onRetry: () =>
                  context.read<ServiceAgentCubit>().loadInitialData(),
            );
          }

          return const LoadingScreen();
        },
      ),
    );
  }

  Widget _buildLoadedScreen(BuildContext context, ServiceAgentLoaded state) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          Header(state: state),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 320, child: LeftPane(state: state)),
                Expanded(child: MainPanel(state: state)),
              ],
            ),
          ),
          const BottomBar(),
        ],
      ),
    );
  }
}
