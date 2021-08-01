import 'package:monkey/monkey/evaluator/builtin.dart' as builtin;
import 'package:monkey/monkey/evaluator/env.dart';
import 'package:monkey/monkey/evaluator/object.dart' as object;
import 'package:monkey/monkey/parser/ast.dart' as ast;

object.Object eval(ast.Node node, Environment env) {
  if (node is ast.Program) {
    return _evalProgram(node, env);
  } else if (node is ast.Stmt) {
    return _evalStmt(node, env);
  } else if (node is ast.Expr) {
    throw Exception('unimplements');
  } else {
    throw Exception('Unreachable');
  }
}

object.Object _evalStmt(ast.Stmt stmt, Environment env) {
  if (stmt is ast.ExprStmt) {
    return eval(stmt.expr, env);
  } else if (stmt is ast.Let) {
    final val = _evalExpr(stmt.value, env);
    env.insert(stmt.name.value, val);
    return builtin.constNull;
  } else if (stmt is ast.Block) {
    return _evalBlock(stmt, env);
  } else if (stmt is ast.Return) {
    final val = _evalExpr(stmt.value, env);
    return object.Return(val);
  } else {
    throw Exception('Unreachable');
  }
}

object.Object _evalExpr(ast.Expr expr, Environment env) {
  if (expr is ast.Array) {
    throw Exception('unimplements');
  } else if (expr is ast.Boolean) {
    throw Exception('unimplements');
  } else if (expr is ast.Int) {
    throw Exception('unimplements');
  } else if (expr is ast.StringLit) {
    return object.StringLit(expr.value);
  } else if (expr is ast.Hash) {
    throw Exception('unimplements');
  } else if (expr is ast.Ident) {
    throw Exception('unimplements');
  } else if (expr is ast.InfixExpr) {
    throw Exception('unimplements');
  } else if (expr is ast.PrefixExpr) {
    final right = _evalExpr(expr.right, env);
    return _evalPrefixExpr(expr.ope, right);
  } else if (expr is ast.If) {
    throw Exception('unimplements');
  } else if (expr is ast.MFunction) {
    return object.MFunction(expr.params, expr.body, env);
  } else if (expr is ast.Index) {
    throw Exception('unimplements');
  } else if (expr is ast.Call) {
    throw Exception('unimplements');
  } else {
    throw Exception('Unreachable');
  }
}

object.Object _evalProgram(ast.Program program, Environment env) =>
    _evalStatementsInScope(program.statements, env);

object.Object _evalBlock(ast.Block block, Environment env) =>
    _evalStatementsInScope(block.statements, env);

object.Object _evalStatementsInScope(
    List<ast.Stmt> statements, Environment env) {
  object.Object obj = builtin.constNull;
  for (final stmt in statements) {
    final value = _evalStmt(stmt, env);
    if (value is object.Return) {
      return value.value;
    } else {
      obj = value;
    }
  }

  return obj;
}

object.Object _evalPrefixExpr(ast.Operator ope, object.Object right) {
  switch (ope) {
    case ast.Operator.bang:
      throw Exception('unimplements');
    case ast.Operator.minus:
      throw Exception('unimplements');
    case ast.Operator.assign:
    case ast.Operator.asterisk:
    case ast.Operator.equal:
    case ast.Operator.gt:
    case ast.Operator.lt:
    case ast.Operator.notEqual:
    case ast.Operator.plus:
    case ast.Operator.slash:
      throw Exception('unknown operator: $ope$right');
  }
}
