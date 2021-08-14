import 'package:monkey/monkey/error.dart';
import 'package:monkey/monkey/evaluator/env.dart' as env;
import 'package:monkey/monkey/evaluator/object.dart' as object;
import 'package:monkey/monkey/lexer.dart' as lexer;
import 'package:monkey/monkey/parser.dart' as parser;
import 'package:test/test.dart';
import 'package:monkey/monkey/evaluator.dart' as evaluator;

void main() {
  group('eval', () {
    test('integer expression', () {
      final tests = [
        ['5', 5],
        ['5', 5],
        ['10', 10],
        ['-5', -5],
        ['-10', -10],
        ['5 + 5 + 5 + 5 - 10', 10],
        ['2 * 2 * 2 * 2 * 2', 32],
        ['-50 + 100 + -50', 0],
        ['5 * 2 + 10', 20],
        ['5 + 2 * 10', 25],
        ['20 + 2 * -10', 0],
        ['50 / 2 * 2 + 10', 60],
        ['2 * (5 + 10)', 30],
        ['3 * 3 * 3 + 10', 37],
        ['3 * (3 * 3) + 10', 37],
        ['(5 + 10 * 2 + 15 / 3) * 2 + -10', 50],
      ];

      for (final test in tests) {
        expectIntegerObject(
            _testEval(test[0] as String), object.Integer(test[1] as int));
      }
    });

    test('boolean expression', () {
      final tests = [
        ['true', true],
        ['false', false],
        ['1 < 2', true],
        ['1 > 2', false],
        ['1 < 1', false],
        ['1 > 1', false],
        ['1 == 1', true],
        ['1 != 1', false],
        ['1 == 2', false],
        ['1 != 2', true],
        ['true == true', true],
        ['false == false', true],
        ['true == false', false],
        ['true != false', true],
        ['false != true', true],
        ['(1 < 2) == true', true],
        ['(1 < 2) == false', false],
        ['(1 > 2) == true', false],
        ['(1 > 2) == false', true],
      ];

      for (final test in tests) {
        expectBooleanObject(
            _testEval(test[0] as String), object.Boolean(test[1] as bool));
      }
    });
  });

  test('bang operator', () {
    final tests = [
      ['!true', false],
      ['!false', true],
      ['!5', false],
      ['!!true', true],
      ['!!false', false],
      ['!!5', true],
    ];

    for (final test in tests) {
      expectBooleanObject(
          _testEval(test[0] as String), object.Boolean(test[1] as bool));
    }
  });

  test('if-else expression', () {
    final tests = [
      ['if (true) { 10 }', object.Integer(10)],
      ['if (1) { 10 }', object.Integer(10)],
      ['if ( 1 < 2 ) { 10 }', object.Integer(10)],
      ['if ( 1 > 2 ) { 10 } else { 20 }', object.Integer(20)],
      ['if ( 1 < 2 ) { 10 } else { 20 }', object.Integer(10)],
      ['if (false) { 10 }', const object.Null()],
      ['if ( 1 > 2 ) { 10 }', const object.Null()]
    ];

    for (final test in tests) {
      expectObject(_testEval(test[0] as String), test[1] as object.Object);
    }
  });

  test('return statement', () {
    final tests = [
      ['return 10;', 10],
      ['return 10; 9;', 10],
      ['return 2 * 5; 9;', 10],
      ['9; return 2 * 5; 9;', 10],
      [
        '''
          if (10 > 1) {
              if (10 > 1) {
                  return 10;
              }
          }

          return 1;
        ''',
        10,
      ],
    ];

    for (final test in tests) {
      expectObject(
          _testEval(test[0] as String), object.Integer(test[1] as int));
    }
  });

  test('error handling', () {
    final tests = [
      ['5 + true;', 'type mismatch: Integer + Boolean'],
      ['5 + true; 5;', 'type mismatch: Integer + Boolean'],
      ['-true', 'unknown operator: -Boolean'],
      ['true + false;', 'unknown operator: Boolean + Boolean'],
      ['5; true + false; 5', 'unknown operator: Boolean + Boolean'],
      [
        'if (10 > 1 ) { true + false; }',
        'unknown operator: Boolean + Boolean',
      ],
      [
        '''
          if (10 > 1) {
            if (10 > 1) {
                return true + false;
            }
            return 1;
          }
        ''',
        'unknown operator: Boolean + Boolean',
      ],
      ['foobar', 'identifier not found: foobar'],
      ['"Hello" - "World"', 'unknown operator: String - String'],
      [
        '[1, 2, 3][fn(x) { x }];',
        'unusable as array key: MFunction',
      ],
      [
        '{"name": "Monkey"}[fn(x) { x }];',
        'unusable as hash key: MFunction',
      ],
      [
        '{fn(x) { x }: "Monkey"}[0];',
        'unusable as hash key: MFunction',
      ],
    ];
    for (final test in tests) {
      try {
        _testEval(test[0]);
        expect('', test[1]);
      } on MonkeyException catch (e) {
        expect(e.msg, test[1]);
      }
    }
  });

  test('let statement', () {
    final tests = [
      ['let a = 5; a;', 5],
      ['let a = 5 * 5; a;', 25],
      ['let a = 5; let b = a; b;', 5],
      ['let a = 5; let b = a; let c = a + b + 5; c;', 15],
    ];

    for (final test in tests) {
      expectObject(
          _testEval(test[0] as String), object.Integer(test[1] as int));
    }
  });
}

object.Object _testEval(String input) {
  final l = lexer.Lexer(input);
  final p = parser.Parser(l);
  final program = p.parseProgram();
  final e = env.Environment();

  return evaluator.eval(program, e);
}

void expectObject(object.Object actual, object.Object expected) {
  expect(actual.runtimeType, expected.runtimeType);

  if (expected is object.Integer) {
    expectIntegerObject(actual, expected);
  } else if (expected is object.Boolean) {
    expectBooleanObject(actual, expected);
  } else if (expected is object.Null) {
    expectNullObject(actual);
  } else {
    throw Exception('unimplements');
  }
}

void expectIntegerObject(object.Object actual, object.Integer expected) {
  expect(actual, isA<object.Integer>());
  if (actual is! object.Integer) {
    return;
  }

  expect(actual.value, expected.value);
}

void expectBooleanObject(object.Object actual, object.Boolean expected) {
  expect(actual, isA<object.Boolean>());
  if (actual is! object.Boolean) {
    return;
  }

  expect(actual.value, expected.value);
}

void expectNullObject(object.Object actual) {
  expect(actual, isA<object.Null>());
}
