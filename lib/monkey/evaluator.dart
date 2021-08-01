import 'package:monkey/monkey/evaluator/env.dart';
import 'package:monkey/monkey/evaluator/object.dart' as object;
import 'package:monkey/monkey/parser/ast.dart' as ast;

object.Object eval(ast.Node node, Environment env) {
  if (node is ast.Program) {
    throw Exception('unimplements');
  } else if (node is ast.Stmt) {
    throw Exception('unimplements');
  } else if (node is ast.Expr) {
    throw Exception('unimplements');
  } else {
    throw Exception('Unreachable');
  }
}
