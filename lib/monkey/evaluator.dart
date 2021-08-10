import 'package:monkey/monkey/error.dart';
import 'package:monkey/monkey/evaluator/builtin.dart' as builtin;
import 'package:monkey/monkey/evaluator/env.dart';
import 'package:monkey/monkey/evaluator/object.dart' as object;
import 'package:monkey/monkey/ast.dart' as ast;

object.Object eval(ast.Node node, Environment env) {
  if (node is ast.Program) {
    return _evalProgram(node, env);
  } else if (node is ast.Stmt) {
    return _evalStmt(node, env);
  } else if (node is ast.Expr) {
    return _evalExpr(node, env);
  } else {
    throw MonkeyException('Unreachable');
  }
}

object.Object _evalStmt(ast.Stmt stmt, Environment env) {
  if (stmt is ast.ExprStmt) {
    return eval(stmt.expr, env);
  } else if (stmt is ast.Let) {
    final val = _evalExpr(stmt.value, env);
    env.insert(stmt.name.value, val);
    return builtin.constNull;
  } else if (stmt is ast.Block) {
    return _evalBlock(stmt, env);
  } else if (stmt is ast.Return) {
    final val = _evalExpr(stmt.value, env);
    return object.Return(val);
  } else {
    throw MonkeyException('Unreachable');
  }
}

object.Object _evalExpr(ast.Expr expr, Environment env) {
  if (expr is ast.Array) {
    final elements = _evalExpressions(expr.elements, env);
    return object.Array(elements);
  } else if (expr is ast.Boolean) {
    return expr.value.toBooleanObject();
  } else if (expr is ast.Int) {
    return object.Integer(expr.value);
  } else if (expr is ast.StringLit) {
    return object.StringLit(expr.value);
  } else if (expr is ast.Hash) {
    return _evalHashLiteral(expr, env);
  } else if (expr is ast.Ident) {
    return _evalIdentifier(expr, env);
  } else if (expr is ast.InfixExpr) {
    final left = _evalExpr(expr.left, env);
    final right = _evalExpr(expr.right, env);
    return _evalInfixExpr(expr.ope, left, right);
  } else if (expr is ast.PrefixExpr) {
    final right = _evalExpr(expr.right, env);
    return _evalPrefixExpr(expr.ope, right);
  } else if (expr is ast.If) {
    return _evalIfExpr(expr, env);
  } else if (expr is ast.MFunction) {
    return object.MFunction(expr.params, expr.body, env);
  } else if (expr is ast.Index) {
    final left = _evalExpr(expr.left, env);
    final index = _evalExpr(expr.index, env);
    return _evalIndexExpr(left, index);
  } else if (expr is ast.Call) {
    {
      final func = expr.func;
      if (func is ast.Ident && func.value == 'quote') {
        return _quote(expr.args[0], env);
      }
    }

    final func = _evalExpr(expr.func, env);
    final args = _evalExpressions(expr.args, env);
    return _applyFunction(func, args);
  } else {
    throw MonkeyException('Unreachable');
  }
}

object.Object _evalProgram(ast.Program program, Environment env) {
  object.Object obj = builtin.constNull;
  for (final stmt in program.statements) {
    final value = _evalStmt(stmt, env);
    if (value is object.Return) {
      return value.value;
    } else {
      obj = value;
    }
  }

  return obj;
}

object.Object _evalBlock(ast.Block block, Environment env) {
  object.Object obj = builtin.constNull;
  for (final stmt in block.statements) {
    final value = _evalStmt(stmt, env);
    if (value is object.Return) {
      return value;
    } else {
      obj = value;
    }
  }

  return obj;
}

object.Object _evalPrefixExpr(ast.Operator ope, object.Object right) {
  switch (ope) {
    case ast.Operator.bang:
      return _evalBangOpeExpr(right);
    case ast.Operator.minus:
      return _evalMinusPrefixOpeExpr(right);
    case ast.Operator.assign:
    case ast.Operator.asterisk:
    case ast.Operator.equal:
    case ast.Operator.gt:
    case ast.Operator.lt:
    case ast.Operator.notEqual:
    case ast.Operator.plus:
    case ast.Operator.slash:
      throw MonkeyException('unknown operator: $ope$right');
  }
}

extension on bool {
  object.Boolean toBooleanObject() =>
      this ? builtin.constTrue : builtin.constFalse;
}

object.Boolean _evalBangOpeExpr(object.Object right) {
  if (right is object.Boolean) {
    return right.value ? builtin.constFalse : builtin.constTrue;
  } else if (right is object.Null) {
    return builtin.constTrue;
  } else {
    return builtin.constFalse;
  }
}

object.Object _evalMinusPrefixOpeExpr(object.Object right) {
  if (right is object.Integer) {
    return object.Integer(-right.value);
  } else {
    throw MonkeyException('unknown operator: -${right.runtimeType}');
  }
}

