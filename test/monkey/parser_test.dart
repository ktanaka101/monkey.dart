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
ast.If createExpectedIf(
        ast.Expr cond, ast.Block consequence, ast.Block? alternative) =>
    ast.If(cond, consequence, alternative);
ast.MFunction createExpectedFunctionExpr(
        List<ast.Ident> params, ast.Block body, String? name) =>
    ast.MFunction(params, body, name);

void main() {
  test('let statements', () {
    const e = createExpectedLet;
    final inputs = [
      ['let x = 5', e('x', ast.Int(5))],
      ['let x = 5;', e('x', ast.Int(5))],
      ['let y = true;', e('y', ast.Boolean(true))],
      ['let foobar = y;', e('foobar', ast.Ident('y'))],
    ].map((input) =>
        Tuple2<String, ast.Let>(input[0] as String, input[1] as ast.Let));

    runTest<ast.Let>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testLetByStmt(program.statements[0], expected);
    });
  });

  test('return statements', () {
    const e = createExpectedReturn;
    final inputs = [
      ['return 5', e(ast.Int(5))],
      ['return 5;', e(ast.Int(5))],
      ['return true;', e(ast.Boolean(true))],
      ['return y;', e(ast.Ident('y'))],
    ].map((input) =>
        Tuple2<String, ast.Return>(input[0] as String, input[1] as ast.Return));

    runTest<ast.Return>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testReturnByStmt(program.statements[0], expected);
    });
  });

  test('identifier expressions', () {
    const e = createExpectedIdent;
    final inputs = [
      ['foobar', e('foobar')]
    ].map((input) =>
        Tuple2<String, ast.Ident>(input[0] as String, input[1] as ast.Ident));

    runTest<ast.Ident>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testIdentByStmt(program.statements[0], expected);
    });
  });

  test('integer expressions', () {
    const e = createExpectedInt;
    final inputs = [
      ['5', e(5)],
      ['5;', e(5)]
    ].map((input) =>
        Tuple2<String, ast.Int>(input[0] as String, input[1] as ast.Int));

    runTest<ast.Int>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testIntByStmt(program.statements[0], expected);
    });
  });

  test('boolean expressions', () {
    const e = createExpectedBool;
    final inputs = [
      ['true', e(true)],
      ['true;', e(true)],
      ['false;', e(false)],
    ].map((input) => Tuple2<String, ast.Boolean>(
        input[0] as String, input[1] as ast.Boolean));

    runTest<ast.Boolean>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testBoolByStmt(program.statements[0], expected);
    });
  });

  test('prefix expressions', () {
    const e = createExpectedPrefixExpr;
    final inputs = [
      ['!5', e(ast.Operator.bang, ast.Int(5))],
      ['!5;', e(ast.Operator.bang, ast.Int(5))],
      ['-15', e(ast.Operator.minus, ast.Int(15))],
      ['!true;', e(ast.Operator.bang, ast.Boolean(true))],
      ['!false;', e(ast.Operator.bang, ast.Boolean(false))]
    ].map((input) => Tuple2<String, ast.PrefixExpr>(
        input[0] as String, input[1] as ast.PrefixExpr));

    runTest<ast.PrefixExpr>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testPrefixExprByStmt(program.statements[0], expected);
    });
  });

  test('infix expressions', () {
    const e = createExpectedInfixExpr;
    final inputs = [
      ['5 + 5', e(ast.Int(5), ast.Operator.plus, ast.Int(5))],
      ['5 + 5;', e(ast.Int(5), ast.Operator.plus, ast.Int(5))],
      ['5 - 5;', e(ast.Int(5), ast.Operator.minus, ast.Int(5))],
      ['5 * 5', e(ast.Int(5), ast.Operator.asterisk, ast.Int(5))],
      ['5 / 5', e(ast.Int(5), ast.Operator.slash, ast.Int(5))],
      ['5 > 5', e(ast.Int(5), ast.Operator.gt, ast.Int(5))],
      ['5 < 5', e(ast.Int(5), ast.Operator.lt, ast.Int(5))],
      ['5 == 5;', e(ast.Int(5), ast.Operator.equal, ast.Int(5))],
      ['5 != 5;', e(ast.Int(5), ast.Operator.notEqual, ast.Int(5))],
      [
        'true == true;',
        e(ast.Boolean(true), ast.Operator.equal, ast.Boolean(true))
      ],
      [
        'true != false;',
        e(ast.Boolean(true), ast.Operator.notEqual, ast.Boolean(false))
      ],
      [
        'false == false;',
        e(ast.Boolean(false), ast.Operator.equal, ast.Boolean(false))
      ]
    ].map((input) => Tuple2<String, ast.InfixExpr>(
        input[0] as String, input[1] as ast.InfixExpr));

    runTest<ast.InfixExpr>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testInfixExprByStmt(program.statements[0], expected);
    });
  });

  test('operator precedence parsing', () {
    final inputs = [
      ['-a * b', '((-a) * b);'],
      ['!-a', '(!(-a));'],
      ['a + b + c', '((a + b) + c);'],
      ['a + b - c', '((a + b) - c);'],
      ['a * b * c', '((a * b) * c);'],
      ['a * b / c', '((a * b) / c);'],
      ['a + b / c', '(a + (b / c));'],
      ['a + b * c + d / e - f', '(((a + (b * c)) + (d / e)) - f);'],
      ['3 + 4; -5 * 5', '(3 + 4);((-5) * 5);'],
      ['5 > 4 == 3 < 4', '((5 > 4) == (3 < 4));'],
      ['5 < 4 != 3 > 4', '((5 < 4) != (3 > 4));'],
      [
        '3 + 4 * 5 == 3 * 1 + 4 * 5',
        '((3 + (4 * 5)) == ((3 * 1) + (4 * 5)));',
      ],
      ['true', 'true;'],
      ['false', 'false;'],
      ['3 > 5 == false', '((3 > 5) == false);'],
      ['3 < 5 == true', '((3 < 5) == true);'],
      ['1 + (2 + 3) + 4', '((1 + (2 + 3)) + 4);'],
      ['(5 + 5) * 2', '((5 + 5) * 2);'],
      ['2 / (5 + 5)', '(2 / (5 + 5));'],
      ['-(5 + 5)', '(-(5 + 5));'],
      ['!(true == true)', '(!(true == true));'],
      ['a + add(b * c) + d', '((a + add((b * c))) + d);'],
      [
        'add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8));',
        'add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)));',
      ],
      [
        'add(a + b + c * d / f  + g)',
        'add((((a + b) + ((c * d) / f)) + g));',
      ],
      [
        'a * [1, 2, 3, 4][b * c] * d',
        '((a * ([1, 2, 3, 4][(b * c)])) * d);',
      ],
      [
        'add(a * b[2], b[1], 2 * [1, 2][1])',
        'add((a * (b[2])), (b[1]), (2 * ([1, 2][1])));',
      ],
    ].map((input) => Tuple2<String, String>(input[0], input[1]));

    runTest<String>(inputs, (program, expected) {
      expect(program.toString(), expected);
    });
  });

  test('if else expressions', () {
    const e = createExpectedIf;
    final inputs = [
      [
        'if (x < y) { x };',
        e(
          ast.InfixExpr(ast.Ident('x'), ast.Operator.lt, ast.Ident('y')),
          ast.Block([ast.ExprStmt(ast.Ident('x'))]),
          null,
        )
      ],
      [
        'if (x < y) { x } else { y }',
        e(
          ast.InfixExpr(ast.Ident('x'), ast.Operator.lt, ast.Ident('y')),
          ast.Block([ast.ExprStmt(ast.Ident('x'))]),
          ast.Block([ast.ExprStmt(ast.Ident('y'))]),
        )
      ],
      [
        'if (x < y) { x; } else { y; }',
        e(
          ast.InfixExpr(ast.Ident('x'), ast.Operator.lt, ast.Ident('y')),
          ast.Block([ast.ExprStmt(ast.Ident('x'))]),
          ast.Block([ast.ExprStmt(ast.Ident('y'))]),
        )
      ]
    ].map((input) =>
        Tuple2<String, ast.If>(input[0] as String, input[1] as ast.If));

    runTest<ast.If>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testIfByStmt(program.statements[0], expected);
    });
  });

  test('function expressions', () {
    const e = createExpectedFunctionExpr;
    final inputs = [
      [
        'fn(x, y) { x + y }',
        e(
            [ast.Ident('x'), ast.Ident('y')],
            ast.Block([
              ast.ExprStmt(ast.InfixExpr(
                ast.Ident('x'),
                ast.Operator.plus,
                ast.Ident('y'),
              ))
            ]),
            null),
      ]
    ].map((input) => Tuple2<String, ast.MFunction>(
        input[0] as String, input[1] as ast.MFunction));

    runTest<ast.MFunction>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testFunctionByStmt(program.statements[0], expected);
    });
  });

  test('function params expressions', () {
    const e = createExpectedFunctionExpr;
    final inputs = [
      [
        'fn() {};',
        e([], ast.Block([]), null),
      ],
      [
        'fn(x) {};',
        e([ast.Ident('x')], ast.Block([]), null),
      ],
      [
        'fn(x, y, z) {};',
        e([ast.Ident('x'), ast.Ident('y'), ast.Ident('z')], ast.Block([]),
            null),
      ]
    ].map((input) => Tuple2<String, ast.MFunction>(
        input[0] as String, input[1] as ast.MFunction));

    runTest<ast.MFunction>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testFunctionByStmt(program.statements[0], expected);
    });
  });

  test('call expressions', () {
    final inputs = [
      [
        'add(1, 2 * 3, 4 + 5);',
        ast.Call(ast.Ident('add'), [
          ast.Int(1),
          ast.InfixExpr(ast.Int(2), ast.Operator.asterisk, ast.Int(3)),
          ast.InfixExpr(ast.Int(4), ast.Operator.plus, ast.Int(5)),
        ]),
      ]
    ].map((input) =>
        Tuple2<String, ast.Call>(input[0] as String, input[1] as ast.Call));

    runTest<ast.Call>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testCallByStmt(program.statements[0], expected);
    });
  });

  test('string expressions', () {
    final inputs = [
      ['"hello world"', ast.StringLit('hello world')]
    ].map((input) => Tuple2<String, ast.StringLit>(
        input[0] as String, input[1] as ast.StringLit));

    runTest<ast.StringLit>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testStringLitByStmt(program.statements[0], expected);
    });
  });

  test('array expressions', () {
    final inputs = [
      [
        '[1, 2 * 2, 3 + 3]',
        ast.Array([
          ast.Int(1),
          ast.InfixExpr(ast.Int(2), ast.Operator.asterisk, ast.Int(2)),
          ast.InfixExpr(ast.Int(3), ast.Operator.plus, ast.Int(3)),
        ])
      ]
    ].map((input) =>
        Tuple2<String, ast.Array>(input[0] as String, input[1] as ast.Array));

    runTest<ast.Array>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testArrayByStmt(program.statements[0], expected);
    });
  });

  test('index expressions', () {
    final inputs = [
      [
        'myArray[1 + 1]',
        ast.Index(
          ast.Ident('myArray'),
          ast.InfixExpr(ast.Int(1), ast.Operator.asterisk, ast.Int(1)),
        )
      ]
    ].map((input) =>
        Tuple2<String, ast.Index>(input[0] as String, input[1] as ast.Index));

    runTest<ast.Index>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testIndexByStmt(program.statements[0], expected);
    });
  });
}

