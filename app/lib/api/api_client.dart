import 'package:dio/dio.dart';

import '../core/app_config.dart';
import '../core/storage.dart';

class ApiClient {
  ApiClient._() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStore.token();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final path = error.requestOptions.path;
          final isAuthRequest =
              path == '/auth/login' || path == '/auth/register';
          if (error.response?.statusCode == 401 && !isAuthRequest) {
            await onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  static final instance = ApiClient._();
  Future<void> Function()? onUnauthorized;
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBase,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );
}

String apiErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      return (data['message'] ?? data['error'] ?? 'Request failed').toString();
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return 'Cannot connect to TryHub. Check the server address and connection.';
    }
    return error.message ?? 'Request failed';
  }
  return 'Something went wrong. Please try again.';
}
