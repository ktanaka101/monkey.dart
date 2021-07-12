import 'package:test/test.dart';

import 'package:monkey/monkey/lexer.dart';
import 'package:monkey/monkey/token.dart';

void main() {
  test('lookup_ident', () {
    expect(lookupIdent('fn'), isA<MFunction>());
    expect(lookupIdent('let'), isA<Let>());
    expect(lookupIdent('true'), isA<True>());
    expect(lookupIdent('false'), isA<False>());
    expect(lookupIdent('if'), isA<If>());
    expect(lookupIdent('else'), isA<Else>());
    expect(lookupIdent('return'), isA<Return>());
    expect(lookupIdent('macro'), isA<Macro>());
    expect(lookupIdent('custom'), equals(Ident('custom')));
    expect(lookupIdent('custom'), isNot(equals(Ident('true'))));
    expect(lookupIdent('tru'), equals(Ident('tru')));
  });

  test('Token#==', () {
    expect(Illegal('aaa') == Illegal('aaa'), true);
    expect(Illegal('aaa') == Illegal('bbb'), false);
    expect(Illegal('aaa') == Ident('aaa'), false);
  });

  test('Token#hashCode', () {
    expect(Illegal('aaa').hashCode, Illegal('aaa').hashCode);
    expect(Illegal('aaa').hashCode, isNot(Illegal('bbb').hashCode));
    expect(Illegal('aaa').hashCode, Ident('aaa').hashCode);
  });

  test('Lexer#next_token', () {
    const input = '''
      let five = 5;
      let ten = 10;
      
      let add = fn(x, y) {
        x + y;
      };

      let result = add(five, ten);
      !-/*5;
      5 < 10 > 5;

      if(5 < 10) {
        return true;
      } else {
        return false;
      }

      10 == 10;
      10 != 9;
      "foobar"
      "foo bar"
      [1, 2];
      { "foo": "bar" }
      macro(x, y) { x + y; };
    ''';

    final lexer = Lexer(input);
    [
      Let(),
      Ident('five'),
      Assign(),
      Int('5'),
      Semicolon(),
      //
      Let(),
      Ident('ten'),
      Assign(),
      Int('10'),
      Semicolon(),
      //
      Let(),
      Ident('add'),
      Assign(),
      MFunction(),
      Lparen(),
      Ident('x'),
      Comma(),
      Ident('y'),
      Rparen(),
      Lbrace(),
      Ident('x'),
      Plus(),
      Ident('y'),
      Semicolon(),
      Rbrace(),
      Semicolon(),
      //
      Let(),
      Ident('result'),
      Assign(),
      Ident('add'),
      Lparen(),
      Ident('five'),
      Comma(),
      Ident('ten'),
      Rparen(),
      Semicolon(),
      Bang(),
      Minus(),
      Slash(),
      Asterisk(),
      Int('5'),
      Semicolon(),
      //
      Int('5'),
      Lt(),
      Int('10'),
      Gt(),
      Int('5'),
      Semicolon(),
      //
      If(),
      Lparen(),
      Int('5'),
      Lt(),
      Int('10'),
      Rparen(),
      Lbrace(),
      Return(),
      True(),
      Semicolon(),
      Rbrace(),
      //
      Else(),
      Lbrace(),
      Return(),
      False(),
      Semicolon(),
      Rbrace(),
      //
      Int('10'),
      Equal(),
      Int('10'),
      Semicolon(),
      //
      Int('10'),
      NotEqual(),
      Int('9'),
      Semicolon(),
      //
      StringLiteral('foobar'),
      StringLiteral('foo bar'),
      //
      Lbracket(),
      Int('1'),
      Comma(),
      Int('2'),
      Rbracket(),
      Semicolon(),
      //
      Lbrace(),
      StringLiteral('foo'),
      Colon(),
      StringLiteral('bar'),
      Rbrace(),
      //
      Macro(),
      Lparen(),
      Ident('x'),
      Comma(),
      Ident('y'),
      Rparen(),
      Lbrace(),
      Ident('x'),
      Plus(),
      Ident('y'),
      Semicolon(),
      Rbrace(),
      Semicolon()
    ].forEach((expected) {
      expect(lexer.nextToken(), equals(expected));
    });
  });
}
