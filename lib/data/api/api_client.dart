import 'package:dio/dio.dart';

import '../../core/config.dart';
import '../../core/logger.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message, {this.body});
  final int? statusCode;
  final String message;
  final dynamic body;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

typedef TokenProvider = Future<String?> Function();
typedef UnauthorizedHandler = Future<void> Function();

class ApiClient {
  ApiClient({
    String? baseUrl,
    required TokenProvider tokenProvider,
    UnauthorizedHandler? onUnauthorized,
  })  : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? AppConfig.defaultApiBaseUrl,
          connectTimeout: AppConfig.apiTimeout,
          receiveTimeout: AppConfig.apiTimeout,
          sendTimeout: AppConfig.apiTimeout,
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenProvider();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        log.d('→ ${options.method} ${options.uri}');
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401 && onUnauthorized != null) {
          await onUnauthorized();
        }
        handler.next(e);
      },
    ));
  }

  final Dio _dio;

  String get baseUrl => _dio.options.baseUrl;
  set baseUrl(String url) => _dio.options.baseUrl = url;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return res.data;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<dynamic> post(String path, {Object? body}) async {
    try {
      final res = await _dio.post(path, data: body);
      return res.data;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<dynamic> put(String path, {Object? body}) async {
    try {
      final res = await _dio.put(path, data: body);
      return res.data;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  ApiException _wrap(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    String message = e.message ?? 'Network error';
    if (body is Map && body['message'] is String) {
      message = body['message'] as String;
    } else if (body is Map && body['error'] is String) {
      message = body['error'] as String;
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      message = 'Request timed out';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Cannot reach server';
    }
    return ApiException(status, message, body: body);
  }
}
