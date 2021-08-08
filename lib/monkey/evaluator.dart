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
    throw Exception('unimplements');
  } else {
    throw Exception('Unreachable');
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
    throw Exception('Unreachable');
  }
}

object.Object _evalExpr(ast.Expr expr, Environment env) {
  if (expr is ast.Array) {
    final elements = _evalExpressions(expr.elements, env);
    return object.Array(elements);
  } else if (expr is ast.Boolean) {
    return expr.value.toBooleanObject();
  } else if (expr is ast.Int) {
    throw Exception('unimplements');
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
    throw Exception('Unreachable');
  }
}

object.Object _evalProgram(ast.Program program, Environment env) =>
    _evalStatementsInScope(program.statements, env);

object.Object _evalBlock(ast.Block block, Environment env) =>
    _evalStatementsInScope(block.statements, env);

object.Object _evalStatementsInScope(
    List<ast.Stmt> statements, Environment env) {
  object.Object obj = builtin.constNull;
  for (final stmt in statements) {
    final value = _evalStmt(stmt, env);
    if (value is object.Return) {
      return value.value;
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
      throw Exception('unknown operator: $ope$right');
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
    throw Exception('unknown operator: -${right.runtimeType}');
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
      throw Exception(
          'unknown operator: ${left.runtimeType} $ope ${right.runtimeType}');
    } else {
      throw Exception('type: ${left.runtimeType} $ope ${right.runtimeType}');
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
    throw Exception('unknown oeperator: $ope');
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
    throw Exception('unknown operator: String $ope String');
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

  throw Exception('ientifier not found: ${ident.value}');
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
    throw Exception('not a function: ${func.runtimeType}');
  }
}

Environment _extendFunctionEnv(
    object.MFunction func, List<object.Object> args) {
  if (func.params.length != args.length) {
    throw Exception('not match args.');
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
  if (left is object.Array && index is object.Integer) {
    return _evalArrayIndexExpr(left, index);
  } else if (left is object.Hash && index is object.Hashable) {
    return _evalHashIndexExpr(left, index as object.Hashable);
  } else {
    throw Exception('index operator not supported');
  }
}

object.Object _evalArrayIndexExpr(object.Array array, object.Integer index) {
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
      throw Exception('unusable as hash key: $key');
    }
  }

  return object.Hash(pairs);
}

object.Object _evalHashIndexExpr(object.Hash hash, object.Hashable key) {
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
          throw Exception('unimplements');
        }
      } else {
        throw Exception('unimplements');
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
    throw Exception('unimplements');
  }
}

bool _isMacroDefinition(ast.Stmt stmt) =>
    stmt is ast.Let && stmt.value is ast.MacroLit;

void _addMacro(ast.Stmt stmt, Environment env) {
  if (stmt is! ast.Let) {
    throw Exception('expect Let. receive $stmt');
  }

  final value = stmt.value;
  if (value is! ast.MacroLit) {
    throw Exception('expect Macro. received $value');
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
    throw Exception('''
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
