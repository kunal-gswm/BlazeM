import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// Creates and configures the Dio HTTP client.
///
/// Single instance shared across all services via Riverpod.
Dio createApiClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    ErrorInterceptor(),
    LoggingInterceptor(),
  ]);

  return dio;
}
