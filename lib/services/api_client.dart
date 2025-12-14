import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:servelq_agent/common/constants/app_errors.dart';
import 'package:servelq_agent/common/widgets/flutter_toast.dart';

/// 🔹 This replaces ApiClient — directly use this for network calls.
class ApiClient {
  final Dio _dio;

  ApiClient({required Dio dio}) : _dio = dio;

  /// Common GET
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
    // _showErrorSnackbarWhenStatusCodeIs200(response);
    return response;
  }

  /// Common POST
  Future<Response?> postApi(
    String path, {
    dynamic body,
    bool showLoader = true,
    dynamic queryPara,
  }) async {
    // if (showLoader) customLoader();
    Response? response;

    // try {
    response = await _dio.post(path, data: body, queryParameters: queryPara);
    // } on DioException catch (e) {
    //   _showErrorSnackbar(e);
    // } finally {
    //   // EasyLoading.dismiss();
    // }

    // _showErrorSnackbarWhenStatusCodeIs200(response);
    return response;
  }

  /// Common MULTIPART POST
  Future<Response?> postMultipartApi(
    String path, {
    FormData? formData,
    void Function(int, int)? onSendProgress,
    Options? options,
    bool showLoader = true,
    bool showToast = true,
  }) async {
    // if (showLoader) customLoader();
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
    } finally {
      // EasyLoading.dismiss();
    }

    // if (showToast) _showErrorSnackbarWhenStatusCodeIs200(response);
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
          // _logoutAndShowTokenExpiryPopup();
        } else if (e.response?.statusCode == 400) {
          // final errorData = e.response!.data;
          // final errorMessage = errorData is Map<String, dynamic>
          //     ? (errorData['message'] ??
          //           e.response!.statusMessage ??
          //           'Bad Request')
          //     : e.response!.statusMessage ?? 'Bad Request';

          // flutterToast(message: errorMessage);
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

  // void _showErrorSnackbarWhenStatusCodeIs200(Response? response) {
  //   if (response != null) {
  //     final commonResponse = CommonResponse.fromJson(response.data);
  //     if (commonResponse.status == false) {
  //       flutterToast(
  //         message: commonResponse.message ?? AppErrors.unknownErrorDetails,
  //       );
  //     }
  //   }
  // }
}
