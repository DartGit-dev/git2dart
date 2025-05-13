/// Represents an error that occurred in Git2Dart library.
class Git2DartError implements Error {
  /// Creates a new instance of [Git2DartError] with the given error message.
  Git2DartError(this.message);

  /// The error message associated with this error.
  final String message;

  @override
  StackTrace? get stackTrace => StackTrace.current;

  @override
  String toString() => message;
}
