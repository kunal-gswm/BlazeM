/// Data state envelope used by all providers.
///
/// Every screen consumes `DataState<T>`, never raw `T`.
/// This ensures stale indicators and error states are always handled.
sealed class DataState<T> {
  const DataState();

  /// Initial load, no data available yet.
  const factory DataState.loading() = DataLoading;

  /// Data is within TTL — render normally.
  const factory DataState.fresh(T data, DateTime fetchedAt) = DataFresh;

  /// Data is past TTL — render with stale indicator, refresh in background.
  const factory DataState.stale(T data, DateTime fetchedAt) = DataStale;

  /// Error occurred. May have last-known data.
  const factory DataState.error(String message, {T? lastData}) = DataError;

  /// Whether there is any data to display (fresh, stale, or error with fallback).
  bool get hasData => switch (this) {
    DataFresh() => true,
    DataStale() => true,
    DataError(lastData: final d) => d != null,
    DataLoading() => false,
  };

  /// Get the displayable data if available.
  T? get displayData => switch (this) {
    DataFresh(data: final d) => d,
    DataStale(data: final d) => d,
    DataError(lastData: final d) => d,
    DataLoading() => null,
  };

  /// Execute a callback based on state.
  R when<R>({
    required R Function() loading,
    required R Function(T data, DateTime fetchedAt) fresh,
    required R Function(T data, DateTime fetchedAt) stale,
    required R Function(String message, T? lastData) error,
  }) {
    return switch (this) {
      DataLoading() => loading(),
      DataFresh(data: final d, fetchedAt: final f) => fresh(d, f),
      DataStale(data: final d, fetchedAt: final f) => stale(d, f),
      DataError(message: final m, lastData: final d) => error(m, d),
    };
  }

  /// Execute a callback, collapsing fresh and stale into a single "data" case.
  R maybeWhen<R>({
    R Function()? loading,
    R Function(T data, DateTime fetchedAt, bool isStale)? data,
    R Function(String message, T? lastData)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      DataLoading() => loading?.call() ?? orElse(),
      DataFresh(data: final d, fetchedAt: final f) =>
        data?.call(d, f, false) ?? orElse(),
      DataStale(data: final d, fetchedAt: final f) =>
        data?.call(d, f, true) ?? orElse(),
      DataError(message: final m, lastData: final d) =>
        error?.call(m, d) ?? orElse(),
    };
  }
}

class DataLoading<T> extends DataState<T> {
  const DataLoading();
}

class DataFresh<T> extends DataState<T> {
  const DataFresh(this.data, this.fetchedAt);
  final T data;
  final DateTime fetchedAt;
}

class DataStale<T> extends DataState<T> {
  const DataStale(this.data, this.fetchedAt);
  final T data;
  final DateTime fetchedAt;
}

class DataError<T> extends DataState<T> {
  const DataError(this.message, {this.lastData});
  final String message;
  final T? lastData;
}
