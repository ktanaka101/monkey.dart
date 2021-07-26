import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import 'package:monkey/monkey/lexer.dart';
import 'package:monkey/monkey/parser.dart';
import 'package:monkey/monkey/parser/ast.dart' as ast;

class TestValue {}

class TestInt extends TestValue {
  TestInt(this.value);
  final int value;
}

class TestIdent extends TestValue {
  TestIdent(this.value);
  final String value;
}

class TestBool extends TestValue {
  // ignore: avoid_positional_boolean_parameters
  TestBool(this.value);
  final bool value;
}

class TestLet extends TestValue {
  TestLet(this.name, this.value);
  final String name;
  final TestValue value;
}

typedef TestLetStmt = Tuple2<String, ast.Let>;
typedef TestReturnStmt = Tuple2<String, ast.Return>;
typedef TestIdentExpr = Tuple2<String, ast.Ident>;
typedef TestIntExpr = Tuple2<String, ast.Int>;
typedef TestBoolExpr = Tuple2<String, ast.Boolean>;
typedef TestPrefixExpr = Tuple2<String, ast.PrefixExpr>;
typedef TestInfixExpr = Tuple2<String, ast.InfixExpr>;

ast.Let createExpectedLet(String name, ast.Expr expr) =>
    ast.Let(ast.Ident(name), expr);

ast.Return createExpectedReturn(ast.Expr expr) => ast.Return(expr);
ast.Ident createExpectedIdent(String ident) => ast.Ident(ident);
ast.Int createExpectedInt(int value) => ast.Int(value);
// ignore: avoid_positional_boolean_parameters
ast.Boolean createExpectedBool(bool value) => ast.Boolean(value);
ast.PrefixExpr createExpectedPrefixExpr(ast.Operator ope, ast.Expr expr) =>
    ast.PrefixExpr(ope, expr);

ast.InfixExpr createExpectedInfixExpr(
        ast.Expr left, ast.Operator ope, ast.Expr right) =>
    ast.InfixExpr(left, ope, right);

void main() {
  test('let statements', () {
    const e = createExpectedLet;
    final inputs = [
      TestLetStmt('let x = 5', e('x', ast.Int(5))),
      TestLetStmt('let x = 5;', e('x', ast.Int(5))),
      TestLetStmt('let y = true;', e('y', ast.Boolean(true))),
      TestLetStmt('let foobar = y;', e('foobar', ast.Ident('y'))),
    ];

    runTest<ast.Let>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testLetByStmt(program.statements[0], expected);
    });
  });

  test('return statements', () {
    const e = createExpectedReturn;
    final inputs = [
      TestReturnStmt('return 5', e(ast.Int(5))),
      TestReturnStmt('return 5;', e(ast.Int(5))),
      TestReturnStmt('return true;', e(ast.Boolean(true))),
      TestReturnStmt('return y;', e(ast.Ident('y'))),
    ];

    runTest<ast.Return>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testReturnByStmt(program.statements[0], expected);
    });
  });

  test('identifier expressions', () {
    const e = createExpectedIdent;
    final inputs = [TestIdentExpr('foobar', e('foobar'))];

    runTest<ast.Ident>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testIdentByStmt(program.statements[0], expected);
    });
  });

  test('integer expressions', () {
    const e = createExpectedInt;
    final inputs = [TestIntExpr('5', e(5)), TestIntExpr('5;', e(5))];

    runTest<ast.Int>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testIntByStmt(program.statements[0], expected);
    });
  });

  test('boolean expressions', () {
    const e = createExpectedBool;
    final inputs = [
      TestBoolExpr('true', e(true)),
      TestBoolExpr('true;', e(true)),
      TestBoolExpr('false;', e(false)),
    ];

    runTest<ast.Boolean>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testBoolByStmt(program.statements[0], expected);
    });
  });

  test('prefix expressions', () {
    const e = createExpectedPrefixExpr;
    final inputs = [
      TestPrefixExpr('!5', e(ast.Operator.bang, ast.Int(5))),
      TestPrefixExpr('!5;', e(ast.Operator.bang, ast.Int(5))),
      TestPrefixExpr('-15', e(ast.Operator.minus, ast.Int(15))),
      TestPrefixExpr('!true;', e(ast.Operator.bang, ast.Boolean(true))),
      TestPrefixExpr('!false;', e(ast.Operator.bang, ast.Boolean(false)))
    ];

    runTest<ast.PrefixExpr>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testPrefixExprByStmt(program.statements[0], expected);
    });
  });

  test('infix expressions', () {
    const e = createExpectedInfixExpr;
    final inputs = [
      TestInfixExpr('5 + 5', e(ast.Int(5), ast.Operator.plus, ast.Int(5))),
      TestInfixExpr('5 + 5;', e(ast.Int(5), ast.Operator.plus, ast.Int(5))),
      TestInfixExpr('5 - 5;', e(ast.Int(5), ast.Operator.minus, ast.Int(5))),
      TestInfixExpr('5 * 5', e(ast.Int(5), ast.Operator.asterisk, ast.Int(5))),
      TestInfixExpr('5 / 5', e(ast.Int(5), ast.Operator.slash, ast.Int(5))),
      TestInfixExpr('5 > 5', e(ast.Int(5), ast.Operator.gt, ast.Int(5))),
      TestInfixExpr('5 < 5', e(ast.Int(5), ast.Operator.lt, ast.Int(5))),
      TestInfixExpr('5 == 5;', e(ast.Int(5), ast.Operator.equal, ast.Int(5))),
      TestInfixExpr(
          '5 != 5;', e(ast.Int(5), ast.Operator.notEqual, ast.Int(5))),
      TestInfixExpr('true == true;',
          e(ast.Boolean(true), ast.Operator.equal, ast.Boolean(true))),
      TestInfixExpr('true != false;',
          e(ast.Boolean(true), ast.Operator.notEqual, ast.Boolean(false))),
      TestInfixExpr('false == false;',
          e(ast.Boolean(false), ast.Operator.equal, ast.Boolean(false)))
    ];

    runTest<ast.InfixExpr>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testInfixExprByStmt(program.statements[0], expected);
    });
  });

  test('operator precedence parsing', () {});
}

