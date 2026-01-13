import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
        if (e.response?.statusCode == 401) {
          // Do Nothing
        } else if (e.response?.statusCode == 400) {
          // Do Nothing
        } else {
          flutterToast(message: AppErrors.serverErrorDetails);
        }
        break;

      //  if (statusCode == 401) {
      //   // Optional: logout / refresh token
      // } else if (statusCode == 400) {
      //   final message = responseData is Map && responseData['message'] != null
      //       ? responseData['message'].toString()
      //       : AppErrors.unknownErrorDetails;

      //   flutterToast(message: message, color: AppColors.red);
      // } else {
      //   flutterToast(
      //     message: AppErrors.serverErrorDetails,
      //     color: AppColors.red,
      //   );
      // }
      // break;

      default:
        flutterToast(
          message: AppErrors.unknownErrorDetails,
          color: AppColors.red,
        );
        break;
    }
    return null;
  }
}
