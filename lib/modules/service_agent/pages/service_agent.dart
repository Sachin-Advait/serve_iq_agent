import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/common/widgets/flutter_toast.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
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

class _ServiceAgentScreenState extends State<ServiceAgentScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<ServiceAgentCubit>().loadInitialData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ServiceAgentCubit>().onAppResumed();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
              if (state.status == ServiceAgentStatus.error) {
                flutterToast(message: "An error occured");
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
                      // WebSocket status banner at the very top
                      const WebSocketStatusBanner(),

                      // Main content
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
                    message: 'An error occurred',
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

/// Widget to display WebSocket connection status
class WebSocketStatusBanner extends StatelessWidget {
  const WebSocketStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceAgentCubit, ServiceAgentState>(
      buildWhen: (previous, current) =>
          previous.webSocketStatus != current.webSocketStatus ||
          previous.webSocketErrorMessage != current.webSocketErrorMessage,
      builder: (context, state) {
        // Don't show banner if connected
        if (state.webSocketStatus == WebSocketStatus.connected) {
          return const SizedBox.shrink();
        }

        // Show connecting state
        if (state.webSocketStatus == WebSocketStatus.connecting) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.brownDark,
            child: Row(
              children: [
                SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Connecting to server...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Show error state
        if (state.webSocketStatus == WebSocketStatus.error) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.red.shade700,
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Connection Failed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (state.webSocketErrorMessage != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          state.webSocketErrorMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    context
                        .read<ServiceAgentCubit>()
                        .retryWebSocketConnection();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
