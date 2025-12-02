import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
import 'package:servelq_agent/configs/get_it.dart';
import 'package:servelq_agent/configs/lang/cubit/localization_cubit.dart';
import 'package:servelq_agent/routes/routes.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WakelockPlus.enable();

  // setUrlStrategy(PathUrlStrategy());
  // GoRouter.optionURLReflectsImperativeAPIs = true;
  GetStorage.init();
  getItSetup();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocalizationCubit(),
      child: BlocBuilder<LocalizationCubit, LocalizationState>(
        builder: (context, state) {
          return MaterialApp.router(
            builder: EasyLoading.init(),
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
