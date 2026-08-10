import '../error/failure.dart';

/// 예외를 던지지 않고 성공/실패를 값으로 다룬다.
/// UseCase가 Result를 반환하면 화면은 try-catch 없이 when으로 분기하면 된다.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) =>
      switch (this) {
        Success<T>(:final data) => success(data),
        FailureResult<T>(:final error) => failure(error),
      };

  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;

  bool get isSuccess => this is Success<T>;
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class FailureResult<T> extends Result<T> {
  const FailureResult(this.error);
  final Failure error;
}
