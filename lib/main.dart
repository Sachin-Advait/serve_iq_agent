import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/common/constants/app_strings.dart';
import 'package:servelq_agent/common/utils/app_screen_util.dart';
import 'package:servelq_agent/common/utils/get_it.dart';
import 'package:servelq_agent/configs/theme/app_theme.dart';
import 'package:servelq_agent/modules/home/cubit/home_cubit.dart';
import 'package:servelq_agent/routes/pages.dart';
import 'package:servelq_agent/services/firebase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setUrlStrategy(PathUrlStrategy());
  GoRouter.optionURLReflectsImperativeAPIs = true;
  GetStorage.init();
  getItSetup();

  // Adding Firebase configuration utils
  await Firebase.initializeApp(options: FirebaseConfig.web);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeCubit>(),
      child: LayoutBuilder(
        builder: (context, constraints) => ScreenUtilInit(
          designSize: Size(constraints.maxWidth, constraints.maxHeight),
          minTextAdapt: true,
          ensureScreenSize: true,
          splitScreenMode: true,
          builder: (context, child) {
            final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

            AppScreenUtil().init(constraints);

            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(isTablet ? 1.2 : 1.0)),
              child: MaterialApp.router(
                routerConfig: Pages.router,
                title: AppStrings.appTitle,
                debugShowCheckedModeBanner: false,
                builder: EasyLoading.init(),
                theme: AppThemes.lightTheme,
              ),
            );
          },
        ),
      ),
    );
  }
}
