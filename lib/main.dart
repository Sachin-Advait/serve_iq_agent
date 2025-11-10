import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/configs/get_it.dart';
import 'package:servelq_agent/configs/lang/cubit/localization_cubit.dart';
import 'package:servelq_agent/modules/service_agent/cubit/service_agent_cubit.dart';
import 'package:servelq_agent/modules/tv_display/cubit/tv_display_cubit.dart';
import 'package:servelq_agent/routes/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setUrlStrategy(PathUrlStrategy());
  GoRouter.optionURLReflectsImperativeAPIs = true;

  getItSetup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LocalizationCubit()),
        BlocProvider(create: (_) => ServiceAgentCubit()),
        BlocProvider(create: (_) => TVDisplayCubit()),
      ],
      child: BlocBuilder<LocalizationCubit, LocalizationState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'ServelQ',
            theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
            routerConfig: AppRoutes.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
