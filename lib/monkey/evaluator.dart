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
    throw Exception('unimplements');
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
