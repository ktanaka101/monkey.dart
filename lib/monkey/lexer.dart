import 'package:monkey/monkey/error.dart';
import 'package:monkey/monkey/token.dart';

/// Lexer parse to tokens from inputed string
class Lexer {
  /// Lexer constructor
  Lexer(this._input) {
    _readChar();
  }

  final String _input;
  int _pos = 0;
  int _readPos = 0;
  String? _ch;

  /// Return next token.
  Token nextToken() {
    _skipWhitespace();

    Token? token;
    switch (_ch) {
      case null:
        token = Eof();
        break;
      case '=':
        switch (_peekChar()) {
          case '=':
            _readChar();
            token = Equal();
            break;
          default:
            token = Assign();
        }
        break;
      case '+':
        token = Plus();
        break;
      case '-':
        token = Minus();
        break;
      case '!':
        switch (_peekChar()) {
          case '=':
            _readChar();
            token = NotEqual();
            break;
          default:
            token = Bang();
        }
        break;
      case '*':
        token = Asterisk();
        break;
      case '/':
        token = Slash();
        break;
      case '<':
        token = Lt();
        break;
      case '>':
        token = Gt();
        break;
      case ',':
        token = Comma();
        break;
      case ';':
        token = Semicolon();
        break;
      case ':':
        token = Colon();
        break;
      case '(':
        token = Lparen();
        break;
      case ')':
        token = Rparen();
        break;
      case '{':
        token = Lbrace();
        break;
      case '}':
        token = Rbrace();
        break;
      case '[':
        token = Lbracket();
        break;
      case ']':
        token = Rbracket();
        break;
      case '"':
        token = _readString();
        break;
      default:
        final c = _ch;
        if (c == null) {
          throw MonkeyException('Unreachable');
        }

        if (Lexer._isLatter(c)) {
          final literal = _readIdentifier();
          return lookupIdent(literal);
        } else if (Lexer._isDigit(c)) {
          return Int(_readNumber());
        } else {
          token = Illegal(c);
        }
    }

    _readChar();

    return token;
  }

  String _readIdentifier() {
    final pos = _pos;
    while (_ch != null) {
      final c = _ch;
      if (c == null) {
        throw MonkeyException('Unreachable');
      }
      if (!Lexer._isLatter(c)) {
        break;
      }

      _readChar();
    }

    return _readRange(pos, _pos);
  }

  String _readRange(int s, int e) {
    return _input.substring(s, e);
  }

  String _readNumber() {
    final pos = _pos;
    while (_ch != null) {
      final c = _ch;
      if (c == null) {
        throw MonkeyException('Unreachable');
      }
      if (!Lexer._isDigit(c)) {
        break;
      }

      _readChar();
    }

    return _readRange(pos, _pos);
  }

  static bool _isLatter(String c) {
    if (c.length != 1) {
      throw MonkeyException('expect $c to be a char.');
    }
    return RegExp(r'^[a-zA-Z_!?]$').hasMatch(c);
  }

  static bool _isDigit(String c) {
    if (c.length != 1) {
      throw MonkeyException('expect $c to be a char.');
    }
    return RegExp(r'^[0-9]$').hasMatch(c);
  }

  StringLiteral _readString() {
    final pos = _pos + 1;
    while (_ch != null) {
      _readChar();

      if (_ch == '"') {
        break;
      }
    }

    return StringLiteral(_readRange(pos, _pos));
  }

  void _skipWhitespace() {
    while (_ch == ' ' || _ch == '\n') {
      _readChar();
    }
  }

  void _readChar() {
    _ch = _peekChar();
    _pos = _readPos;
    _readPos += 1;
  }

  String? _peekChar() {
    if (_readPos >= _input.length) {
      return null;
    } else {
      return _input[_readPos];
    }
  }
}

/// This function lookup ident from [string].
Token lookupIdent(String string) {
  switch (string) {
    case 'fn':
      return MFunction();
    case 'let':
      return Let();
    case 'true':
      return True();
    case 'false':
      return False();
    case 'if':
      return If();
    case 'else':
      return Else();
    case 'return':
      return Return();
    case 'macro':
      return Macro();
    default:
      return Ident(string);
  }
}