void testIndexByStmt(ast.Stmt actual, ast.Index expected) {
  final expr = expectExprStmt(actual);
  expect(expr, isA<ast.Index>());
  if (expr is ast.Index) {
    testExpr(expr.left, expected.left);
    testExpr(expr.index, expected.index);
  }
}

void testArrayByStmt(ast.Stmt actual, ast.Array expected) {
  final expr = expectExprStmt(actual);
  expect(expr, isA<ast.Array>());
  if (expr is ast.Array) {
    testExprList(expr.elements, expected.elements);
  }
}

void testStringLitByStmt(ast.Stmt actual, ast.StringLit expected) {
  final expr = expectExprStmt(actual);
  expect(expr, isA<ast.StringLit>());
  if (expr is ast.StringLit) {
    expect(expr.value, expected.value);
  }
}

void testCallByStmt(ast.Stmt actual, ast.Call expected) {
  final expr = expectExprStmt(actual);
  expect(expr, isA<ast.Call>());
  if (expr is ast.Call) {
    testExpr(expr.func, expected.func);
    testExprList(expr.args, expected.args);
  }
}

void testExprList(List<ast.Expr> actual, List<ast.Expr> expected) {
  for (var i = 0; i < expected.length; i++) {
    testExpr(actual[i], expected[i]);
  }
}

