import 'dart:io';
import 'package:monkey/monkey.dart' as monkey;
import 'package:monkey/monkey/error.dart';

const prompt = '>> ';

Future<void> main(List<String> arguments) async {
  final env = monkey.Environment();
  final macroEnv = monkey.Environment();

  // ignore: literal_only_boolean_expressions
  while (true) {
    stdout.write(prompt);

    final input = stdin.readLineSync();
    if (input == null) {
      continue;
    }

    if (input == 'exit') {
      break;
    }

    try {
      final ast = monkey.buildAst(input);
      monkey.defineMacros(ast, env);
      final expanded = monkey.extendMacros(ast, macroEnv);

      final evaluated = monkey.eval(expanded, env);
      if (evaluated is monkey.Null) {
        continue;
      }
      print('$evaluated');
    } on MonkeyException catch (e) {
      print(e.msg);
      continue;
    }
  }
}
