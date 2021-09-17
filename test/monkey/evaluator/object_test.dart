import 'package:monkey/monkey.dart';
import 'package:monkey/monkey/ast.dart' as ast;
import 'package:monkey/monkey/evaluator/object.dart';
import 'package:test/test.dart';

void main() {
  group('toString', () {
    test('Integer', () {
      expect(Integer(1).toString(), '1');
      expect(Integer(100).toString(), '100');
      expect(Integer(-1).toString(), '-1');
    });

    test('Boolean', () {
      expect(const Boolean(true).toString(), 'true');
      expect(const Boolean(false).toString(), 'false');
    });

    test('StringLit', () {
      expect(StringLit('foo').toString(), '"foo"');
      expect(StringLit('foo bar').toString(), '"foo bar"');
    });

    test('Array', () {
      expect(Array([]).toString(), '[]');
      expect(
          Array([Integer(1), Integer(2), Integer(3)]).toString(), '[1, 2, 3]');
      expect(Array([Integer(1), Integer(2), Integer(3), Integer(4)]).toString(),
          '[1, 2, 3, 4]');
      expect(Array([StringLit('foo')]).toString(), '["foo"]');
      expect(
          Array([
            Integer(1),
            Array([
              Integer(2),
              Array([
                Integer(3),
              ]),
            ]),
          ]).toString(),
          '[1, [2, [3]]]');
    });

    test('Hash', () {
      expect(Hash({}).toString(), '{}');
      expect(Hash({Integer(1): Integer(2)}).toString(), '{1: 2}');
      expect(
        Hash({StringLit('foo'): StringLit('bar')}).toString(),
        '{"foo": "bar"}',
      );
      expect(
        Hash({
          Integer(1): Hash({
            Integer(2): Hash({
              Integer(3): Integer(4),
            }),
          }),
        }).toString(),
        '{1: {2: {3: 4}}}',
      );
    });

    test('MFunction', () {
      expect(
          MFunction([], ast.Block([]), Environment()).toString(), 'Function');
    });

    test('Builtin', () {
      expect(Builtin((_) => Integer(1)).toString(), 'Function');
    });

    test('Return', () {
      expect(Return(Integer(1)).toString(), 'Return');
    });

    test('Null', () {
      expect(const Null().toString(), 'null');
    });

    test('Macro', () {
      expect(
        Macro(
          [],
          ast.Block([]),
          Environment(),
        ).toString(),
        'Macro',
      );
    });

    test('Quote', () {
      expect(
        Quote(
          ast.Int(1),
        ).toString(),
        'Quote',
      );
    });
  });
}
