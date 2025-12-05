// Router Configuration
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/configs/get_it.dart';
import 'package:servelq_agent/configs/global_keys.dart';
import 'package:servelq_agent/modules/login/bloc/login_bloc.dart';
import 'package:servelq_agent/modules/login/pages/login.dart';
import 'package:servelq_agent/modules/service_agent/cubit/service_agent_cubit.dart';
import 'package:servelq_agent/modules/service_agent/pages/service_agent.dart';
import 'package:servelq_agent/routes/not_found.dart';
import 'package:servelq_agent/services/session_manager.dart';

class AppRoutes {
  static GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: GlobalKeys.navigatorKey,
    errorBuilder: (context, state) => NotFound(state: state),
    redirect: (context, state) {
      final token = SessionManager.getToken();

      // If user already logged in, redirect from login to agent
      if (token.isNotEmpty && state.matchedLocation == '/') {
        return '/agent';
      }

      // If user is not logged in, block access to /agent
      if (token.isEmpty && state.matchedLocation == '/agent') {
        return '/';
      }

      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, state) => BlocProvider(
          create: (context) => getIt<LoginBloc>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/agent',
        builder: (_, state) => BlocProvider(
          create: (context) => getIt<ServiceAgentCubit>(),
          child: const ServiceAgentScreen(),
        ),
      ),
    ],
  );
}
