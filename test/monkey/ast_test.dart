import 'package:monkey/monkey/ast.dart';
import 'package:test/test.dart';

void main() {
  test('Program#toString', () {
    final statements = [
      ExprStmt(Int(10)),
      Let(Ident('x'), Int(30)),
    ];
    final program = Program(statements);
    expect(program.toString(), '10;let x = 30;');
  });

  test('Let#toString', () {
    final let = Let(Ident('xxx'), Int(100));
    expect(let.toString(), 'let xxx = 100;');
  });

  test('Return#toString', () {
    final ret = Return(Int(100));
    expect(ret.toString(), 'return 100;');
  });

  test('Block#toString', () {
    {
      final statements = [
        ExprStmt(Int(10)),
        ExprStmt(StringLit('xxxxx')),
      ];
      final block = Block(statements);
      expect(block.toString(), '{ 10;"xxxxx"; }');
    }

    {
      final block = Block([]);
      expect(block.toString(), '{  }');
    }
  });

  test('ExprStmt#toString', () {
    final exprStmt = ExprStmt(Int(10));
    expect(exprStmt.toString(), '10;');
  });

  test('Operator#toCode', () {
    expect(Operator.assign.toCode(), '=');
    expect(Operator.asterisk.toCode(), '*');
    expect(Operator.bang.toCode(), '!');
    expect(Operator.equal.toCode(), '==');
    expect(Operator.gt.toCode(), '>');
    expect(Operator.lt.toCode(), '<');
    expect(Operator.minus.toCode(), '-');
    expect(Operator.notEqual.toCode(), '!=');
    expect(Operator.plus.toCode(), '+');
    expect(Operator.slash.toCode(), '/');
  });

  test('InfixExpr#toString', () {
    final infixExpr = InfixExpr(Int(10), Operator.plus, Int(30));
    expect(infixExpr.toString(), '(10 + 30)');
  });

  test('PrefixExpr#toString', () {
    final prefixExpr = PrefixExpr(Operator.minus, Int(10));
    expect(prefixExpr.toString(), '(-10)');
  });

  test('If#toString', () {
    {
      final cond = Boolean(true);
      final consequence = Block([
        ExprStmt(Int(10)),
        ExprStmt(Int(20)),
      ]);
      final alternative = Block([
        ExprStmt(Int(30)),
        ExprStmt(Int(40)),
      ]);
      final ifExpr = If(cond, consequence, alternative);
      expect(ifExpr.toString(), 'if (true) { 10;20; } else { 30;40; }');
    }

    {
      final cond = Boolean(true);
      final consequence = Block([
        ExprStmt(Int(10)),
        ExprStmt(Int(20)),
      ]);
      final ifExpr = If(cond, consequence, null);
      expect(ifExpr.toString(), 'if (true) { 10;20; }');
    }
  });

  test('Ident#toString', () {
    {
      final ident = Ident('xxxxx');
      expect(ident.toString(), 'xxxxx');
    }

    {
      final ident = Ident('yyyyy');
      expect(ident.toString(), 'yyyyy');
    }
  });

  test('Call#toString', () {
    final func = Ident('function');
    final args = [Int(30), Ident('arg1')];

    {
      final call = Call(func, args);
      expect(call.toString(), 'function(30, arg1)');
    }

    {
      final call = Call(func, []);
      expect(call.toString(), 'function()');
    }
  });

  test('MFunction#toString', () {
    {
      final params = [Ident('argA'), Ident('argB')];
      final body = Block([
        ExprStmt(Int(10)),
        ExprStmt(StringLit('stringA')),
      ]);
      const name = 'funcA';

      final func = MFunction(params, body, name);
      expect(func.toString(), 'fn funcA(argA, argB) { 10;"stringA"; }');
    }

    {
      final func = MFunction([], Block([]), 'funcB');
      expect(func.toString(), 'fn funcB() {  }');
    }
  });

  test('Index#toString', () {
    {
      final left = Array([Int(10), Int(20)]);
      final index = Index(left, Int(0));
      expect(index.toString(), '([10, 20][0])');
    }

    {
      final left = Array([]);
      final index = Index(left, Int(0));
      expect(index.toString(), '([][0])');
    }

    {
      final left = Ident('arr');
      final index = Index(left, Int(0));
      expect(index.toString(), '(arr[0])');
    }
  });

  test('MacroLit#toString', () {
    {
      final params = [Ident('arg1'), Ident('arg2')];
      final block = Block([
        ExprStmt(Int(10)),
        ExprStmt(Int(20)),
      ]);
      final macro = MacroLit(params, block);
      expect(macro.toString(), 'macro(arg1, arg2) { 10;20; }');
    }

    {
      final macro = MacroLit([], Block([]));
      expect(macro.toString(), 'macro() {  }');
    }
  });

  test('Array#toString', () {
    {
      final arr = Array([]);
      expect(arr.toString(), '[]');
    }

    {
      final arr = Array([Int(10), Int(20)]);
      expect(arr.toString(), '[10, 20]');
    }
  });

  test('Boolean#toString', () {
    expect(Boolean(true).toString(), 'true');
    expect(Boolean(false).toString(), 'false');
  });

  test('Pair#toString', () {
    {
      final pair = Pair(Int(10), Int(20));
      expect(pair.toString(), '10: 20');
    }

    {
      final pair = Pair(StringLit('aaa'), Int(20));
      expect(pair.toString(), '"aaa": 20');
    }
  });

  test('Hash#toString', () {
    final pairs = [
      Pair(Int(10), Int(20)),
      Pair(StringLit('aaa'), StringLit('bbb')),
    ];
    expect(Hash(pairs).toString(), '{ 10: 20, "aaa": "bbb" }');
  });

  test('Int#toString', () {
    expect(Int(10).toString(), '10');
    expect(Int(345).toString(), '345');
  });

  test('StringLit#toString', () {
    expect(StringLit('aaa').toString(), '"aaa"');
    expect(StringLit('bbbb').toString(), '"bbbb"');
  });

  test('modify', () {
    Node _turnOneIntoTwo(Node node) {
      if (node is ExprStmt) {
        node.expr = _turnOneIntoTwo(node.expr) as Expr;
      } else if (node is Int) {
        if (node.value != 1) {
          return node;
        }

        node.value = 2;
      }

      return node;
    }

    final tests = [
      [Int(1), Int(2)],
      [
        Program([ExprStmt(Int(1))]),
        Program([ExprStmt(Int(2))]),
      ],
      [
        InfixExpr(Int(1), Operator.plus, Int(2)),
        InfixExpr(Int(2), Operator.plus, Int(2)),
      ],
      [
        InfixExpr(Int(2), Operator.plus, Int(1)),
        InfixExpr(Int(2), Operator.plus, Int(2)),
      ],
      [
        PrefixExpr(Operator.plus, Int(1)),
        PrefixExpr(Operator.plus, Int(2)),
      ],
      [Index(Int(1), Int(1)), Index(Int(2), Int(2))],
      [
        If(Int(1), Block([ExprStmt(Int(1))]), Block([ExprStmt(Int(1))])),
        If(Int(2), Block([ExprStmt(Int(2))]), Block([ExprStmt(Int(2))])),
      ],
      [Return(Int(1)), Return(Int(2))],
      [
        Let(Ident('x'), Int(1)),
        Let(Ident('x'), Int(2)),
      ],
      [
        MFunction([], Block([ExprStmt(Int(1))]), null),
        MFunction([], Block([ExprStmt(Int(2))]), null),
      ],
      [
        Array([Int(1)]),
        Array([Int(2)])
      ],
      [
        Hash([Pair(Int(1), Int(1))]),
        Hash([Pair(Int(2), Int(2))]),
      ]
    ];
    final expected =
        tests.map((test) => [test[0], modify(test[0], _turnOneIntoTwo)]);
    expect(
      tests.map((t) => [t[0].toString(), t[1].toString()]),
      expected.map((t) => [t[0].toString(), t[1].toString()]),
    );
  });
}