void testLetByStmt(ast.Stmt actual, ast.Let expected) {
  expect(actual, isA<ast.Let>());
  if (actual is ast.Let) {
    testIdent(actual.name, expected.name);
    testExpr(actual.value, expected.value);
  }
}

void testReturnByStmt(ast.Stmt actual, ast.Return expected) {
  expect(actual, isA<ast.Return>());
  if (actual is ast.Return) {
    testExpr(actual.value, expected.value);
  }
}

void testIdentByStmt(ast.Stmt actual, ast.Ident expected) {
  final expr = expectExprStmt(actual);
  expect(expr, isA<ast.Ident>());
  if (expr is ast.Ident) {
    expect(expr.value, expected.value);
  }
}

ast.Expr expectExprStmt(ast.Stmt actual) {
  expect(actual, isA<ast.ExprStmt>());
  if (actual is ast.ExprStmt) {
    return actual.expr;
  }

  throw Exception('Unreachable');
}

void testIntByStmt(ast.Stmt actual, ast.Int expected) {
  final expr = expectExprStmt(actual);
  expect(expr, isA<ast.Int>());
  if (expr is ast.Int) {
    expect(expr.value, expected.value);
  }
}

void testBoolByStmt(ast.Stmt actual, ast.Boolean expected) {
  final expr = expectExprStmt(actual);
  expect(expr, isA<ast.Boolean>());
  if (expr is ast.Boolean) {
    expect(expr.value, expected.value);
  }
}

void testPrefixExprByStmt(ast.Stmt actual, ast.PrefixExpr expected) {
  final expr = expectExprStmt(actual);
  expect(expr, isA<ast.PrefixExpr>());
  if (expr is ast.PrefixExpr) {
    expect(expr.ope, expected.ope);
    testExpr(expr.right, expected.right);
  }
}

void testInfixExprByStmt(ast.Stmt actual, ast.InfixExpr expected) {
  final expr = expectExprStmt(actual);
  expect(expr, isA<ast.InfixExpr>());
  if (expr is ast.InfixExpr) {
    testExpr(expr.left, expected.left);
    expect(expr.ope, expected.ope);
    testExpr(expr.right, expected.right);
  }
}

void testIdent(ast.Ident actual, ast.Ident expected) {
  expect(actual.value, expected.value);
}

void testExpr(ast.Expr actual, ast.Expr expected) {
  expect(actual.runtimeType, expected.runtimeType);

  if (actual is ast.Int) {
    testInt(actual, expected as ast.Int);
  } else {
    expect(actual.runtimeType, expected.runtimeType);
  }
}

void testInt(ast.Int actual, ast.Int expected) {
  expect(actual.value, expected.value);
}

void runTest<T>(List<Tuple2<String, T>> inputs,
    void Function(ast.Program, T) runExpecting) {
  for (final input in inputs) {
    final program = testParse(input.item1);
    runExpecting(program, input.item2);
  }
}

ast.Program testParse(String input) {
  final lexer = Lexer(input);
  final parser = Parser(lexer);
  return parser.parseProgram();
}
