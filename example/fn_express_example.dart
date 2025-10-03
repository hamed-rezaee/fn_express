import 'dart:io';

import 'package:fn_express/fn_express.dart';

void main() => Repl(
      onInput: () => stdin.readLineSync(),
      onOutput: (output, {newline = true}) =>
          newline ? stdout.writeln(output) : stdout.write(output),
    ).start();
