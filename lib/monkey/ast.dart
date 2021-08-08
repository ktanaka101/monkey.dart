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
  /// `=`
  assign,

  /// `+`
  plus,

  /// `-`
  minus,

  /// `!`
  bang,

  /// `*`
  asterisk,

  /// `/`
  slash,

  /// `==`
  equal,

  /// `!=`
  notEqual,

  /// `<`
  lt,

  /// `>`
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
  String? name;

  @override
  String toString() {
    if (name == null) {
      return 'fn(${params.join(", ")}) $body';
    } else {
      return 'fn $name(${params.join(", ")}) $body';
    }
  }
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

Node modify(Node node, Node Function(Node) modifier) {
  if (node is Program) {
    node.statements =
        node.statements.map((stmt) => modify(stmt, modifier) as Stmt).toList();
  } else if (node is ExprStmt) {
    node.expr = modify(node.expr, modifier) as Expr;
  } else if (node is Block) {
    node.statements =
        node.statements.map((stmt) => modify(stmt, modifier) as Stmt).toList();
  } else if (node is Return) {
    node.value = modify(node.value, modifier) as Expr;
  } else if (node is Let) {
    node
      ..name = modify(node.name, modifier) as Ident
      ..value = modify(node.value, modifier) as Expr;
  } else if (node is InfixExpr) {
    node
      ..left = modify(node.left, modifier) as Expr
      ..right = modify(node.right, modifier) as Expr;
  } else if (node is PrefixExpr) {
    node.right = modify(node.right, modifier) as Expr;
  } else if (node is Index) {
    node
      ..left = modify(node.left, modifier) as Expr
      ..index = modify(node.index, modifier) as Expr;
  } else if (node is If) {
    node
      ..cond = modify(node.cond, modifier) as Expr
      ..consequence = modify(node.consequence, modifier) as Block;
    final alt = node.alternative;
    if (alt != null) {
      node.alternative = modify(alt, modifier) as Block;
    }
  } else if (node is MFunction) {
    node
      ..params =
          node.params.map((ident) => modify(ident, modifier) as Ident).toList()
      ..body = modify(node.body, modifier) as Block;
  } else if (node is Array) {
    node.elements =
        node.elements.map((expr) => modify(expr, modifier) as Expr).toList();
  } else if (node is Hash) {
    node.pairs = node.pairs
        .map((pair) => pair
          ..key = modify(pair.key, modifier) as Expr
          ..value = modify(pair.value, modifier) as Expr)
        .toList();
  }

  return modifier(node);
}
