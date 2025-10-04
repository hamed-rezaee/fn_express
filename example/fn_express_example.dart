import 'dart:io';

import 'package:fn_express/fn_express.dart';

void main() {
  var isRunning = true;

  final repl = Repl(
    (output, {newline = true}) =>
        newline ? stdout.writeln(output) : stdout.write(output),
  );

  while (isRunning) {
    stdout.write('>> ');
    final input = stdin.readLineSync();

    (input == null || input.toLowerCase() == 'exit')
        ? isRunning = false
        : repl(input);
  }
}
