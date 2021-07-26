abstract class Node {}

abstract class Expr extends Node {}

abstract class Stmt extends Node {}

class Program extends Node {
  Program(this.statements);
  List<Stmt> statements;

  @override
  String toString() => statements.map((e) => e.toString()).join();
}

class Let extends Stmt {
  Let(this.name, this.value);
  Ident name;
  Expr value;

  @override
  String toString() => 'let $name = $value;';
}

class Return extends Stmt {
  Return(this.value);
  Expr value;

  @override
  String toString() => 'return $value;';
}

class Block extends Stmt {
  Block(this.statements);
  List<Stmt> statements;

  @override
  String toString() {
    final code = statements.map((e) => e.toString()).join();
    return '{ $code }';
  }
}

class ExprStmt extends Stmt {
  ExprStmt(this.expr);
  Expr expr;

  @override
  String toString() => '${expr.toString()};';
}

enum Operator {
  assign,
  plus,
  minus,
  bang,
  asterisk,
  slash,
  equal,
  notEqual,
  lt,
  gt
}

extension OperatorToCode on Operator {
  String toCode() {
    switch (this) {
      case Operator.assign:
        return '=';
      case Operator.plus:
        return '+';
      case Operator.minus:
        return '-';
      case Operator.bang:
        return '!';
      case Operator.asterisk:
        return '*';
      case Operator.slash:
        return '/';
      case Operator.equal:
        return '==';
      case Operator.notEqual:
        return '!=';
      case Operator.lt:
        return '<';
      case Operator.gt:
        return '>';
    }
  }
}

class InfixExpr extends Expr {
  InfixExpr(this.left, this.ope, this.right);
  Expr left;
  Operator ope;
  Expr right;

  @override
  String toString() => '($left ${ope.toCode()} $right)';
}

class PrefixExpr extends Expr {
  PrefixExpr(this.ope, this.right);
  Operator ope;
  Expr right;

  @override
  String toString() => '(${ope.toCode()}$right)';
}

class If extends Expr {
  If(this.cond, this.consequence, this.alternative);
  Expr cond;
  Block consequence;
  Block? alternative;

  @override
  String toString() {
    final code = 'if ($cond) $consequence';
    final alt = alternative;
    if (alt == null) {
      return code;
    }

    return '$code else $alternative';
  }
}

class Ident extends Expr {
  Ident(this.value);
  String value;

  @override
  String toString() => value;
}

class Call extends Expr {
  Call(this.func, this.args);
  Expr func;
  List<Expr> args;

  @override
  String toString() => '$func(${args.join(", ")})';
}

class MFunction extends Expr {
  MFunction(this.params, this.body, this.name);
  List<Ident> params;
  Block body;
  String name;

  @override
  String toString() => 'fn $name(${params.join(", ")}) $body';
}

class Index extends Expr {
  Index(this.left, this.index);
  Expr left;
  Expr index;

  @override
  String toString() => '($left[$index])';
}

class MacroLit extends Expr {
  MacroLit(this.params, this.body);
  List<Ident> params;
  Block body;

  @override
  String toString() => 'macro(${params.join(", ")}) $body';
}

class Array extends Expr {
  Array(this.elements);
  List<Expr> elements;

  @override
  String toString() => '[${elements.join(", ")}]';
}

class Boolean extends Expr {
  // ignore: avoid_positional_boolean_parameters
  Boolean(this.value);
  bool value;

  @override
  String toString() => value.toString();
}

class Pair {
  Pair(this.key, this.value);
  Expr key;
  Expr value;

  @override
  String toString() => '$key: $value';
}

class Hash extends Expr {
  Hash(this.pairs);
  List<Pair> pairs;

  @override
  String toString() => '{ ${pairs.join(", ")} }';
}

class Int extends Expr {
  Int(this.value);
  int value;

  @override
  String toString() => value.toString();
}

class StringLit extends Expr {
  StringLit(this.value);
  String value;

  @override
  String toString() => '"$value"';
}
