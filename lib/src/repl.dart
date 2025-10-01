// Need to ignore these lint rules for this file as it's an interactive REPL
// ignore_for_file: avoid_print, avoid_catches_without_on_clauses

import 'dart:io';

import 'package:fn_express/fn_express.dart';

/// A Read-Eval-Print Loop (REPL) interface for interactive mathematical expression evaluation.
///
/// The REPL provides an interactive command-line interface where users can:
/// - Enter mathematical expressions and see results immediately
/// - Define and use variables across multiple expressions
/// - Access help documentation for functions and operators
/// - View command history and examples
///
/// Example usage:
/// ```dart
/// final repl = Repl();
/// repl.start();
/// ```
class Repl {
  /// Creates a new REPL instance with a fresh interpreter.
  Repl() : _interpreter = Interpreter();

  /// The interpreter instance used for expression evaluation.
  final Interpreter _interpreter;

  /// Starts the REPL interactive session.
  ///
  /// The session continues until the user enters 'exit' or presses Ctrl+C.
  /// Users can enter mathematical expressions, variable assignments, or
  /// special commands like 'help' for assistance.
  void start() {
    _printWelcome();

    while (true) {
      stdout.write('>> ');

      final input = stdin.readLineSync();

      if (input == null || input.toLowerCase() == 'exit') break;
      if (input.trim().isEmpty) continue;

      _processInput(input.trim());
    }

    _printGoodbye();
  }

