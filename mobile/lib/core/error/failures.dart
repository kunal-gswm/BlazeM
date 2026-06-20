/// Failure types for the application.
///
/// Every error that crosses a service boundary is one of these.
/// Raw exceptions never leak past the service layer.
sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Device is offline or request timed out.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Request timed out.
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out']);
}

/// Backend returned 5xx.
class ServerFailure extends Failure {
  const ServerFailure(this.statusCode, [super.message = 'Server error']);
  final int statusCode;
}

/// Backend returned 404.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

/// Backend returned 400 or validation error.
class BadRequestFailure extends Failure {
  const BadRequestFailure([super.message = 'Bad request']);
}

/// sqflite read/write error.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

/// Catch-all for unexpected errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(this.error, [super.message = 'Unexpected error']);
  final Object error;
}
