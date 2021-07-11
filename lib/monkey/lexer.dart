import 'package:monkey/monkey/token.dart';

class Lexer {
  String input;
  int pos = 0;
  int read_pos = 0;
  String? ch;

  Lexer(this.input) {
    _read_char();
  }

  Token next_token() {
    _skip_whitespace();

    Token? token;
    switch (ch) {
      case null:
        token = Eof();
        break;
      case '=':
        switch (_peek_char()) {
          case '=':
            _read_char();
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
        switch (_peek_char()) {
          case '=':
            _read_char();
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
        token = _read_string();
        break;
      default:
        var c = ch;
        if (c == null) {
          throw 'Unreachable';
        }

        if (Lexer._is_latter(c)) {
          var literal = _read_identifier();
          return lookup_ident(literal);
        } else if (Lexer._is_digit(c)) {
          return Int(_read_number());
        } else {
          token = Illegal(c);
        }
    }

    _read_char();

    return token;
  }

  String _read_identifier() {
    var pos = this.pos;
    while (ch != null) {
      var c = ch;
      if (c == null) {
        throw 'Unreachable';
      }
      if (!Lexer._is_latter(c)) {
        break;
      }

      _read_char();
    }

    return _read_range(pos, this.pos);
  }

  String _read_range(int s, int e) {
    return input.substring(s, e);
  }

  String _read_number() {
    var pos = this.pos;
    while (ch != null) {
      var c = ch;
      if (c == null) {
        throw 'Unreachable';
      }
      if (!Lexer._is_digit(c)) {
        break;
      }

      _read_char();
    }

    return _read_range(pos, this.pos);
  }

  static bool _is_latter(String c) {
    if (c.length != 1) {
      throw 'expect $c to be a char.';
    }
    return RegExp(r'^[a-zA-Z_!?]$').hasMatch(c);
  }

  static bool _is_digit(String c) {
    if (c.length != 1) {
      throw 'expect $c to be a char.';
    }
    return RegExp(r'^[0-9]$').hasMatch(c);
  }

  StringLiteral _read_string() {
    var pos = this.pos + 1;
    while (ch != null) {
      _read_char();

      if (ch == '"') {
        break;
      }
    }

    return StringLiteral(_read_range(pos, this.pos));
  }

  void _skip_whitespace() {
    while (ch == ' ' || ch == '\n') {
      _read_char();
    }
  }

  void _read_char() {
    ch = _peek_char();
    pos = read_pos;
    read_pos += 1;
  }

  String? _peek_char() {
    if (read_pos >= input.length) {
      return null;
    } else {
      return input[read_pos];
    }
  }
}

Token lookup_ident(String ident) {
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
