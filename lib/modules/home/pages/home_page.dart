import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/common/widgets/flutter_toast.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/modules/home/cubit/home_cubit.dart';
import 'package:servelq_agent/modules/home/pages/components/error_screen.dart';
import 'package:servelq_agent/modules/home/pages/components/header.dart';
import 'package:servelq_agent/modules/home/pages/components/left_pane.dart';
import 'package:servelq_agent/modules/home/pages/components/loading_screen.dart';
import 'package:servelq_agent/modules/home/pages/components/main_panel.dart';
import 'package:servelq_agent/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    initialize();
    WidgetsBinding.instance.addObserver(this);
    context.read<HomeCubit>().loadInitialData();
    super.initState();
  }

  void initialize() async {
    await NotificationService.instance.init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HomeCubit>().onAppResumed();
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
          body: BlocListener<HomeCubit, HomeState>(
            listener: (context, state) {
              if (state.status == HomeStatus.error) {
                flutterToast(message: "An error occurred");
              }
              // Handle network connection changes
              if (!state.isNetworkConnected &&
                  state.status == HomeStatus.loaded) {
                flutterToast(
                  message: "No internet connection",
                  color: AppColors.darkRed,
                );
              }
            },
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state.status == HomeStatus.initial ||
                    state.status == HomeStatus.loading) {
                  return LoadingScreen(title: 'Loading Agent Dashboard...');
                }

                if (state.status == HomeStatus.loaded) {
                  return Column(
                    children: [
                      // Network status banner
                      const NetworkStatusBanner(),

                      // WebSocket status banner
                      const WebSocketStatusBanner(),

                      // Main content
                      Header(),
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

                if (state.status == HomeStatus.error) {
                  return ErrorScreen(
                    message: 'An error occurred',
                    onRetry: () => context.read<HomeCubit>().loadInitialData(),
                  );
                }

                return LoadingScreen(title: "Loading Agent Dashboard...");
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget to display network connection status
class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.isNetworkConnected != current.isNetworkConnected,
      builder: (context, state) {
        // Don't show banner if connected
        if (state.isNetworkConnected) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.orange.shade700,
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'No Internet Connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  context.read<HomeCubit>().checkNetworkStatus();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Check Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget to display WebSocket connection status
class WebSocketStatusBanner extends StatelessWidget {
  const WebSocketStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.webSocketStatus != current.webSocketStatus ||
          previous.webSocketErrorMessage != current.webSocketErrorMessage ||
          previous.isNetworkConnected != current.isNetworkConnected,
      builder: (context, state) {
        // Don't show banner if connected
        if (state.webSocketStatus == WebSocketStatus.connected) {
          return const SizedBox.shrink();
        }

        // Don't show WebSocket banner if there's no network
        if (!state.isNetworkConnected) {
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
                        'Server Connection Failed',
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
                    context.read<HomeCubit>().retryWebSocketConnection();
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
