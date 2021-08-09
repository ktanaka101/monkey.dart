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
  });
}

object.Object _testEval(String input) {
  final l = lexer.Lexer(input);
  final p = parser.Parser(l);
  final program = p.parseProgram();
  final e = env.Environment();

  return evaluator.eval(program, e);
}

void expectIntegerObject(object.Object actual, object.Integer expected) {
  expect(actual, isA<object.Integer>());
  if (actual is! object.Integer) {
    return;
  }

  expect(actual.value, expected.value);
}
