import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/common/widgets/flutter_toast.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/modules/service_agent/cubit/service_agent_cubit.dart';
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
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Load initial data when screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceAgentCubit>().loadInitialData();
      final cubit = context.read<ServiceAgentCubit>();

      _startPolling(cubit);
    });
  }

  void _startPolling(ServiceAgentCubit cubit) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      final currentState = cubit.state;
      if (currentState.status == ServiceAgentStatus.loaded) {
        await cubit.queueAPI();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.bg01Png),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: BlocListener<ServiceAgentCubit, ServiceAgentState>(
            listener: (context, state) {
              if (state.status == ServiceAgentStatus.error &&
                  state.errorMessage != null) {
                flutterToast(message: state.errorMessage!);
              }
            },
            child: BlocBuilder<ServiceAgentCubit, ServiceAgentState>(
              builder: (context, state) {
                if (state.status == ServiceAgentStatus.initial ||
                    state.status == ServiceAgentStatus.loading) {
                  return const LoadingScreen();
                }

                if (state.status == ServiceAgentStatus.loaded) {
                  return Column(
                    children: [
                      Header(state: state),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 320, child: LeftPane()),
                            Expanded(child: MainPanel(state: state)),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                if (state.status == ServiceAgentStatus.error) {
                  return ErrorScreen(
                    message: state.errorMessage ?? 'An error occurred',
                    onRetry: () =>
                        context.read<ServiceAgentCubit>().loadInitialData(),
                  );
                }

                return const LoadingScreen();
              },
            ),
          ),
        ),
      ),
    );
  }
}
