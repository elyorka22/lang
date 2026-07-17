import '../error/failures.dart';

/// Simple Result type without inheritance complexity.
class Result<T> {
  const Result._({this.data, this.failure});

  final T? data;
  final Failure? failure;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  factory Result.success([T? data]) => Result._(data: data);
  factory Result.failure(Failure failure) => Result._(failure: failure);

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    if (this.failure != null) {
      return failure(this.failure!);
    }
    return success(data as T);
  }
}
