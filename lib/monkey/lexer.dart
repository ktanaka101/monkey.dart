import 'package:monkey/monkey/token.dart';

class Lexer {
  String input;
  int pos = 0;
  int readPos = 0;
  String? ch;

  Lexer(this.input) {
    _readChar();
  }

  Token nextToken() {
    _skipWhitespace();

    Token? token;
    switch (ch) {
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
        var c = ch;
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
    var pos = this.pos;
    while (ch != null) {
      var c = ch;
      if (c == null) {
        throw 'Unreachable';
      }
      if (!Lexer._isLatter(c)) {
        break;
      }

      _readChar();
    }

    return _readRange(pos, this.pos);
  }

  String _readRange(int s, int e) {
    return input.substring(s, e);
  }

  String _readNumber() {
    var pos = this.pos;
    while (ch != null) {
      var c = ch;
      if (c == null) {
        throw 'Unreachable';
      }
      if (!Lexer._isDigit(c)) {
        break;
      }

      _readChar();
    }

    return _readRange(pos, this.pos);
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
    var pos = this.pos + 1;
    while (ch != null) {
      _readChar();

      if (ch == '"') {
        break;
      }
    }

    return StringLiteral(_readRange(pos, this.pos));
  }

  void _skipWhitespace() {
    while (ch == ' ' || ch == '\n') {
      _readChar();
    }
  }

  void _readChar() {
    ch = _peekChar();
    pos = readPos;
    readPos += 1;
  }

  String? _peekChar() {
    if (readPos >= input.length) {
      return null;
    } else {
      return input[readPos];
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
