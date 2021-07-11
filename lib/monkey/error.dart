/// Monkey exception
class MonkeyException implements Exception {
  /// constructor
  MonkeyException(this.msg);

  /// exception message
  final String msg;

  /// Instance to string.
  @override
  String toString() => 'MonkeyException: $msg';
}
