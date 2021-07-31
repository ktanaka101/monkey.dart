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

void main() {
  test('let statements', () {
    final inputs = [
      ['let x = 5', ast.Let(ast.Ident('x'), ast.Int(5))],
      ['let x = 5;', ast.Let(ast.Ident('x'), ast.Int(5))],
      ['let y = true;', ast.Let(ast.Ident('y'), ast.Boolean(true))],
      ['let foobar = y;', ast.Let(ast.Ident('foobar'), ast.Ident('y'))],
    ].map((input) =>
        Tuple2<String, ast.Let>(input[0] as String, input[1] as ast.Let));

    runTest<ast.Let>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testLetByStmt(program.statements[0], expected);
    });
  });

  test('return statements', () {
    final inputs = [
      ['return 5', ast.Return(ast.Int(5))],
      ['return 5;', ast.Return(ast.Int(5))],
      ['return true;', ast.Return(ast.Boolean(true))],
      ['return y;', ast.Return(ast.Ident('y'))],
    ].map((input) =>
        Tuple2<String, ast.Return>(input[0] as String, input[1] as ast.Return));

    runTest<ast.Return>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testReturnByStmt(program.statements[0], expected);
    });
  });

  test('identifier expressions', () {
    final inputs = [
      ['foobar', ast.Ident('foobar')]
    ].map((input) =>
        Tuple2<String, ast.Ident>(input[0] as String, input[1] as ast.Ident));

    runTest<ast.Ident>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testExprByStmt(program.statements[0], expected, testIdent);
    });
  });

  test('integer expressions', () {
    final inputs = [
      ['5', ast.Int(5)],
      ['5;', ast.Int(5)]
    ].map((input) =>
        Tuple2<String, ast.Int>(input[0] as String, input[1] as ast.Int));

    runTest<ast.Int>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testExprByStmt(program.statements[0], expected, testInt);
    });
  });

  test('boolean expressions', () {
    final inputs = [
      ['true', ast.Boolean(true)],
      ['true;', ast.Boolean(true)],
      ['false;', ast.Boolean(false)],
    ].map((input) => Tuple2<String, ast.Boolean>(
        input[0] as String, input[1] as ast.Boolean));

    runTest<ast.Boolean>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testExprByStmt(program.statements[0], expected, testBool);
    });
  });

  test('prefix expressions', () {
    final inputs = [
      ['!5', ast.PrefixExpr(ast.Operator.bang, ast.Int(5))],
      ['!5;', ast.PrefixExpr(ast.Operator.bang, ast.Int(5))],
      ['-15', ast.PrefixExpr(ast.Operator.minus, ast.Int(15))],
      ['!true;', ast.PrefixExpr(ast.Operator.bang, ast.Boolean(true))],
      ['!false;', ast.PrefixExpr(ast.Operator.bang, ast.Boolean(false))]
    ].map((input) => Tuple2<String, ast.PrefixExpr>(
        input[0] as String, input[1] as ast.PrefixExpr));

    runTest<ast.PrefixExpr>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testExprByStmt(program.statements[0], expected, testPrefixExpr);
    });
  });

  test('infix expressions', () {
    final inputs = [
      ['5 + 5', ast.InfixExpr(ast.Int(5), ast.Operator.plus, ast.Int(5))],
      ['5 + 5;', ast.InfixExpr(ast.Int(5), ast.Operator.plus, ast.Int(5))],
      ['5 - 5;', ast.InfixExpr(ast.Int(5), ast.Operator.minus, ast.Int(5))],
      ['5 * 5', ast.InfixExpr(ast.Int(5), ast.Operator.asterisk, ast.Int(5))],
      ['5 / 5', ast.InfixExpr(ast.Int(5), ast.Operator.slash, ast.Int(5))],
      ['5 > 5', ast.InfixExpr(ast.Int(5), ast.Operator.gt, ast.Int(5))],
      ['5 < 5', ast.InfixExpr(ast.Int(5), ast.Operator.lt, ast.Int(5))],
      ['5 == 5;', ast.InfixExpr(ast.Int(5), ast.Operator.equal, ast.Int(5))],
      ['5 != 5;', ast.InfixExpr(ast.Int(5), ast.Operator.notEqual, ast.Int(5))],
      [
        'true == true;',
        ast.InfixExpr(ast.Boolean(true), ast.Operator.equal, ast.Boolean(true))
      ],
      [
        'true != false;',
        ast.InfixExpr(
            ast.Boolean(true), ast.Operator.notEqual, ast.Boolean(false))
      ],
      [
        'false == false;',
        ast.InfixExpr(
            ast.Boolean(false), ast.Operator.equal, ast.Boolean(false))
      ]
    ].map((input) => Tuple2<String, ast.InfixExpr>(
        input[0] as String, input[1] as ast.InfixExpr));

    runTest<ast.InfixExpr>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testExprByStmt(program.statements[0], expected, testInfixExpr);
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
    final inputs = [
      [
        'if (x < y) { x };',
        ast.If(
          ast.InfixExpr(ast.Ident('x'), ast.Operator.lt, ast.Ident('y')),
          ast.Block([ast.ExprStmt(ast.Ident('x'))]),
          null,
        )
      ],
      [
        'if (x < y) { x } else { y }',
        ast.If(
          ast.InfixExpr(ast.Ident('x'), ast.Operator.lt, ast.Ident('y')),
          ast.Block([ast.ExprStmt(ast.Ident('x'))]),
          ast.Block([ast.ExprStmt(ast.Ident('y'))]),
        )
      ],
      [
        'if (x < y) { x; } else { y; }',
        ast.If(
          ast.InfixExpr(ast.Ident('x'), ast.Operator.lt, ast.Ident('y')),
          ast.Block([ast.ExprStmt(ast.Ident('x'))]),
          ast.Block([ast.ExprStmt(ast.Ident('y'))]),
        )
      ]
    ].map((input) =>
        Tuple2<String, ast.If>(input[0] as String, input[1] as ast.If));

    runTest<ast.If>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testExprByStmt(program.statements[0], expected, testIf);
    });
  });

  test('function expressions', () {
    final inputs = [
      [
        'fn(x, y) { x + y }',
        ast.MFunction(
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
      testExprByStmt(program.statements[0], expected, testFunction);
    });
  });

  test('function params expressions', () {
    final inputs = [
      [
        'fn() {};',
        ast.MFunction([], ast.Block([]), null),
      ],
      [
        'fn(x) {};',
        ast.MFunction([ast.Ident('x')], ast.Block([]), null),
      ],
      [
        'fn(x, y, z) {};',
        ast.MFunction([ast.Ident('x'), ast.Ident('y'), ast.Ident('z')],
            ast.Block([]), null),
      ]
    ].map((input) => Tuple2<String, ast.MFunction>(
        input[0] as String, input[1] as ast.MFunction));

    runTest<ast.MFunction>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testExprByStmt(program.statements[0], expected, testFunction);
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
      testExprByStmt(program.statements[0], expected, testCall);
    });
  });

  test('string expressions', () {
    final inputs = [
      ['"hello world"', ast.StringLit('hello world')]
    ].map((input) => Tuple2<String, ast.StringLit>(
        input[0] as String, input[1] as ast.StringLit));

    runTest<ast.StringLit>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testExprByStmt(program.statements[0], expected, testStringLit);
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
      testExprByStmt(program.statements[0], expected, testArray);
    });
  });

  test('index expressions', () {
    final inputs = [
      [
        'myArray[1 + 1]',
        ast.Index(
          ast.Ident('myArray'),
          ast.InfixExpr(ast.Int(1), ast.Operator.plus, ast.Int(1)),
        )
      ]
    ].map((input) =>
        Tuple2<String, ast.Index>(input[0] as String, input[1] as ast.Index));

    runTest<ast.Index>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testExprByStmt(program.statements[0], expected, testIndex);
    });
  });

  test('hash expressions', () {
    final inputs = [
      ['{}', ast.Hash([])],
      [
        '{ "one": 1, "two": 2, "three": 3 }',
        ast.Hash([
          ast.Pair(ast.StringLit('one'), ast.Int(1)),
          ast.Pair(ast.StringLit('two'), ast.Int(2)),
          ast.Pair(ast.StringLit('three'), ast.Int(3)),
        ])
      ],
      [
        '{ "one": 0 + 1, "two": 10 - 2, "three": 15 / 5 }',
        ast.Hash([
          ast.Pair(ast.StringLit('one'),
              ast.InfixExpr(ast.Int(0), ast.Operator.plus, ast.Int(1))),
          ast.Pair(ast.StringLit('two'),
              ast.InfixExpr(ast.Int(10), ast.Operator.minus, ast.Int(2))),
          ast.Pair(ast.StringLit('three'),
              ast.InfixExpr(ast.Int(15), ast.Operator.slash, ast.Int(5))),
        ])
      ],
      [
        '{ 1: 111, 2: "b", 3: true }',
        ast.Hash([
          ast.Pair(ast.Int(1), ast.Int(111)),
          ast.Pair(ast.Int(2), ast.StringLit('b')),
          ast.Pair(ast.Int(3), ast.Boolean(true)),
        ])
      ],
      [
        '{ true: 1, false: "abc" }',
        ast.Hash([
          ast.Pair(ast.Boolean(true), ast.Int(1)),
          ast.Pair(ast.Boolean(false), ast.StringLit('abc')),
        ])
      ],
    ].map((input) =>
        Tuple2<String, ast.Hash>(input[0] as String, input[1] as ast.Hash));

    runTest<ast.Hash>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testExprByStmt(program.statements[0], expected, testHash);
    });
  });

  test('macro literal expressions', () {
    final inputs = [
      [
        'macro(x, y) { x + y };',
        ast.MacroLit(
          [ast.Ident('x'), ast.Ident('y')],
          ast.Block([
            ast.ExprStmt(ast.InfixExpr(
              ast.Ident('x'),
              ast.Operator.plus,
              ast.Ident('y'),
            )),
          ]),
        )
      ],
    ].map((input) => Tuple2<String, ast.MacroLit>(
        input[0] as String, input[1] as ast.MacroLit));

    runTest<ast.MacroLit>(inputs, (program, expected) {
      expect(program.statements.length, 1);
      testExprByStmt(program.statements[0], expected, testMacroLit);
    });
  });
}

