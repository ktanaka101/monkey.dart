import 'package:monkey/monkey/evaluator/env.dart';
import 'package:monkey/monkey/evaluator/object.dart' as object;
import 'package:test/test.dart';

void main() {
  test('get object by env', () {
    final env = Environment();
    const obj = object.Boolean(true);
    env.insert('key_a', obj);
    final getObj = env.resolve('key_a');
    expect(obj, equals(getObj));
  });

  test('get object by outer env', () {
    final outerEnv = Environment();
    const obj1 = object.Boolean(true);
    outerEnv.insert('key_a', obj1);

    final env = Environment(outer: outerEnv);
    const obj2 = object.Boolean(false);
    env.insert('key_b', obj2);

    final getObj = env.resolve('key_a');
    expect(obj1, equals(getObj));
  });

  test('get by giving priority to scope', () {
    final outerEnv = Environment();
    const obj1 = object.Boolean(true);
    outerEnv.insert('key_a', obj1);

    final env = Environment(outer: outerEnv);
    const obj2 = object.Boolean(false);
    env.insert('key_a', obj2);

    final getObj = env.resolve('key_a');
    expect(obj2, equals(getObj));
  });
}
