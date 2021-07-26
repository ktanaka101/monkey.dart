import 'package:monkey/monkey/parser/ast.dart' as ast;
import 'package:monkey/monkey/lexer.dart';
import 'package:monkey/monkey/token.dart' as token;
import 'package:monkey/monkey/error.dart';

/// An expr priority of operator
enum Priority {
  /// lowest priority
  lowest,

  /// == !=
  equals,

  /// < >
  lessgreater,

  /// + -
  sum,

  /// * /
  product,

  prefix,

  /// (
  call,

  /// high priority
  /// [
  pIndex
}

extension Priorities on Priority {
  /// Convert [Priority] from [token.Token]
  static Priority fromToken(token.Token t) {
    switch (t.runtimeType) {
      case token.Equal:
      case token.NotEqual:
        return Priority.equals;
      case token.Lt:
      case token.Gt:
        return Priority.lessgreater;
      case token.Plus:
      case token.Minus:
        return Priority.sum;
      case token.Slash:
      case token.Asterisk:
        return Priority.product;
      case token.Lparen:
        return Priority.call;
      case token.Lbracket:
        return Priority.pIndex;
      default:
        return Priority.lowest;
    }
  }
}

extension Operators on ast.Operator {
  static ast.Operator fromToken(token.Token t) {
    switch (t.runtimeType) {
      case token.Assign:
        return ast.Operator.assign;
      case token.Plus:
        return ast.Operator.plus;
      case token.Minus:
        return ast.Operator.minus;
      case token.Bang:
        return ast.Operator.bang;
      case token.Asterisk:
        return ast.Operator.asterisk;
      case token.Slash:
        return ast.Operator.slash;
      case token.Equal:
        return ast.Operator.equal;
      case token.NotEqual:
        return ast.Operator.notEqual;
      case token.Lt:
        return ast.Operator.lt;
      case token.Gt:
        return ast.Operator.gt;
      default:
        throw MonkeyException('Unsupported operator.($t)');
    }
  }
}

enum InfixFn { infix, call, mIndex }

class Parser {
  Parser(this.lexer) {
    curToken = lexer.nextToken();
    peekToken = lexer.nextToken();
  }

  final Lexer lexer;
  late token.Token curToken;
  late token.Token peekToken;
  final List<String> errors = [];

  ast.Program parseProgram() {
    final statements = <ast.Stmt>[];
    while (curToken is! token.Eof) {
      final stmt = _parseStatement();
      statements.add(stmt);
      _nextToken();
    }

    return ast.Program(statements);
  }

  ast.Stmt _parseStatement() {
    switch (curToken.runtimeType) {
      case token.Let:
        return _parseLetStatement();
      case token.Return:
        return _parseReturnStatement();
      default:
        return _parseExprStatement();
    }
  }

  ast.Let _parseLetStatement() {
    _expectPeek(token.Ident);

    final tkn = curToken;
    if (tkn is! token.Ident) {
      throw MonkeyException('Unreachable.');
    }
    final name = ast.Ident(tkn.value);

    _expectPeek(token.Assign);

    _nextToken();
    final value = _parseExpr(Priority.lowest);
    if (_peekTokenIs(token.Semicolon)) {
      _nextToken();
    }
    if (value is ast.MFunction) {
      value.name = name.value;
    }

    return ast.Let(name, value);
  }

  ast.Return _parseReturnStatement() {
    _nextToken();

    final returnValue = _parseExpr(Priority.lowest);

    if (peekToken is token.Semicolon) {
      _nextToken();
    }

    return ast.Return(returnValue);
  }

  ast.ExprStmt _parseExprStatement() {
    final expr = _parseExpr(Priority.lowest);

    if (_peekTokenIs(token.Semicolon)) {
      _nextToken();
    }

    return ast.ExprStmt(expr);
  }

