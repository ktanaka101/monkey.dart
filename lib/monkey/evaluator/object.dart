import 'package:monkey/monkey/evaluator/env.dart';
import 'package:monkey/monkey/evaluator/builtin.dart' as builtin;
import 'package:monkey/monkey/ast.dart' as ast;

// ignore: one_member_abstracts
abstract class MonkeyEq {
  bool monkeyEqual(Object other);
}

abstract class Object implements MonkeyEq {
  const Object();
}

mixin Hashable {}

class Integer extends Object with Hashable {
  Integer(this.value);
  int value;

  @override
  bool monkeyEqual(Object other) {
    if (other is Integer) {
      return value == other.value;
    } else {
      return false;
    }
  }
}

class Boolean extends Object with Hashable {
  // ignore: avoid_positional_boolean_parameters
  const Boolean(this.value);
  final bool value;

  @override
  bool monkeyEqual(Object other) {
    if (other is Boolean) {
      return value == other.value;
    } else {
      return false;
    }
  }
}

class StringLit extends Object with Hashable {
  StringLit(this.value);
  String value;

  @override
  bool monkeyEqual(Object other) {
    if (other is StringLit) {
      return value == other.value;
    } else {
      return false;
    }
  }
}

class Array extends Object {
  Array(this.elements);
  List<Object> elements;

  @override
  bool monkeyEqual(Object other) {
    if (other is Array) {
      if (elements.length != other.elements.length) {
        return false;
      }

      for (var i = 0; i < elements.length; i++) {
        if (!elements[i].monkeyEqual(other.elements[i])) {
          return false;
        }
      }

      return true;
    } else {
      return false;
    }
  }
}

typedef HashPairs = Map<Hashable, Object>;

class Hash extends Object {
  Hash(this.pairs);
  HashPairs pairs;

  @override
  bool monkeyEqual(Object other) {
    if (other is! Hash) {
      return false;
    }

    if (pairs.length != other.pairs.length) {
      return false;
    }

    for (final pair in pairs.entries) {
      final key = pair.key;
      final otherValue = other.pairs[key];
      if (otherValue == null) {
        return false;
      }

      if (pair.value is MonkeyEq && otherValue is MonkeyEq) {
        if (!pair.value.monkeyEqual(otherValue)) {
          return false;
        }
      }
    }

    return true;
  }
}

class MFunction extends Object {
  MFunction(this.params, this.body, this.env);
  List<ast.Ident> params;
  ast.Block body;
  Environment env;

  @override
  bool monkeyEqual(Object other) => this == other;
}

class Builtin extends Object {
  Builtin(this.func);
  builtin.MFunction func;

  @override
  bool monkeyEqual(Object other) => this == other;
}

class Return extends Object {
  Return(this.value);
  Object value;

  @override
  bool monkeyEqual(Object other) => this == other;
}

class Null extends Object {
  const Null();

  @override
  bool monkeyEqual(Object other) => this == other;
}

class Macro extends Object {
  Macro(this.params, this.body, this.env);
  List<ast.Ident> params;
  ast.Block body;
  Environment env;

  @override
  bool monkeyEqual(Object other) => this == other;
}

class Quote extends Object {
  Quote(this.node);
  ast.Node node;
}