object.Object _evalInfixExpr(
    ast.Operator ope, object.Object left, object.Object right) {
  if (left is object.Integer && right is object.Integer) {
    return _evalIntegerInfixExpr(ope, left, right);
  } else if (left is object.StringLit && right is object.StringLit) {
    return _evalStringInfixExpr(ope, left, right);
  } else if (ope == ast.Operator.equal) {
    return left.monkeyEqual(right).toBooleanObject();
  } else if (ope == ast.Operator.notEqual) {
    return (!left.monkeyEqual(right)).toBooleanObject();
  } else {
    if (left.runtimeType == right.runtimeType) {
      throw MonkeyException(
        '''unknown operator: ${left.runtimeType} ${ope.toCode()} ${right.runtimeType}''',
      );
    } else {
      throw MonkeyException(
        '''type mismatch: ${left.runtimeType} ${ope.toCode()} ${right.runtimeType}''',
      );
    }
  }
}

object.Object _evalIntegerInfixExpr(
    ast.Operator ope, object.Integer left, object.Integer right) {
  if (ope == ast.Operator.plus) {
    return object.Integer(left.value + right.value);
  } else if (ope == ast.Operator.minus) {
    return object.Integer(left.value - right.value);
  } else if (ope == ast.Operator.asterisk) {
    return object.Integer(left.value * right.value);
  } else if (ope == ast.Operator.slash) {
    return object.Integer((left.value / right.value).ceil());
  } else if (ope == ast.Operator.lt) {
    return (left.value < right.value).toBooleanObject();
  } else if (ope == ast.Operator.gt) {
    return (left.value > right.value).toBooleanObject();
  } else if (ope == ast.Operator.equal) {
    return (left.monkeyEqual(right)).toBooleanObject();
  } else if (ope == ast.Operator.notEqual) {
    return (!left.monkeyEqual(right)).toBooleanObject();
  } else {
    throw MonkeyException('unknown oeperator: ${ope.toCode()}');
  }
}

object.Object _evalStringInfixExpr(
    ast.Operator ope, object.StringLit left, object.StringLit right) {
  if (ope == ast.Operator.plus) {
    return object.StringLit(left.value + right.value);
  } else if (ope == ast.Operator.equal) {
    return left.monkeyEqual(right).toBooleanObject();
  } else if (ope == ast.Operator.notEqual) {
    return (!left.monkeyEqual(right)).toBooleanObject();
  } else {
    throw MonkeyException('unknown operator: String ${ope.toCode()} String');
  }
}

object.Object _evalIfExpr(ast.If ifExpr, Environment env) {
  final cond = _evalExpr(ifExpr.cond, env);

  if (_isTruthy(cond)) {
    return _evalStmt(ifExpr.consequence, env);
  } else {
    final alt = ifExpr.alternative;
    if (alt != null) {
      return _evalStmt(alt, env);
    } else {
      return builtin.constNull;
    }
  }
}

bool _isTruthy(object.Object obj) {
  if (obj is object.Null) {
    return false;
  } else if (obj is object.Boolean) {
    return obj.value;
  } else {
    return true;
  }
}

object.Object _evalIdentifier(ast.Ident ident, Environment env) {
  final expr = env.resolve(ident.value);
  if (expr != null) {
    return expr;
  }

  final builtinFunc = builtin.BuiltinFunction.resolve(ident.value);
  if (builtinFunc != null) {
    return builtinFunc;
  }

  throw MonkeyException('identifier not found: ${ident.value}');
}

List<object.Object> _evalExpressions(
        List<ast.Expr> exprList, Environment env) =>
    exprList.map((expr) => _evalExpr(expr, env)).toList();

object.Object _applyFunction(object.Object func, List<object.Object> args) {
  if (func is object.MFunction) {
    final extendedEnv = _extendFunctionEnv(func, args);
    final evaluated = _evalStmt(func.body, extendedEnv);
    return _unwrapReturnValue(evaluated);
  } else if (func is object.Builtin) {
    final res = func.call(args);
    if (res == null) {
      return builtin.constNull;
    }

    return res;
  } else {
    throw MonkeyException('not a function: ${func.runtimeType}');
  }
}

Environment _extendFunctionEnv(
    object.MFunction func, List<object.Object> args) {
  if (func.params.length != args.length) {
    throw MonkeyException('not match args.');
  }

  final env = Environment.newEnclose(func.env);
  for (var i = 0; i < func.params.length; i++) {
    env.insert(func.params[i].value, args[i]);
  }

  return env;
}

object.Object _unwrapReturnValue(object.Object obj) {
  if (obj is object.Return) {
    return obj.value;
  } else {
    return obj;
  }
}

