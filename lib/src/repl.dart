// Need to ignore these lint rules for this file as it's an interactive REPL
// ignore_for_file: avoid_catches_without_on_clauses

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

      stdout.writeln('${result.value}');
    } catch (e) {
      stderr.writeln('Error: $e');
    }
  }

  /// Prints the welcome message and basic usage instructions.
  void _printWelcome() {
    stdout
      ..writeln('╭─────────────────────────────────────╮')
      ..writeln('│          Fn Express REPL            │')
      ..writeln('│   Mathematical Expression Parser    │')
      ..writeln('╰─────────────────────────────────────╯')
      ..writeln()
      ..writeln('Enter mathematical expressions or type "help" for assistance.')
      ..writeln('Type "exit" to quit.')
      ..writeln();
  }

  /// Prints the goodbye message.
  void _printGoodbye() {
    stdout
      ..writeln()
      ..writeln('Thanks for using Fn Express REPL! Goodbye!');
  }

  /// Prints the main help information.
  void _printHelp() {
    stdout
      ..writeln()
      ..writeln('═══════════════════ HELP ═══════════════════')
      ..writeln()
      ..writeln('COMMANDS:')
      ..writeln('  help              Show this help message')
      ..writeln('  help operators    Show available operators')
      ..writeln('  help functions    Show available functions')
      ..writeln('  help constants    Show available constants')
      ..writeln('  help examples     Show usage examples')
      ..writeln('  variables         Show defined variables')
      ..writeln('  clear             Clear all variables')
      ..writeln('  version           Show version info')
      ..writeln('  exit              Exit the REPL')
      ..writeln()
      ..writeln('BASIC USAGE:')
      ..writeln('  • Enter expressions: 2 + 3 * 4')
      ..writeln('  • Assign variables: x = 10')
      ..writeln('  • Use functions: sin(pi/2)')
      ..writeln('  • Implicit multiplication: 2x, 3(x+1)')
      ..writeln();
  }

  /// Prints information about available operators.
  void _printOperatorHelp() {
    stdout
      ..writeln()
      ..writeln('═══════════════ OPERATORS ═══════════════')
      ..writeln()
      ..writeln('ARITHMETIC:')
      ..writeln('  +    Addition          5 + 3 = 8')
      ..writeln('  -    Subtraction       5 - 3 = 2')
      ..writeln('  *    Multiplication    5 * 3 = 15')
      ..writeln('  /    Division          5 / 2 = 2.5')
      ..writeln('  %    Modulo           17 % 5 = 2')
      ..writeln('  ^    Exponentiation    2^3 = 8')
      ..writeln('  u-   Unary minus      -5 = -5')
      ..writeln()
      ..writeln('PRECEDENCE (highest to lowest):')
      ..writeln('  1. Unary minus (-x)')
      ..writeln('  2. Exponentiation (^) - right associative')
      ..writeln('  3. Multiplication, Division, Modulo (*, /, %)')
      ..writeln('  4. Addition, Subtraction (+, -)')
      ..writeln();
  }

  /// Prints information about available functions.
  void _printFunctionHelp() {
    stdout
      ..writeln()
      ..writeln('═══════════════ FUNCTIONS ═══════════════')
      ..writeln()
      ..writeln('BASIC:')
      ..writeln('  sqrt(x)           Square root')
      ..writeln('  abs(x)            Absolute value')
      ..writeln('  ln(x)             Natural logarithm')
      ..writeln()
      ..writeln('TRIGONOMETRIC:')
      ..writeln('  sin(x), cos(x), tan(x)     Standard trig functions')
      ..writeln('  asin(x), acos(x), atan(x)  Inverse trig functions')
      ..writeln()
      ..writeln('ROUNDING:')
      ..writeln('  floor(x)          Largest integer ≤ x')
      ..writeln('  ceil(x)           Smallest integer ≥ x')
      ..writeln('  round(x)          Nearest integer')
      ..writeln('  trunc(x)          Integer part (toward zero)')
      ..writeln()
      ..writeln('SPECIAL:')
      ..writeln('  fact(x)           Factorial (non-negative integers)')
      ..writeln('  sign(x)           Sign function (-1, 0, 1)')
      ..writeln()
      ..writeln('MULTI-ARGUMENT:')
      ..writeln('  complex(r, i)     Create complex number')
      ..writeln('  log(val, base)    Logarithm with custom base')
      ..writeln('  pow(base, exp)    Power function')
      ..writeln('  min(a, b, ...)    Minimum of multiple values')
      ..writeln('  max(a, b, ...)    Maximum of multiple values')
      ..writeln('  fraction(n, d)    Create fraction')
      ..writeln('  clamp(val, min, max) Clamp value between bounds')
      ..writeln()
      ..writeln('STATISTICAL (VARIABLE ARGUMENTS):')
      ..writeln('  average(a, b, ...) Average (arithmetic mean)')
      ..writeln('  median(a, b, ...) Median of multiple values')
      ..writeln('  mode(a, b, ...)   Mode of multiple values')
      ..writeln('  stdev(a, b, ...)  Standard deviation (min 2 args)')
      ..writeln('  variance(a, b, ...)  Variance (min 2 args)')
      ..writeln();
  }

  /// Prints information about available constants.
  void _printConstantHelp() {
    stdout
      ..writeln()
      ..writeln('═══════════════ CONSTANTS ═══════════════')
      ..writeln()
      ..writeln('MATHEMATICAL:')
      ..writeln('  pi               π (3.14159...)')
      ..writeln("  e                Euler's number (2.71828...)")
      ..writeln('  i                Imaginary unit (√-1)')
      ..writeln('  phi              Golden ratio φ (1.61803...)')
      ..writeln('  tau              τ = 2π (6.28318...)')
      ..writeln()
      ..writeln('USAGE EXAMPLES:')
      ..writeln('  sin(pi/2)        Result: 1.0')
      ..writeln('  ln(e)            Result: 1.0')
      ..writeln('  i * i            Result: -1.0')
      ..writeln('  2 * pi * 5       Result: 31.415...')
      ..writeln('  phi^2 - phi      Result: 1.0')
      ..writeln('  tau / 2          Result: 3.14159...')
      ..writeln();
  }

  /// Prints usage examples.
  void _printExamples() {
    stdout
      ..writeln()
      ..writeln('═══════════════ EXAMPLES ═══════════════')
      ..writeln()
      ..writeln('BASIC ARITHMETIC:')
      ..writeln('  >> 2 + 3 * 4')
      ..writeln('  14')
      ..writeln('  >> (10 + 5) / 3')
      ..writeln('  5.0')
      ..writeln('  >> 2^3^2')
      ..writeln('  512')
      ..writeln()
      ..writeln('VARIABLES:')
      ..writeln('  >> x = 10')
      ..writeln('  10')
      ..writeln('  >> y = 2 * x + 5')
      ..writeln('  25')
      ..writeln('  >> x + y')
      ..writeln('  35')
      ..writeln()
      ..writeln('TRIGONOMETRY:')
      ..writeln('  >> sin(pi/2)')
      ..writeln('  1.0')
      ..writeln('  >> angle = pi/4')
      ..writeln('  0.7853981633974483')
      ..writeln('  >> sin(angle)^2 + cos(angle)^2')
      ..writeln('  1.0')
      ..writeln()
      ..writeln('COMPLEX NUMBERS:')
      ..writeln('  >> complex(3, 4)')
      ..writeln('  3.0 + 4.0i')
      ..writeln('  >> (2 + 3i) * (1 + i)')
      ..writeln('  -1.0 + 5.0i')
      ..writeln('  >> abs(3 + 4i)')
      ..writeln('  5.0')
      ..writeln()
      ..writeln('ADVANCED:')
      ..writeln('  >> fact(5)')
      ..writeln('  120')
      ..writeln('  >> log(100, 10)')
      ..writeln('  2.0')
      ..writeln('  >> min(floor(3.7), ceil(2.1))')
      ..writeln('  3')
      ..writeln('  >> sign(-5.7)')
      ..writeln('  -1')
      ..writeln('  >> clamp(15, 0, 10)')
      ..writeln('  10')
      ..writeln();
  }

  /// Prints currently defined variables.
  void _printVariables() {
    stdout.writeln();
    if (_interpreter.variables.isEmpty) {
      stdout.writeln('No variables defined.');
    } else {
      stdout
        ..writeln('═══════════════ VARIABLES ═══════════════')
        ..writeln();

      for (final entry in _interpreter.variables.entries) {
        stdout.writeln('  ${entry.key} = ${entry.value.value}');
      }
    }

    stdout.writeln();
  }

  /// Clears all defined variables.
  void _clearVariables() {
    _interpreter.variables.clear();

    stdout.writeln('All variables cleared.');
  }

  /// Prints version information.
  void _printVersion() {
    stdout
      ..writeln()
      ..writeln('Fn Express REPL v1.1.0')
      ..writeln('Mathematical Expression Parser for Dart')
      ..writeln();
  }
}
