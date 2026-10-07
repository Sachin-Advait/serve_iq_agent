import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:servelq_agent/common/constants/api_constants.dart';
import 'package:servelq_agent/common/constants/app_errors.dart';
import 'package:servelq_agent/common/widgets/flutter_toast.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({required Dio dio}) : _dio = dio;

  Future<Response?> getApi(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    Response? response;
    try {
      response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _showErrorSnackbar(e);
    }
    return response;
  }

  /// Common POST
  Future<Response?> postApi(
    String path, {
    dynamic body,
    dynamic queryPara,
  }) async {
    Response? response;

    try {
      response = await _dio.post(path, data: body, queryParameters: queryPara);
    } on DioException catch (e) {
      _showErrorSnackbar(e);
    }

    return response;
  }

  // 🔹 Error handlers
  String? _showErrorSnackbar(DioException e) {
    debugPrint('API ERROR ===> $e');
    switch (e.type) {
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionTimeout:
        flutterToast(message: AppErrors.serverTimeoutErrorDetails);
        break;

      case DioExceptionType.connectionError:
        if (e.error is SocketException) {
          flutterToast(message: AppErrors.noInternetDetails);
        }
        break;

      case DioExceptionType.badResponse:
        //   if (e.response?.statusCode == 401) {
        //     // Do Nothing
        //   } else if (e.response?.statusCode == 400) {
        //     // Do Nothing
        //   } else {
        //     flutterToast(message: AppErrors.serverErrorDetails);
        //   }
        //   break;

        if (e.response?.statusCode == 403) {
          // SessionManager.clearSession();
          // Pages.router.goNamed(Routes.login);
        } else if (e.response?.statusCode == 400 ||
            e.response?.statusCode == 409) {
          // 409 is a business rule the backend refused (e.g. a token still
          // in progress); show its message instead of a generic server error.
          flutterToast(
            message: _backendMessage(e.response?.data),
            color: AppColors.red,
          );
        } else if (e.response?.statusCode == 401 &&
            e.requestOptions.path == ApiConstants.login) {
          flutterToast(
            message: 'Invalid email or password',
            color: AppColors.red,
          );
        } else if (e.response?.statusCode == 404) {
        } else {
          flutterToast(
            message: AppErrors.serverErrorDetails,
            color: AppColors.red,
          );
        }
        break;

      default:
        flutterToast(
          message: AppErrors.unknownErrorDetails,
          color: AppColors.red,
        );
        break;
    }
    return null;
  }

  // The backend sends either an ApiResponseDTO map or a plain string body.
  String _backendMessage(dynamic data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return AppErrors.unknownErrorDetails;
  }
}
