import 'failures.dart';

/// Result type for operations that can fail.
///
/// Services return `Result<T>`, never throw.
/// Providers map Result → DataState.
sealed class Result<T> {
  const Result();

  /// True if this is a successful result.
  bool get isSuccess => this is Success<T>;

  /// True if this is a failure result.
  bool get isFailure => this is Err<T>;

  /// Unwrap the success value or throw.
  /// Only use when you're certain of success.
  T get data => (this as Success<T>).value;

  /// Unwrap the failure or throw.
  Failure get failure => (this as Err<T>).error;

  /// Transform the success value.
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => Success(transform(v)),
      Err(error: final e) => Err(e),
    };
  }

  /// Execute a callback based on the result.
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success(value: final v) => success(v),
      Err(error: final e) => failure(e),
    };
  }
}

/// Successful result containing a value.
class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

/// Failed result containing a Failure.
class Err<T> extends Result<T> {
  const Err(this.error);
  final Failure error;
}
