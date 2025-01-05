/// Generic klasa za rezultate operacija
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  /// Kreira uspešan rezultat
  factory Result.success([T? data]) {
    return Result._(
      data: data,
      isSuccess: true,
    );
  }

  /// Kreira rezultat sa greškom
  factory Result.failure(String error) {
    return Result._(
      error: error,
      isSuccess: false,
    );
  }

  /// Bezbedno uzima data ili baca exception
  T requireData() {
    if (data == null) {
      throw Exception('Data is null');
    }
    return data!;
  }
}