  ast.Expr _parseExpr(Priority precedence) {
    switch (curToken.runtimeType) {
      case token.Illegal:
      case token.Eof:
      case token.Assign:
      case token.Plus:
      case token.Asterisk:
      case token.Slash:
      case token.Equal:
      case token.NotEqual:
      case token.Lt:
      case token.Gt:
      case token.Comma:
      case token.Semicolon:
      case token.Colon:
      case token.Rparen:
      case token.Rbrace:
      case token.Rbracket:
      case token.Let:
      case token.Else:
      case token.Return:
        throw MonkeyException('Not expected $curToken');
      case token.Ident:
      case token.Int:
      case token.Bang:
      case token.Minus:
      case token.True:
      case token.False:
      case token.Lparen:
      case token.If:
      case token.MFunction:
      case token.StringLiteral:
      case token.Lbracket:
      case token.Lbrace:
      case token.Macro:
        break;
      default:
        throw MonkeyException('Unreachable. $curToken');
    }

    var leftExpr = _prefixParseFns(curToken);

    while (peekToken is! token.Semicolon &&
        precedence.index < Priorities.fromToken(peekToken).index) {
      final infixFn = _infixParseFns(peekToken);

      _nextToken();

      switch (infixFn) {
        case InfixFn.infix:
          leftExpr = _parseInfixExpr(leftExpr);
          break;
        case InfixFn.call:
          leftExpr = _parseCallExpr(leftExpr);
          break;
        case InfixFn.mIndex:
          leftExpr = _parseIndexExpr(leftExpr);
          break;
      }
    }

    return leftExpr;
  }

  ast.InfixExpr _parseInfixExpr(ast.Expr left) {
    final ope = Operators.fromToken(curToken);
    _nextToken();
    final right = _parseExpr(Priority.prefix);

    return ast.InfixExpr(left, ope, right);
  }

  ast.Call _parseCallExpr(ast.Expr func) {
    return ast.Call(func, _parseExprList(token.Rparen));
  }

  ast.Index _parseIndexExpr(ast.Expr left) {
    _nextToken();
    final index = _parseExpr(Priority.lowest);
    _expectPeek(token.Rbracket);

    return ast.Index(left, index);
  }

  InfixFn _infixParseFns(token.Token tkn) {
    switch (tkn.runtimeType) {
      case token.Plus:
      case token.Minus:
      case token.Slash:
      case token.Asterisk:
      case token.Equal:
      case token.NotEqual:
      case token.Lt:
      case token.Gt:
        return InfixFn.infix;
      case token.Lparen:
        return InfixFn.call;
      case token.Lbracket:
        return InfixFn.mIndex;
      default:
        throw MonkeyException('InvalidInfix: $tkn');
    }
  }

  ast.Expr _prefixParseFns(token.Token tkn) {
    switch (tkn.runtimeType) {
      case token.Ident:
        return _parseIdentifier();
      case token.Int:
        return _parseIntegerLiteral();
      case token.Bang:
      case token.Minus:
        return _parsePrefixExpr();
      case token.True:
      case token.False:
        return _parseBoolLiteral();
      case token.Lparen:
        return _parseGroupedExpr();
      case token.If:
        return _parseIfExpr();
      case token.MFunction:
        return _parseFunctionLiteral();
      case token.StringLiteral:
        return _parseStringLiteral();
      case token.Lbracket:
        return _parseArrayLiteral();
      case token.Lbrace:
        return _parseHashLiteral();
      case token.Macro:
        return _parseMacroLiteral();
      default:
        throw MonkeyException('Invalid prefix: $tkn');
    }
  }

  ast.Ident _parseIdentifier() {
    final tkn = curToken;
    if (tkn is token.Ident) {
      return ast.Ident(tkn.value);
    }

    throw MonkeyException('Expect identifier: $tkn');
  }

  ast.Int _parseIntegerLiteral() {
    final tkn = curToken;
    if (tkn is token.Int) {
      return ast.Int(int.parse(tkn.value));
    }

    throw MonkeyException('Invalid integer: $tkn');
  }

  ast.Boolean _parseBoolLiteral() {
    final tkn = curToken;
    switch (tkn.runtimeType) {
      case token.True:
        return ast.Boolean(true);
      case token.False:
        return ast.Boolean(false);
      default:
        throw MonkeyException('Invalid boolean: $tkn');
    }
  }

  ast.Expr _parseGroupedExpr() {
    _nextToken();
    final expr = _parseExpr(Priority.lowest);
    _expectPeek(token.Rparen);

    return expr;
  }

  ast.PrefixExpr _parsePrefixExpr() {
    final ope = Operators.fromToken(curToken);
    _nextToken();

    final right = _parseExpr(Priority.prefix);

    return ast.PrefixExpr(ope, right);
  }

