import 'package:monkey/monkey/token.dart';

class Lexer {
  final String _input;
  int _pos = 0;
  int _readPos = 0;
  String? _ch;

  Lexer(this._input) {
    _readChar();
  }

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
        var c = _ch;
        if (c == null) {
          throw 'Unreachable';
        }

        if (Lexer._isLatter(c)) {
          var literal = _readIdentifier();
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
    var pos = _pos;
    while (_ch != null) {
      var c = _ch;
      if (c == null) {
        throw 'Unreachable';
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
    var pos = _pos;
    while (_ch != null) {
      var c = _ch;
      if (c == null) {
        throw 'Unreachable';
      }
      if (!Lexer._isDigit(c)) {
        break;
      }

      _readChar();
    }

    return _readRange(pos, this._pos);
  }

  static bool _isLatter(String c) {
    if (c.length != 1) {
      throw 'expect $c to be a char.';
    }
    return RegExp(r'^[a-zA-Z_!?]$').hasMatch(c);
  }

  static bool _isDigit(String c) {
    if (c.length != 1) {
      throw 'expect $c to be a char.';
    }
    return RegExp(r'^[0-9]$').hasMatch(c);
  }

  StringLiteral _readString() {
    var pos = _pos + 1;
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

Token lookupIdent(String ident) {
  switch (ident) {
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
      return Ident(ident);
  }
}