void testExprByStmt<T extends ast.Expr>(
    ast.Stmt actual, T expected, void Function(T, T) test) {
  final expr = expectExprStmt(actual);
  expect(expr, isA<T>());
  if (expr is T) {
    test(expr, expected);
  }
}

void testStmtByStmt<T extends ast.Stmt>(
    ast.Stmt actual, T expected, void Function(T, T) test) {
  expect(actual, isA<T>());
  if (actual is T) {
    test(actual, expected);
  }
}

void testList<T>(List<T> actual, List<T> expected, void Function(T, T) test) {
  expect(actual.length, expected.length);
  for (var i = 0; i < expected.length; i++) {
    test(actual[i], expected[i]);
  }
}

void testBlock(ast.Block actual, ast.Block expected) {
  testList(actual.statements, expected.statements, testStmt);
}

void testBlockByStmt(ast.Stmt actual, ast.Block expected) {
  testStmtByStmt(actual, expected, testBlock);
}

void testStmt(ast.Stmt actual, ast.Stmt expected) {
  expect(actual.runtimeType, expected.runtimeType);

  if (expected is ast.Let) {
    testLet(actual as ast.Let, expected);
  } else if (expected is ast.Return) {
    testReturn(actual as ast.Return, expected);
  } else if (expected is ast.Block) {
    testBlock(actual as ast.Block, expected);
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
    testLet(actual, expected);
  }
}

