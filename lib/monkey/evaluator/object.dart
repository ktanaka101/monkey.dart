import 'package:monkey/monkey/evaluator/env.dart';
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

class MFunction {
  MFunction(this.params, this.body, this.env);
  List<ast.Ident> params;
  ast.Block body;
  Environment env;
}
