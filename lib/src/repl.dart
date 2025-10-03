// Need to ignore these lint rules for this file as it's an interactive REPL
// ignore_for_file: avoid_catches_without_on_clauses

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
  Repl({required this.onInput, required this.onOutput})
      : _interpreter = Interpreter();

  /// The interpreter instance used for expression evaluation.
  final Interpreter _interpreter;

  /// Callback function to handle user input.
  final String? Function() onInput;

  /// Callback function to handle output display.
  final void Function(String value, {bool newline}) onOutput;

  /// Starts the REPL interactive session.
  ///
  /// The session continues until the user enters 'exit' or presses Ctrl+C.
  /// Users can enter mathematical expressions, variable assignments, or
  /// special commands like 'help' for assistance.
  void start() {
    _printWelcome();

    while (true) {
      onOutput('>> ', newline: false);

      final input = onInput();

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

      onOutput('${result.value}');
    } catch (e) {
      onOutput('$e');
    }
  }

  /// Prints the welcome message and basic usage instructions.
  void _printWelcome() {
    onOutput('╭─────────────────────────────────────╮');
    onOutput('│          Fn Express REPL            │');
    onOutput('│   Mathematical Expression Parser    │');
    onOutput('╰─────────────────────────────────────╯');
    onOutput('');
    onOutput('Enter mathematical expressions or type "help" for assistance.');
    onOutput('Type "exit" to quit.');
    onOutput('');
  }

  /// Prints the goodbye message.
  void _printGoodbye() {
    onOutput('');
    onOutput('Thanks for using Fn Express REPL! Goodbye!');
  }

  /// Prints the main help information.
  void _printHelp() {
    onOutput('');
    onOutput('═══════════════════ HELP ═══════════════════');
    onOutput('');
    onOutput('COMMANDS:');
    onOutput('  help              Show this help message');
    onOutput('  help operators    Show available operators');
    onOutput('  help functions    Show available functions');
    onOutput('  help constants    Show available constants');
    onOutput('  help examples     Show usage examples');
    onOutput('  variables         Show defined variables');
    onOutput('  clear             Clear all variables');
    onOutput('  version           Show version info');
    onOutput('  exit              Exit the REPL');
    onOutput('');
    onOutput('BASIC USAGE:');
    onOutput('  • Enter expressions: 2 + 3 * 4');
    onOutput('  • Assign variables: x = 10');
    onOutput('  • Use functions: sin(pi/2)');
    onOutput('  • Implicit multiplication: 2x, 3(x+1)');
    onOutput('');
  }

  /// Prints information about available operators.
  void _printOperatorHelp() {
    onOutput('');
    onOutput('═══════════════ OPERATORS ═══════════════');
    onOutput('');
    onOutput('ARITHMETIC:');
    onOutput('  +    Addition          5 + 3 = 8');
    onOutput('  -    Subtraction       5 - 3 = 2');
    onOutput('  *    Multiplication    5 * 3 = 15');
    onOutput('  /    Division          5 / 2 = 2.5');
    onOutput('  %    Modulo           17 % 5 = 2');
    onOutput('  ^    Exponentiation    2^3 = 8');
    onOutput('  u-   Unary minus      -5 = -5');
    onOutput('');
    onOutput('PRECEDENCE (highest to lowest):');
    onOutput('  1. Unary minus (-x)');
    onOutput('  2. Exponentiation (^) - right associative');
    onOutput('  3. Multiplication, Division, Modulo (*, /, %)');
    onOutput('  4. Addition, Subtraction (+, -)');
    onOutput('');
  }

  /// Prints information about available functions.
  void _printFunctionHelp() {
    onOutput('');
    onOutput('═══════════════ FUNCTIONS ═══════════════');
    onOutput('');
    onOutput('BASIC:');
    onOutput('  sqrt(x)           Square root');
    onOutput('  abs(x)            Absolute value');
    onOutput('  ln(x)             Natural logarithm');
    onOutput('');
    onOutput('TRIGONOMETRIC:');
    onOutput('  sin(x), cos(x), tan(x)     Standard trig functions');
    onOutput('  asin(x), acos(x), atan(x)  Inverse trig functions');
    onOutput('');
    onOutput('ROUNDING:');
    onOutput('  floor(x)          Largest integer ≤ x');
    onOutput('  ceil(x)           Smallest integer ≥ x');
    onOutput('  round(x)          Nearest integer');
    onOutput('  trunc(x)          Integer part (toward zero)');
    onOutput('');
    onOutput('SPECIAL:');
    onOutput('  fact(x)           Factorial (non-negative integers)');
    onOutput('  sign(x)           Sign function (-1, 0, 1)');
    onOutput('');
    onOutput('MULTI-ARGUMENT:');
    onOutput('  complex(r, i)     Create complex number');
    onOutput('  log(val, base)    Logarithm with custom base');
    onOutput('  pow(base, exp)    Power function');
    onOutput('  min(a, b, ...)    Minimum of multiple values');
    onOutput('  max(a, b, ...)    Maximum of multiple values');
    onOutput('  fraction(n, d)    Create fraction');
    onOutput('  clamp(val, min, max) Clamp value between bounds');
    onOutput('');
    onOutput('STATISTICAL (VARIABLE ARGUMENTS):');
    onOutput('  average(a, b, ...) Average (arithmetic mean)');
    onOutput('  median(a, b, ...) Median of multiple values');
    onOutput('  mode(a, b, ...)   Mode of multiple values');
    onOutput('  stdev(a, b, ...)  Standard deviation (min 2 args)');
    onOutput('  variance(a, b, ...)  Variance (min 2 args)');
    onOutput('');
  }

  /// Prints information about available constants.
  void _printConstantHelp() {
    onOutput('');
    onOutput('═══════════════ CONSTANTS ═══════════════');
    onOutput('');
    onOutput('MATHEMATICAL:');
    onOutput('  pi               π (3.14159...)');
    onOutput("  e                Euler's number (2.71828...)");
    onOutput('  i                Imaginary unit (√-1)');
    onOutput('  phi              Golden ratio φ (1.61803...)');
    onOutput('  tau              τ = 2π (6.28318...)');
    onOutput('');
    onOutput('USAGE EXAMPLES:');
    onOutput('  sin(pi/2)        Result: 1.0');
    onOutput('  ln(e)            Result: 1.0');
    onOutput('  i * i            Result: -1.0');
    onOutput('  2 * pi * 5       Result: 31.415...');
    onOutput('  phi^2 - phi      Result: 1.0');
    onOutput('  tau / 2          Result: 3.14159...');
    onOutput('');
  }

  /// Prints usage examples.
  void _printExamples() {
    onOutput('');
    onOutput('═══════════════ EXAMPLES ═══════════════');
    onOutput('');
    onOutput('BASIC ARITHMETIC:');
    onOutput('  >> 2 + 3 * 4');
    onOutput('  14');
    onOutput('  >> (10 + 5) / 3');
    onOutput('  5.0');
    onOutput('  >> 2^3^2');
    onOutput('  512');
    onOutput('');
    onOutput('VARIABLES:');
    onOutput('  >> x = 10');
    onOutput('  10');
    onOutput('  >> y = 2 * x + 5');
    onOutput('  25');
    onOutput('  >> x + y');
    onOutput('  35');
    onOutput('');
    onOutput('TRIGONOMETRY:');
    onOutput('  >> sin(pi/2)');
    onOutput('  1.0');
    onOutput('  >> angle = pi/4');
    onOutput('  0.7853981633974483');
    onOutput('  >> sin(angle)^2 + cos(angle)^2');
    onOutput('  1.0');
    onOutput('');
    onOutput('COMPLEX NUMBERS:');
    onOutput('  >> complex(3, 4)');
    onOutput('  3.0 + 4.0i');
    onOutput('  >> (2 + 3i) * (1 + i)');
    onOutput('  -1.0 + 5.0i');
    onOutput('  >> abs(3 + 4i)');
    onOutput('  5.0');
    onOutput('');
    onOutput('ADVANCED:');
    onOutput('  >> fact(5)');
    onOutput('  120');
    onOutput('  >> log(100, 10)');
    onOutput('  2.0');
    onOutput('  >> min(floor(3.7), ceil(2.1))');
    onOutput('  3');
    onOutput('  >> sign(-5.7)');
    onOutput('  -1');
    onOutput('  >> clamp(15, 0, 10)');
    onOutput('  10');
    onOutput('');
  }

  /// Prints currently defined variables.
  void _printVariables() {
    onOutput('');

    if (_interpreter.variables.isEmpty) {
      onOutput('No variables defined.');
    } else {
      onOutput('═══════════════ VARIABLES ═══════════════');
      onOutput('');

      for (final entry in _interpreter.variables.entries) {
        onOutput('  ${entry.key} = ${entry.value.value}');
      }
    }

    onOutput('');
  }

  /// Clears all defined variables.
  void _clearVariables() {
    _interpreter.variables.clear();

    onOutput('All variables cleared.');
  }

  /// Prints version information.
  void _printVersion() {
    onOutput('');
    onOutput('Fn Express REPL v1.1.1');
    onOutput('Mathematical Expression Parser for Dart');
    onOutput('');
  }
}