void testLet(ast.Let actual, ast.Let expected) {
  testIdent(actual.name, expected.name);
  testExpr(actual.value, expected.value);
}

void testReturnByStmt(ast.Stmt actual, ast.Return expected) {
  expect(actual, isA<ast.Return>());
  if (actual is ast.Return) {
    testReturn(actual, expected);
  }
}

void testReturn(ast.Return actual, ast.Return expected) {
  testExpr(actual.value, expected.value);
}

ast.Expr expectExprStmt(ast.Stmt actual) {
  expect(actual, isA<ast.ExprStmt>());
  if (actual is ast.ExprStmt) {
    return actual.expr;
  }

  throw Exception('Unreachable');
}

void testIdent(ast.Ident actual, ast.Ident expected) {
  expect(actual.value, expected.value);
}

void testExpr(ast.Expr actual, ast.Expr expected) {
  expect(actual.runtimeType, expected.runtimeType);

  if (expected is ast.Int) {
    testInt(actual as ast.Int, expected);
  } else if (expected is ast.Boolean) {
    testBool(actual as ast.Boolean, expected);
  } else if (expected is ast.Call) {
    testCall(actual as ast.Call, expected);
  } else if (expected is ast.Hash) {
    testHash(actual as ast.Hash, expected);
  } else if (expected is ast.Ident) {
    testIdent(actual as ast.Ident, expected);
  } else if (expected is ast.If) {
    testIf(actual as ast.If, expected);
  } else if (expected is ast.Index) {
    testIndex(actual as ast.Index, expected);
  } else if (expected is ast.InfixExpr) {
    testInfixExpr(actual as ast.InfixExpr, expected);
  } else if (expected is ast.MFunction) {
    testFunction(actual as ast.MFunction, expected);
  } else if (expected is ast.MacroLit) {
    testMacroLit(actual as ast.MacroLit, expected);
  } else if (expected is ast.PrefixExpr) {
    testPrefixExpr(actual as ast.PrefixExpr, expected);
  } else if (expected is ast.StringLit) {
    testStringLit(actual as ast.StringLit, expected);
  } else if (expected is ast.Array) {
    testArray(actual as ast.Array, expected);
  } else {
    throw Exception('unimplements');
  }
}

