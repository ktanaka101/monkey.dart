import 'package:monkey/monkey/evaluator/object.dart' as object;

object.Object? len(List<object.Object> args) {
  throw 'unimplements';
}

object.Object? first(List<object.Object> args) {
  throw 'unimplements';
}

object.Object? last(List<object.Object> args) {
  throw 'unimplements';
}

object.Object? rest(List<object.Object> args) {
  throw 'unimplements';
}

object.Object? push(List<object.Object> args) {
  throw 'unimplements';
}

object.Object? puts(List<object.Object> args) {
  throw 'unimplements';
}

extension BuiltinFunction on object.Builtin {
  object.Builtin? resolve(String symbol) {
    switch (symbol) {
      case 'len':
        return object.Builtin(len);
      case 'first':
        return object.Builtin(first);
      case 'last':
        return object.Builtin(last);
      case 'rest':
        return object.Builtin(rest);
      case 'push':
        return object.Builtin(push);
      case 'puts':
        return object.Builtin(puts);
    }
  }
}

const constTrue = object.Boolean(true);
const constFalse = object.Boolean(false);
const constNull = object.Null();
