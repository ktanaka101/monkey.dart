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

const _builtinLen = object.Builtin(len);
const _builtinFirst = object.Builtin(first);
const _builtinLast = object.Builtin(last);
const _builtinRest = object.Builtin(rest);
const _builtinPush = object.Builtin(push);
const _builtinPuts = object.Builtin(puts);

extension BuiltinFunction on object.Builtin {
  object.Builtin? resolve(String symbol) {
    switch (symbol) {
      case 'len':
        return _builtinLen;
      case 'first':
        return _builtinFirst;
      case 'last':
        return _builtinLast;
      case 'rest':
        return _builtinRest;
      case 'push':
        return _builtinPush;
      case 'puts':
        return _builtinPuts;
    }
  }
}

const constTrue = object.Boolean(true);
const constFalse = object.Boolean(false);
const constNull = object.Null();
