import 'package:meta/meta.dart';

@immutable
abstract class Token {
  @override
  bool operator ==(Object other) =>
      identical(other, this) ||
      other is Token && runtimeType == other.runtimeType;

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}

/// This is [Token] for string including
@immutable
abstract class StringToken extends Token {
  StringToken(this.value);

  /// string value
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(other, this) ||
      other is StringToken && runtimeType == other.runtimeType && v == other.v;

  @override
  int get hashCode => v.hashCode;
}

@immutable
class Illegal extends StringToken {
  Illegal(String v) : super(v);
}

@immutable
class Eof extends Token {}

@immutable
class Ident extends StringToken {
  Ident(String v) : super(v);
}

@immutable
class Int extends StringToken {
  Int(String v) : super(v);
}

@immutable
class StringLiteral extends StringToken {
  StringLiteral(String v) : super(v);
}

@immutable
class Assign extends Token {}

@immutable
class Plus extends Token {}

@immutable
class Minus extends Token {}

@immutable
class Bang extends Token {}

@immutable
class Asterisk extends Token {}

@immutable
class Slash extends Token {}

@immutable
class Equal extends Token {}

@immutable
class NotEqual extends Token {}

@immutable
class Lt extends Token {}

@immutable
class Gt extends Token {}

@immutable
class Comma extends Token {}

@immutable
class Semicolon extends Token {}

@immutable
class Colon extends Token {}

@immutable
class Lparen extends Token {}

@immutable
class Rparen extends Token {}

@immutable
class Lbrace extends Token {}

@immutable
class Rbrace extends Token {}

@immutable
class Lbracket extends Token {}

@immutable
class Rbracket extends Token {}

@immutable
class MFunction extends Token {}

@immutable
class Let extends Token {}

@immutable
class True extends Token {}

@immutable
class False extends Token {}

@immutable
class If extends Token {}

@immutable
class Else extends Token {}

@immutable
class Return extends Token {}

@immutable
class Macro extends Token {}
