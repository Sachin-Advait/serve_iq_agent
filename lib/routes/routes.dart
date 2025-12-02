// Router Configuration
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/configs/get_it.dart';
import 'package:servelq_agent/modules/login/bloc/login_bloc.dart';
import 'package:servelq_agent/modules/login/pages/login.dart';
import 'package:servelq_agent/modules/login/repository/auth_repo.dart';
import 'package:servelq_agent/modules/service_agent/cubit/service_agent_cubit.dart';
import 'package:servelq_agent/modules/service_agent/pages/service_agent.dart';

class AppRoutes {
  static GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, state) => BlocProvider(
          create: (context) => LoginBloc(getIt<AuthRepository>()),
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
