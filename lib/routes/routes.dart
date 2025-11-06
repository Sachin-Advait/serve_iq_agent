// Router Configuration
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/modules/login/login.dart';
import 'package:servelq_agent/modules/service_agent/pages/service_agent.dart';
import 'package:servelq_agent/modules/tv_display/pages/tv_display.dart';

class AppRoutes {
  static GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/agent',
        builder: (context, state) => const ServiceAgentScreen(),
      ),
      GoRoute(
        path: '/display',
        builder: (context, state) => const TVDisplayScreen(),
      ),
    ],
  );
}