void testInt(ast.Int actual, ast.Int expected) {
  expect(actual.value, expected.value);
}

void testBool(ast.Boolean actual, ast.Boolean expected) {
  expect(actual.value, expected.value);
}

void testCall(ast.Call actual, ast.Call expected) {
  testExpr(actual.func, expected.func);
  testList(actual.args, expected.args, testExpr);
}

void testHash(ast.Hash actual, ast.Hash expected) {
  testList(actual.pairs, expected.pairs, testPair);
}

void testPair(ast.Pair actual, ast.Pair expected) {
  testExpr(actual.key, expected.key);
  testExpr(actual.value, expected.value);
}

void testIf(ast.If actual, ast.If expected) {
  testExpr(actual.cond, expected.cond);
  testBlock(actual.consequence, expected.consequence);
  if (expected.alternative == null) {
    expect(actual.alternative, null);
  } else {
    expect(actual.alternative, isNotNull);
    testBlock(actual.alternative!, expected.alternative!);
  }
}

void testIndex(ast.Index actual, ast.Index expected) {
  testExpr(actual.left, expected.left);
  testExpr(actual.index, expected.index);
}

void testInfixExpr(ast.InfixExpr actual, ast.InfixExpr expected) {
  testExpr(actual.left, expected.left);
  expect(actual.ope, expected.ope);
  testExpr(actual.right, expected.right);
}

void testFunction(ast.MFunction actual, ast.MFunction expected) {
  expect(actual.name, expected.name);
  testList(actual.params, expected.params, testIdent);
  testBlock(actual.body, expected.body);
}

void testMacroLit(ast.MacroLit actual, ast.MacroLit expected) {
  testList(actual.params, expected.params, testIdent);
  testBlock(actual.body, expected.body);
}

void testPrefixExpr(ast.PrefixExpr actual, ast.PrefixExpr expected) {
  expect(actual.ope, expected.ope);
  testExpr(actual.right, expected.right);
}

void testStringLit(ast.StringLit actual, ast.StringLit expected) {
  expect(actual.value, expected.value);
}

void testArray(ast.Array actual, ast.Array expected) {
  testList(actual.elements, expected.elements, testExpr);
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
