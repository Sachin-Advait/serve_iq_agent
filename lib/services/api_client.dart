import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:servelq_agent/common/constants/app_errors.dart';
import 'package:servelq_agent/common/widgets/flutter_toast.dart';

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

  Future<Response?> postMultipartApi(
    String path, {
    FormData? formData,
    void Function(int, int)? onSendProgress,
    Options? options,
    bool showLoader = true,
    bool showToast = true,
  }) async {
    Response? response;

    try {
      response = await _dio.post(
        path,
        options: options,
        data: formData,
        onSendProgress: onSendProgress,
      );
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

      default:
        flutterToast(message: AppErrors.unknownErrorDetails);
        break;
    }
    return null;
  }
}
