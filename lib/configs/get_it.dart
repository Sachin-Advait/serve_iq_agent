import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:servelq_agent/configs/api_constants.dart';
import 'package:servelq_agent/modules/login/bloc/login_bloc.dart';
import 'package:servelq_agent/modules/login/repository/auth_repo.dart';
import 'package:servelq_agent/modules/service_agent/cubit/service_agent_cubit.dart';
import 'package:servelq_agent/modules/service_agent/repository/agent_repo.dart';
import 'package:servelq_agent/modules/splash/bloc/splash_bloc.dart';
import 'package:servelq_agent/services/api_client.dart';

final getIt = GetIt.instance;

void getItSetup() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (kDebugMode) {
          if (options.data is FormData) {
            FormData d = options.data;
            d.fields.forEach(
              ((field) => debugPrint('Fields: ${field.key}: ${field.value}')),
            );
            for (var field in d.files) {
              debugPrint(
                'Files: ${field.key}: ${field.value.filename} ${field.value.contentType?.mimeType}',
              );
            }
          }
        }
        return handler.next(options);
      },
    ),
  );

  // Add logging interceptor with debug check.
  dio.interceptors.add(
    LogInterceptor(
      request: kDebugMode,
      error: kDebugMode,
      responseHeader: kDebugMode,
      requestBody: kDebugMode,
      requestHeader: kDebugMode,
      responseBody: kDebugMode,
    ),
  );
  getIt.registerSingleton<ApiClient>(ApiClient(dio: dio));

  getIt.registerFactory<SplashBloc>(() => SplashBloc());

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<ApiClient>()),
  );

  getIt.registerFactory<LoginBloc>(() => LoginBloc(getIt<AuthRepository>()));

  getIt.registerLazySingleton<AgentRepository>(
    () => AgentRepository(getIt<ApiClient>()),
  );

  getIt.registerFactory<ServiceAgentCubit>(
    () => ServiceAgentCubit(getIt<AgentRepository>()),
  );
}

void resetGetIt() {
  getIt.reset(dispose: false);
  getItSetup();
}
