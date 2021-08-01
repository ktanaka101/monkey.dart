import 'package:monkey/monkey/evaluator/env.dart';
import 'package:monkey/monkey/evaluator/object.dart' as object;
import 'package:monkey/monkey/parser/ast.dart' as ast;

object.Object eval(ast.Node node, Environment env) {
  if (node is ast.Program) {
    throw Exception('unimplements');
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
    throw Exception('unimplements');
  } else if (stmt is ast.Block) {
    throw Exception('unimplements');
  } else if (stmt is ast.Return) {
    throw Exception('unimplements');
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
    throw Exception('unimplements');
  } else if (expr is ast.If) {
    throw Exception('unimplements');
  } else if (expr is ast.MFunction) {
    throw Exception('unimplements');
  } else if (expr is ast.Index) {
    throw Exception('unimplements');
  } else if (expr is ast.Call) {
    throw Exception('unimplements');
  } else {
    throw Exception('Unreachable');
  }
}
