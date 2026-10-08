import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:servelq_agent/common/constants/api_constants.dart';
import 'package:servelq_agent/common/constants/app_errors.dart';
import 'package:servelq_agent/common/widgets/flutter_toast.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/routes/pages.dart';
import 'package:servelq_agent/services/session_manager.dart';
import 'package:servelq_agent/services/web_socket_service.dart';

/// Thrown by repositories when a request failed and ApiClient has already
/// shown the backend's reason, so callers must not add a generic toast on top.
class ApiErrorShown implements Exception {
  @override
  String toString() => 'API error already shown to the user';
}

class ApiClient {
  final Dio _dio;

  // Set once a revoked login has sent the agent to the login page, so parallel
  // failing requests don't redirect and toast repeatedly. Reset on login.
  static bool sessionEnded = false;

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

        if (e.response?.statusCode == 403 ||
            (e.response?.statusCode == 401 &&
                e.requestOptions.path != ApiConstants.login)) {
          // Login revoked (e.g. admin force-released the counter): clear the
          // session and go to login instead of leaving the agent stuck.
          if (!sessionEnded) {
            sessionEnded = true;
            WebSocketService.disconnect();
            SessionManager.clearSession();
            flutterToast(
              message: 'Your session has ended. Please log in again.',
              color: AppColors.red,
            );
            Pages.router.goNamed(Routes.login);
          }
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
          // GET lookups 404 quietly; a failed action (e.g. call next with an
          // empty queue: "No tokens available") shows the backend's reason.
          if (e.requestOptions.method == 'POST') {
            flutterToast(
              message: _backendMessage(e.response?.data),
              color: AppColors.red,
            );
          }
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
