import 'package:monkey/monkey/error.dart';
import 'package:monkey/monkey/evaluator/object.dart' as object;

object.Object? len(List<object.Object> args) {
  if (args.length != 1) {
    throw MonkeyException(
        'wrong number of arguments. got=${args.length}, want=1');
  }

  final arg = args[0];
  if (arg is object.StringLit) {
    return object.Integer(arg.value.length);
  } else if (arg is object.Array) {
    return object.Integer(arg.elements.length);
  } else {
    throw MonkeyException(
        'argument to `len` not supported, got ${arg.runtimeType}');
  }
}

object.Object? first(List<object.Object> args) {
  if (args.length != 1) {
    throw MonkeyException(
        'wrong number of arguments. got=${args.length}, want=1');
  }

  final arg = args[0];
  if (arg is object.Array) {
    return arg.elements.isNotEmpty ? arg.elements[0] : null;
  } else {
    throw MonkeyException(
        'argument to `first` must be Array, got ${arg.runtimeType}');
  }
}

object.Object? last(List<object.Object> args) {
  if (args.length != 1) {
    throw MonkeyException(
        'wrong number of arguments. got=${args.length}, want=1');
  }

  final arg = args[0];
  if (arg is object.Array) {
    return arg.elements.isNotEmpty
        ? arg.elements[arg.elements.length - 1]
        : null;
  } else {
    throw MonkeyException(
        'argument to `last` must be Array, got ${arg.runtimeType}');
  }
}

object.Object? rest(List<object.Object> args) {
  if (args.length != 1) {
    throw MonkeyException(
        'wrong number of arguments. got=${args.length}, want=1');
  }

  final arg = args[0];
  if (arg is object.Array) {
    if (arg.elements.isEmpty) {
      return constNull;
    }

    return object.Array(arg.elements.sublist(1));
  } else {
    throw MonkeyException(
        'argument to `rest` must be Array, got ${arg.runtimeType}');
  }
}

object.Object? push(List<object.Object> args) {
  if (args.length != 2) {
    throw MonkeyException(
        'wrong number of arguments. got=${args.length}, want=2');
  }

  final arg = args[0];
  if (arg is object.Array) {
    return object.Array([...arg.elements, args[1]]);
  } else {
    throw MonkeyException(
        'argument to `push` must be Array, got ${arg.runtimeType}');
  }
}

object.Object? puts(List<object.Object> args) {
  for (final arg in args) {
    // ignore: avoid_print
    print(arg.toString());
  }

  return constNull;
}

const _builtinLen = object.Builtin(len);
const _builtinFirst = object.Builtin(first);
const _builtinLast = object.Builtin(last);
const _builtinRest = object.Builtin(rest);
const _builtinPush = object.Builtin(push);
const _builtinPuts = object.Builtin(puts);

extension BuiltinFunction on object.Builtin {
  static object.Builtin? resolve(String symbol) {
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
      default:
        return null;
    }
  }
}

const constTrue = object.Boolean(true);
const constFalse = object.Boolean(false);
const constNull = object.Null();
