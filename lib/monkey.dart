import './monkey/ast.dart' as ast;
import './monkey/lexer.dart' as lexer;
import './monkey/parser.dart' as parser;

export './monkey/evaluator.dart' show defineMacros, extendMacros, eval;
export './monkey/evaluator/env.dart' show Environment;
export './monkey/evaluator/object.dart';

ast.Program buildAst(String input) {
  final l = lexer.Lexer(input);
  final p = parser.Parser(l);
  return p.parseProgram();
}
