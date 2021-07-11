abstract class Token {
  @override
  bool operator ==(Object other) =>
      identical(other, this) ||
      other is Token && runtimeType == other.runtimeType;
}

abstract class StringToken extends Token {
  String v;
  StringToken(this.v);

  @override
  bool operator ==(Object other) =>
      identical(other, this) ||
      other is StringToken && runtimeType == other.runtimeType && v == other.v;

  @override
  int get hashCode => v.hashCode;
}

class Illegal extends StringToken {
  Illegal(String v) : super(v);
}

class Eof extends Token {}

class Ident extends StringToken {
  Ident(String v) : super(v);
}

class Int extends StringToken {
  Int(String v) : super(v);
}

class StringLiteral extends StringToken {
  StringLiteral(String v) : super(v);
}

class Assign extends Token {}

class Plus extends Token {}

class Minus extends Token {}

class Bang extends Token {}

class Asterisk extends Token {}

class Slash extends Token {}

class Equal extends Token {}

class NotEqual extends Token {}

class Lt extends Token {}

class Gt extends Token {}

class Comma extends Token {}

class Semicolon extends Token {}

class Colon extends Token {}

class Lparen extends Token {}

class Rparen extends Token {}

class Lbrace extends Token {}

class Rbrace extends Token {}

class Lbracket extends Token {}

class Rbracket extends Token {}

class MFunction extends Token {}

class Let extends Token {}

class True extends Token {}

class False extends Token {}

class If extends Token {}

class Else extends Token {}

class Return extends Token {}

class Macro extends Token {}