  /// Processes user input and executes the appropriate action.
  ///
  /// Handles special commands (help, variables, constants, etc.) and
  /// mathematical expressions.
  void _processInput(String input) {
    try {
      switch (input.toLowerCase()) {
        case 'help':
        case '?':
          _printHelp();
          return;
        case 'help operators':
          _printOperatorHelp();
          return;
        case 'help functions':
          _printFunctionHelp();
          return;
        case 'help constants':
          _printConstantHelp();
          return;
        case 'help examples':
          _printExamples();
          return;
        case 'variables':
        case 'vars':
          _printVariables();
          return;
        case 'clear':
          _clearVariables();
          return;
        case 'version':
          _printVersion();
          return;
      }

      final result = _interpreter.eval(input);

      print('${result.value}');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Prints the welcome message and basic usage instructions.
  void _printWelcome() {
    print('╭─────────────────────────────────────╮');
    print('│          Fn Express REPL            │');
    print('│   Mathematical Expression Parser    │');
    print('╰─────────────────────────────────────╯');
    print('');
    print('Enter mathematical expressions or type "help" for assistance.');
    print('Type "exit" to quit.');
    print('');
  }

  /// Prints the goodbye message.
  void _printGoodbye() {
    print('');
    print('Thanks for using Fn Express REPL! Goodbye!');
  }

  /// Prints the main help information.
  void _printHelp() {
    print('');
    print('═══════════════════ HELP ═══════════════════');
    print('');
    print('COMMANDS:');
    print('  help              Show this help message');
    print('  help operators    Show available operators');
    print('  help functions    Show available functions');
    print('  help constants    Show available constants');
    print('  help examples     Show usage examples');
    print('  variables         Show defined variables');
    print('  clear             Clear all variables');
    print('  version           Show version info');
    print('  exit              Exit the REPL');
    print('');
    print('BASIC USAGE:');
    print('  • Enter expressions: 2 + 3 * 4');
    print('  • Assign variables: x = 10');
    print('  • Use functions: sin(pi/2)');
    print('  • Implicit multiplication: 2x, 3(x+1)');
    print('');
  }

  /// Prints information about available operators.
  void _printOperatorHelp() {
    print('');
    print('═══════════════ OPERATORS ═══════════════');
    print('');
    print('ARITHMETIC:');
    print('  +    Addition          5 + 3 = 8');
    print('  -    Subtraction       5 - 3 = 2');
    print('  *    Multiplication    5 * 3 = 15');
    print('  /    Division          5 / 2 = 2.5');
    print('  %    Modulo           17 % 5 = 2');
    print('  ^    Exponentiation    2^3 = 8');
    print('  u-   Unary minus      -5 = -5');
    print('');
    print('PRECEDENCE (highest to lowest):');
    print('  1. Unary minus (-x)');
    print('  2. Exponentiation (^) - right associative');
    print('  3. Multiplication, Division, Modulo (*, /, %)');
    print('  4. Addition, Subtraction (+, -)');
    print('');
  }

  /// Prints information about available functions.
  void _printFunctionHelp() {
    print('');
    print('═══════════════ FUNCTIONS ═══════════════');
    print('');
    print('BASIC:');
    print('  sqrt(x)           Square root');
    print('  abs(x)            Absolute value');
    print('  ln(x)             Natural logarithm');
    print('');
    print('TRIGONOMETRIC:');
    print('  sin(x), cos(x), tan(x)     Standard trig functions');
    print('  asin(x), acos(x), atan(x)  Inverse trig functions');
    print('');
    print('ROUNDING:');
    print('  floor(x)          Largest integer ≤ x');
    print('  ceil(x)           Smallest integer ≥ x');
    print('  round(x)          Nearest integer');
    print('  trunc(x)          Integer part (toward zero)');
    print('');
    print('SPECIAL:');
    print('  (x)           Factorial (non-negative integers)');
    print('');
    print('MULTI-ARGUMENT:');
    print('  complex(r, i)     Create complex number');
    print('  log(val, base)    Logarithm with custom base');
    print('  pow(base, exp)    Power function');
    print('  min(a, b)         Minimum of two values');
    print('  max(a, b)         Maximum of two values');
    print('  fraction(n, d)    Create fraction');
    print('');
  }

  /// Prints information about available constants.
  void _printConstantHelp() {
    print('');
    print('═══════════════ CONSTANTS ═══════════════');
    print('');
    print('MATHEMATICAL:');
    print('  pi               π (3.14159...)');
    print("  e                Euler's number (2.71828...)");
    print('  i                Imaginary unit (√-1)');
    print('');
    print('USAGE EXAMPLES:');
    print('  sin(pi/2)        Result: 1.0');
    print('  ln(e)            Result: 1.0');
    print('  i * i            Result: -1.0');
    print('  2 * pi * 5       Result: 31.415...');
    print('');
  }

  /// Prints usage examples.
  void _printExamples() {
    print('');
    print('═══════════════ EXAMPLES ═══════════════');
    print('');
    print('BASIC ARITHMETIC:');
    print('  >> 2 + 3 * 4');
    print('  14');
    print('  >> (10 + 5) / 3');
    print('  5.0');
    print('  >> 2^3^2');
    print('  512');
    print('');
    print('VARIABLES:');
    print('  >> x = 10');
    print('  10');
    print('  >> y = 2 * x + 5');
    print('  25');
    print('  >> x + y');
    print('  35');
    print('');
    print('TRIGONOMETRY:');
    print('  >> sin(pi/2)');
    print('  1.0');
    print('  >> angle = pi/4');
    print('  0.7853981633974483');
    print('  >> sin(angle)^2 + cos(angle)^2');
    print('  1.0');
    print('');
    print('COMPLEX NUMBERS:');
    print('  >> complex(3, 4)');
    print('  3.0 + 4.0i');
    print('  >> (2 + 3i) * (1 + i)');
    print('  -1.0 + 5.0i');
    print('  >> abs(3 + 4i)');
    print('  5.0');
    print('');
    print('ADVANCED:');
    print('  >> fact(5)');
    print('  120');
    print('  >> log(100, 10)');
    print('  2.0');
    print('  >> min(floor(3.7), ceil(2.1))');
    print('  3');
    print('');
  }

  /// Prints currently defined variables.
  void _printVariables() {
    print('');
    if (_interpreter.variables.isEmpty) {
      print('No variables defined.');
    } else {
      print('═══════════════ VARIABLES ═══════════════');
      print('');
      for (final entry in _interpreter.variables.entries) {
        print('  ${entry.key} = ${entry.value.value}');
      }
    }
    print('');
  }

  /// Clears all defined variables.
  void _clearVariables() {
    _interpreter.variables.clear();
    print('All variables cleared.');
  }

  /// Prints version information.
  void _printVersion() {
    print('');
    print('Fn Express REPL v1.0.0');
    print('Mathematical Expression Parser for Dart');
    print('');
  }
}
