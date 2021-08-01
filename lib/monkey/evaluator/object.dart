import 'package:monkey/monkey/evaluator/env.dart';
import 'package:monkey/monkey/evaluator/builtin.dart' as builtin;
import 'package:monkey/monkey/parser/ast.dart' as ast;

abstract class Object {}

mixin Hashable {}

class Array extends Object {
  Array(this.elements);
  List<Object> elements;
}

class Boolean extends Object with Hashable {
  // ignore: avoid_positional_boolean_parameters
  Boolean(this.value);
  bool value;
}

class MFunction extends Object {
  MFunction(this.params, this.body, this.env);
  List<ast.Ident> params;
  ast.Block body;
  Environment env;
}

class Integer extends Object with Hashable {
  Integer(this.value);
  int value;
}

class Macro extends Object {
  Macro(this.params, this.body, this.env);
  List<ast.Ident> params;
  ast.Block body;
  Environment env;
}

class Builtin extends Object {
  Builtin(this.func);
  builtin.MFunction func;
}
