import 'package:monkey/monkey/evaluator/env.dart';
import 'package:monkey/monkey/evaluator/builtin.dart' as builtin;
import 'package:monkey/monkey/parser/ast.dart' as ast;

abstract class Object {
  const Object();
}

mixin Hashable {}

class Integer extends Object with Hashable {
  Integer(this.value);
  int value;
}

class Boolean extends Object with Hashable {
  // ignore: avoid_positional_boolean_parameters
  const Boolean(this.value);
  final bool value;
}

class StringLit extends Object with Hashable {
  StringLit(this.value);
  String value;
}

class Array extends Object {
  Array(this.elements);
  List<Object> elements;
}

typedef HashPairs = Map<Hashable, Object>;

class Hash extends Object {
  Hash(this.pairs);
  HashPairs pairs;
}

class MFunction extends Object {
  MFunction(this.params, this.body, this.env);
  List<ast.Ident> params;
  ast.Block body;
  Environment env;
}

class Builtin extends Object {
  Builtin(this.func);
  builtin.MFunction func;
}

class Return extends Object {
  Return(this.value);
  Object value;
}

class Null extends Object {
  const Null();
}

class Macro extends Object {
  Macro(this.params, this.body, this.env);
  List<ast.Ident> params;
  ast.Block body;
  Environment env;
}

class Quote extends Object {
  Quote(this.node);
  ast.Node node;
}