  ast.If _parseIfExpr() {
    _expectPeek(token.Lparen);

    _nextToken();

    final cond = _parseExpr(Priority.lowest);

    _expectPeek(token.Rparen);
    _expectPeek(token.Lbrace);

    final consequence = _parseBlockStatement();

    ast.Block? alternative;
    if (_peekTokenIs(token.Else)) {
      _nextToken();
      _expectPeek(token.Lbrace);

      alternative = _parseBlockStatement();
    }

    return ast.If(cond, consequence, alternative);
  }

  ast.Block _parseBlockStatement() {
    _nextToken();

    final statements = <ast.Stmt>[];
    while (!(_curTokenIs(token.Rbrace) || _curTokenIs(token.Eof))) {
      statements.add(_parseStatement());
      _nextToken();
    }

    return ast.Block(statements);
  }

  ast.MFunction _parseFunctionLiteral() {
    _expectPeek(token.Lparen);

    final params = _parseFunctionParams();
    _expectPeek(token.Lbrace);

    final body = _parseBlockStatement();

    return ast.MFunction(params, body, '');
  }

  List<ast.Ident> _parseFunctionParams() {
    final identifiers = <ast.Ident>[];

    if (_peekTokenIs(token.Rparen)) {
      _nextToken();
      return identifiers;
    }

    _nextToken();

    final tkn = curToken;
    if (tkn is token.Ident) {
      final firstIdent = ast.Ident(tkn.value);
      identifiers.add(firstIdent);
    } else {
      throw MonkeyException('Invalid function params: $tkn');
    }

    while (_peekTokenIs(token.Comma)) {
      _nextToken();
      _nextToken();
      final tkn = curToken;
      if (tkn is token.Ident) {
        identifiers.add(ast.Ident(tkn.value));
      } else {
        throw MonkeyException('Invalid function params: $tkn');
      }
    }
    _expectPeek(token.Rparen);

    return identifiers;
  }

  List<ast.Expr> _parseExprList(Type endTokenType) {
    if (endTokenType != token.Rbracket && endTokenType != token.Rparen) {
      throw MonkeyException('Invalid expr list token: $endTokenType');
    }

    if (_peekTokenIs(endTokenType)) {
      _nextToken();
      return [];
    }

    final exprList = <ast.Expr>[];

    _nextToken();
    exprList.add(_parseExpr(Priority.lowest));

    while (_peekTokenIs(endTokenType)) {
      _nextToken();
      _nextToken();
      exprList.add(_parseExpr(Priority.lowest));
    }

    _expectPeek(endTokenType);

    return exprList;
  }

  ast.StringLit _parseStringLiteral() {
    final tkn = curToken;
    if (tkn is token.StringLiteral) {
      return ast.StringLit(tkn.value);
    }

    throw MonkeyException('Invalid string literal: $tkn');
  }

  ast.Array _parseArrayLiteral() => ast.Array(_parseExprList(token.Rbracket));

  ast.Hash _parseHashLiteral() {
    final pairs = <ast.Pair>[];

    while (!_peekTokenIs(token.Rbrace)) {
      _nextToken();

      final key = _parseExpr(Priority.lowest);
      _expectPeek(token.Colon);
      _nextToken();

      final value = _parseExpr(Priority.lowest);
      pairs.add(ast.Pair(key, value));

      if (_peekTokenIs(token.Rbrace)) {
        continue;
      }

      try {
        _expectPeek(token.Comma);
      } on MonkeyException {
        throw MonkeyException('Invalid hash literal: $curToken');
      }
    }
    _expectPeek(token.Rbrace);

    return ast.Hash(pairs);
  }

  ast.MacroLit _parseMacroLiteral() {
    _expectPeek(token.Lparen);
    final params = _parseFunctionParams();

    _expectPeek(token.Lbrace);
    final body = _parseBlockStatement();

    return ast.MacroLit(params, body);
  }

  bool _curTokenIs(Type tokenType) {
    return curToken.runtimeType == tokenType;
  }

  bool _peekTokenIs(Type tokenType) {
    return peekToken.runtimeType == tokenType;
  }

  void _expectPeek(Type tokenType) {
    if (peekToken.runtimeType == tokenType) {
      _nextToken();
    } else {
      throw MonkeyException('ExpectPeek: $tokenType, $curToken');
    }
  }

  void _nextToken() {
    curToken = peekToken;
    peekToken = lexer.nextToken();
  }
}