void testFunctionByStmt(ast.Stmt actual, ast.MFunction expected) {
  final expr = expectExprStmt(actual);
  expect(expr, isA<ast.MFunction>());
  if (expr is ast.MFunction) {
    expect(expr.name, expected.name);
    testExprList(expr.params, expected.params);
    testBlock(expr.body, expected.body);
  }
}

void testIfByStmt(ast.Stmt actual, ast.If expected) {
  final expr = expectExprStmt(actual);
  expect(expr, isA<ast.If>());
  if (expr is ast.If) {
    testExpr(expr.cond, expected.cond);
    testBlock(expr.consequence, expected.consequence);
    if (expected.alternative == null) {
      expect(expr.alternative, null);
    } else {
      expect(expr.alternative, isNotNull);
      testBlock(expr.alternative!, expected.alternative!);
    }
  }
}

void testBlock(ast.Block actual, ast.Block expected) {
  expect(actual.statements.length, expected.statements.length);
  for (var i = 0; i < expected.statements.length; i++) {
    testStmt(actual.statements[i], expected.statements[i]);
  }
}

void testBlockByStmt(ast.Stmt actual, ast.Block expected) {
  expect(actual, isA<ast.Block>());
  if (actual is ast.Block) {
    testBlock(actual, expected);
  }
}

void testStmt(ast.Stmt actual, ast.Stmt expected) {
  if (expected is ast.Let) {
    testLetByStmt(actual, expected);
  } else if (expected is ast.Return) {
    testReturnByStmt(actual, expected);
  } else if (expected is ast.Block) {
    testBlockByStmt(actual, expected);
  } else if (expected is ast.ExprStmt) {
    testExprStmtByStmt(actual, expected);
  } else {
    throw Exception('Unimplements');
  }
}

void testExprStmtByStmt(ast.Stmt actual, ast.ExprStmt expected) {
  final expr = expectExprStmt(actual);
  testExpr(expr, expected.expr);
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

void runTest<T>(Iterable<Tuple2<String, T>> inputs,
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