object.Object _evalIndexExpr(object.Object left, object.Object index) {
  if (left is object.Array) {
    return _evalArrayIndexExpr(left, index);
  } else if (left is object.Hash) {
    return _evalHashIndexExpr(left, index);
  } else {
    throw MonkeyException('index operator not supported');
  }
}

object.Object _evalArrayIndexExpr(object.Array array, object.Object index) {
  if (index is! object.Integer) {
    throw MonkeyException('unusable as array key: ${index.runtimeType}');
  }

  if (index.value < 0 || index.value >= array.elements.length) {
    return builtin.constNull;
  }

  return array.elements[index.value];
}

object.Object _evalHashLiteral(ast.Hash hash, Environment env) {
  final object.HashPairs pairs = {};

  for (final pair in hash.pairs) {
    final key = _evalExpr(pair.key, env);
    final value = _evalExpr(pair.value, env);
    if (key is object.Hashable) {
      pairs[key as object.Hashable] = value;
    } else {
      throw MonkeyException('unusable as hash key: $key');
    }
  }

  return object.Hash(pairs);
}

object.Object _evalHashIndexExpr(object.Hash hash, object.Object key) {
  if (key is! object.Hashable) {
    throw MonkeyException('unusable as hash key: ${key.runtimeType}');
  }

  final value = hash.pairs[key];
  if (value == null) {
    return builtin.constNull;
  }

  return value;
}

object.Object _quote(ast.Node node, Environment env) =>
    object.Quote(_evalUnquoteCalls(node, env));

ast.Node _evalUnquoteCalls(ast.Node quoted, Environment env) =>
    ast.modify(quoted, (node) {
      if (!_isUnquoteCall(node)) {
        return node;
      }

      if (node is ast.Call) {
        if (node.args.length == 1) {
          final arg = node.args[0];
          return _convertObjectToAstNode(eval(arg, env));
        } else {
          throw MonkeyException('unimplements');
        }
      } else {
        throw MonkeyException('unimplements');
      }
    });

bool _isUnquoteCall(ast.Node node) {
  if (node is ast.Call) {
    final func = node.func;
    if (func is ast.Ident) {
      return func.value == 'unquote';
    }
  }

  return false;
}

ast.Node _convertObjectToAstNode(object.Object obj) {
  if (obj is object.Integer) {
    return ast.Int(obj.value);
  } else if (obj is object.Boolean) {
    return ast.Boolean(obj.value);
  } else if (obj is object.Quote) {
    return obj.node;
  } else {
    throw MonkeyException('unimplements');
  }
}

bool _isMacroDefinition(ast.Stmt stmt) =>
    stmt is ast.Let && stmt.value is ast.MacroLit;

void _addMacro(ast.Stmt stmt, Environment env) {
  if (stmt is! ast.Let) {
    throw MonkeyException('expect Let. receive $stmt');
  }

  final value = stmt.value;
  if (value is! ast.MacroLit) {
    throw MonkeyException('expect Macro. received $value');
  }

  final macro = object.Macro(value.params, value.body, env);

  env.insert(stmt.name.value, macro);
}

object.Macro? _getMacroInEnv(ast.Call call, Environment env) {
  final ident = call.func;
  if (ident is! ast.Ident) {
    return null;
  }

  final obj = env.resolve(ident.value);
  if (obj is object.Macro) {
    return obj;
  } else {
    return null;
  }
}

Environment _extendMacroEnv(object.Macro macro, List<object.Quote> args) {
  final extended = Environment(outer: macro.env);

  if (macro.params.length != args.length) {
    throw MonkeyException('''
      The number of elements does not match. 
      ${macro.params.length} != ${args.length}''');
  }

  for (var i = 0; i < args.length; i++) {
    extended.insert(macro.params[i].value, args[i]);
  }

  return extended;
}

List<object.Quote> _quoteArgs(ast.Call call) =>
    call.args.map((arg) => object.Quote(arg)).toList();

void defineMacros(ast.Program program, Environment env) {
  program.statements
      .where(_isMacroDefinition)
      .forEach((stmt) => _addMacro(stmt, env));

  program.statements =
      program.statements.where((stmt) => !_isMacroDefinition(stmt)).toList();
}

ast.Node extendMacros(ast.Node node, Environment env) =>
    ast.modify(node, (node) {
      if (node is! ast.Call) {
        return node;
      }

      final macro = _getMacroInEnv(node, env);
      if (macro == null) {
        return node;
      }

      final args = _quoteArgs(node);
      final evalEnv = _extendMacroEnv(macro, args);
      final evaluated = _evalStmt(macro.body, evalEnv);

      if (evaluated is! object.Quote) {
        throw MonkeyException(
            'we only support returning AST-nodes from macros. $evaluated');
      }

      return evaluated.node;
    });
