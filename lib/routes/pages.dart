// Router Configuration
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/common/utils/get_it.dart';
import 'package:servelq_agent/common/utils/global_keys.dart';
import 'package:servelq_agent/modules/home/pages/home_page.dart';
import 'package:servelq_agent/modules/login/bloc/login_bloc.dart';
import 'package:servelq_agent/modules/login/pages/login_page.dart';
import 'package:servelq_agent/modules/participate/cubit/participate_cubit.dart';
import 'package:servelq_agent/modules/participate/pages/participate_page.dart';
import 'package:servelq_agent/modules/quiz/cubit/quiz_cubit.dart';
import 'package:servelq_agent/modules/quiz/pages/quiz_page.dart';
import 'package:servelq_agent/modules/quiz_result/bloc/quiz_result_bloc.dart';
import 'package:servelq_agent/modules/quiz_result/pages/quiz_result_page.dart';
import 'package:servelq_agent/modules/training/cubit/training_cubit.dart';
import 'package:servelq_agent/modules/training/pages/training.dart';
import 'package:servelq_agent/routes/not_found.dart';
import 'package:servelq_agent/services/session_manager.dart';

part 'routes.dart';

class Pages {
  static GoRouter router = GoRouter(
    initialLocation: Routes.login,
    navigatorKey: GlobalKeys.navigatorKey,
    errorBuilder: (context, state) => NotFound(state: state),
    redirect: (context, state) {
      final token = SessionManager.getToken();

      // If user already logged in, redirect from login to agent
      if (token.isNotEmpty && state.matchedLocation == '/login') {
        return Routes.agent;
      }

      // If user is not logged in, block access to /agent
      if (token.isEmpty && state.matchedLocation == '/agent') {
        return Routes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        name: Routes.login,
        builder: (_, state) => BlocProvider(
          create: (context) => getIt<LoginBloc>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: Routes.agent,
        name: Routes.agent,
        builder: (_, state) => const HomePage(),
        routes: [
          GoRoute(
            path: Routes.quiz,
            name: Routes.quiz,
            builder: (_, state) => BlocProvider(
              create: (context) => getIt<QuizCubit>(),
              child: const QuizPage(),
            ),
          ),

          GoRoute(
            path: '${Routes.participate}/:quizId/:isMandatory',
            name: Routes.participate,
            builder: (_, state) {
              final quizId = state.pathParameters['quizId']!;
              final isMandatory = state.pathParameters['isMandatory'] == 'true';

              return BlocProvider(
                create: (context) => getIt<ParticipateCubit>(),
                child: ParticipatePage(
                  isMandatory: isMandatory,
                  quizId: quizId,
                ),
              );
            },
          ),
          GoRoute(
            path: Routes.result,
            name: Routes.result,
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>;
              return BlocProvider(
                create: (context) => getIt<QuizResultBloc>(),
                child: QuizResultPage(
                  quizId: extra["quizId"],
                  title: extra["title"],
                ),
              );
            },
          ),
          GoRoute(
            path: Routes.training,
            name: Routes.training,
            builder: (_, state) => BlocProvider(
              create: (context) => getIt<TrainingCubit>(),
              child: const Training(contentId: ''),
            ),
          ),
        ],
      ),
    ],
  );
}
