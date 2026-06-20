import 'package:dio/dio.dart';
import '../../error/failures.dart';

/// Maps DioExceptions to typed Failures.
///
/// After this interceptor, downstream code never sees raw DioException.
/// Services catch Failure types only.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = _mapToFailure(err);

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: failure,
        message: failure.message,
      ),
    );
  }

  Failure _mapToFailure(DioException err) {
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutFailure(),

      DioExceptionType.connectionError =>
        const NetworkFailure(),

      DioExceptionType.badResponse => _mapStatusCode(
          err.response?.statusCode,
          err.response?.data,
        ),

      _ => UnexpectedFailure(err),
    };
  }

  Failure _mapStatusCode(int? statusCode, dynamic data) {
    return switch (statusCode) {
      404 => const NotFoundFailure(),
      400 => BadRequestFailure(
          _extractMessage(data) ?? 'Bad request',
        ),
      final code? when code >= 500 => ServerFailure(code, 'Server error ($code)'),
      _ => ServerFailure(statusCode ?? 0, 'Unexpected status: $statusCode'),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        return error['message'] as String?;
      }
    }
    return null;
  }
}
