// Need to ignore these lint rules for this file as it's an interactive REPL
// ignore_for_file: avoid_catches_without_on_clauses

import 'package:fn_express/fn_express.dart';

const String _replVersionLabel = 'Fn Express REPL v2.1.1';
const String _replDescription = 'Interactive Symbolic Math Toolkit';

/// A Read-Eval-Print Loop (REPL) interface for interactive mathematical expression evaluation.
///
/// The REPL provides an interactive command-line interface where users can:
/// - Enter mathematical expressions and see results immediately
/// - Define and use variables across multiple expressions
/// - Access help documentation for functions and operators
/// - View command history and examples
/// - Perform symbolic computations like simplification and differentiation
///
/// Example usage:
/// ```dart
/// var isRunning = true;
///
/// final repl = Repl(
///   (output, {newline = true}) =>
///       newline ? stdout.writeln(output) : stdout.write(output),
/// );
///
/// while (isRunning) {
///   stdout.write('>> ');
///   final input = stdin.readLineSync();
///
///   (input == null || input.toLowerCase() == 'exit')
///       ? isRunning = false
///       : repl(input);
/// }
/// ```
class Repl {
  /// Creates a new REPL instance with a fresh interpreter.
  Repl(this.onOutput) : _interpreter = Interpreter() {
    _symbolicInterpreter = SymbolicInterpreter(_interpreter);
    _equationSolver = EquationSolver(_interpreter);

    _printWelcome();
  }

  /// The interpreter instance used for expression evaluation.
  final Interpreter _interpreter;

  /// The symbolic interpreter instance used for symbolic computations.
  late final SymbolicInterpreter _symbolicInterpreter;

  /// The equation solver instance for numeric root finding.
  late final EquationSolver _equationSolver;

  /// Callback function to handle output display.
  final void Function(String value, {bool newline}) onOutput;

  /// Starts the REPL interactive session.
  ///
  /// The session continues until the user enters 'exit' or presses Ctrl+C.
  /// Users can enter mathematical expressions, variable assignments, or
  /// special commands like 'help' for assistance.
  void call(String? input) {
    if (input == null || input.toLowerCase() == 'exit') return;
    if (input.trim().isEmpty) return;

    _processInput(input.trim());
  }

  /// Processes user input and executes the appropriate action.
  ///
  /// Handles special commands (help, variables, constants, etc.) and
  /// mathematical expressions.
  void _processInput(String input) {
    try {
      final lowerInput = input.toLowerCase();

      if (lowerInput == 'help' || lowerInput == '?') {
        _printHelp();
        return;
      }

      if (lowerInput.startsWith('help ')) {
        final topic = input.substring(5).trim();
        if (_printHelpTopic(topic)) {
          return;
        }

        onOutput(
          'Unknown help topic "$topic". Type "help topics" to list available topics.',
        );

        return;
      }

      switch (lowerInput) {
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

      if (_handleSymbolicCommands(input)) {
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
    const innerWidth = 37;

    String spaces(int count) => ''.padRight(count);

    void printBoxLine(String text) {
      final trimmed = text.trim();
      final available = innerWidth - trimmed.length;
      final left = available ~/ 2;
      final right = available - left;
      onOutput('│${spaces(left)}$trimmed${spaces(right)}│');
    }

    onOutput('╭─────────────────────────────────────╮');
    printBoxLine(_replVersionLabel);
    printBoxLine(_replDescription);
    onOutput('╰─────────────────────────────────────╯');
    onOutput('');
    onOutput('Enter mathematical expressions or type "help" for assistance.');
    onOutput('Type "exit" to quit.');
    onOutput('');
  }

  /// Prints the main help information.
  void _printHelp() {
    onOutput('');
    onOutput('═══════════════════ HELP ═══════════════════');
    onOutput('');
    onOutput(
        'Evaluate expressions directly, or run commands for symbolic and numeric tools.');
    onOutput(
        'Use "help <topic>" for sections or "help <command>" for detailed usage.');
    onOutput('');
    onOutput('PRIMARY TOPICS');
    _printCommandTable(const [
      _HelpEntry('help topics', 'List every help topic'),
      _HelpEntry('help commands', 'Command reference grouped by category'),
      _HelpEntry('help numeric', 'Numeric solvers, interpolation, sequences'),
      _HelpEntry(
          'help symbolic', 'Simplification, derivatives, integrals, gradients'),
      _HelpEntry('help basics', 'Input syntax, assignments, and tips'),
      _HelpEntry('help operators', 'Operator list and precedence'),
      _HelpEntry('help functions', 'Built-in math functions'),
      _HelpEntry('help constants', 'Built-in constants such as pi and e'),
      _HelpEntry('help examples', 'Sample REPL interactions'),
    ]);
    onOutput('');
    onOutput('COMMAND SNAPSHOT');
    _printCommandSummary();
    onOutput('Get more detail with "help <command>" (e.g., help solve).');
    onOutput('');
    onOutput('INPUT BASICS');
    _printInputBasicsBody();
    onOutput('');
    onOutput('TIPS');
    _printTipsBody();
    onOutput('');
  }

  void _printCommandSummary() {
    const summaryCategories = <String>[
      'Session',
      'State',
      'Symbolic',
      'Calculus',
      'Numeric',
      'Analysis',
      'Sequences',
    ];

    var printedCategory = false;

    for (final category in summaryCategories) {
      final entries = _commandInfos
          .where((info) => info.category == category)
          .map((info) => _HelpEntry(_formatCommandName(info), info.summary))
          .toList();

      if (entries.isEmpty) {
        continue;
      }

      if (printedCategory) {
        onOutput('');
      }

      printedCategory = true;
      onOutput(category.toUpperCase());
      _printCommandTable(entries);
    }

    if (printedCategory) {
      onOutput('');
    }
  }

  void _printInputBasicsBody() {
    onOutput('  • Enter expressions: 2 + 3 * 4');
    onOutput('  • Assign variables: x = 10');
    onOutput('  • Use functions: sin(pi/2)');
    onOutput('  • Implicit multiplication: 2x, 3(x+1)');
  }

  void _printTipsBody() {
    onOutput(
        '  • Use "help <topic>" for operators, functions, constants, symbolic tools, and more.');
    onOutput(
        '  • Combine symbolic commands with variables (e.g., simplify 2x + x when x=3).');
    onOutput('  • Use parentheses to control precedence when in doubt.');
  }

  bool _printHelpTopic(String topic) {
    final normalized = topic.trim().toLowerCase();

    if (normalized.isEmpty) {
      _printHelp();
      return true;
    }

    switch (normalized) {
      case 'topics':
      case 'topic':
      case 'index':
        _printHelpTopics();
        return true;
      case 'commands':
      case 'command':
      case 'reference':
        _printCommandReference();
        return true;
      case 'numeric':
      case 'numerical':
        _printNumericHelp();
        return true;
      case 'symbolic':
      case 'symbolics':
      case 'calculus':
        _printSymbolicHelp();
        return true;
      case 'sequence':
      case 'sequences':
        _printSequenceHelp();
        return true;
      case 'basics':
      case 'basic':
      case 'input':
      case 'intro':
        _printBasicsHelp();
        return true;
      case 'operators':
      case 'operator':
        _printOperatorHelp();
        return true;
      case 'functions':
      case 'function':
        _printFunctionHelp();
        return true;
      case 'constants':
      case 'constant':
        _printConstantHelp();
        return true;
      case 'examples':
      case 'example':
        _printExamples();
        return true;
    }

    final info = _findCommandInfo(normalized);

    if (info != null) {
      _printCommandDetail(info);
      return true;
    }

    return false;
  }

  void _printHelpTopics() {
    onOutput('');
    onOutput('════════ HELP TOPICS ═════════════════════');
    onOutput('');
    _printCommandTable(const [
      _HelpEntry('help commands', 'Command reference grouped by category'),
      _HelpEntry('help numeric', 'Numeric solvers and interpolation tools'),
      _HelpEntry('help symbolic', 'Symbolic algebra and calculus commands'),
      _HelpEntry('help sequence', 'Options for sequence fitting'),
      _HelpEntry('help basics', 'Input syntax, assignments, and tips'),
      _HelpEntry('help operators', 'Operator catalog and precedence'),
      _HelpEntry('help functions', 'Built-in function library'),
      _HelpEntry('help constants', 'Named constants like pi, e, tau'),
      _HelpEntry('help examples', 'Sample REPL interactions'),
    ]);
    onOutput('');
    onOutput(
        'Tip: you can run help for aliases too (e.g., help vars, help nthderiv).');
    onOutput('');
  }

  void _printCommandReference() {
    onOutput('');
    onOutput('════════ COMMAND REFERENCE ═══════════════');
    onOutput('');
    _printCommandSummary();
    onOutput(
        'Tip: run "help <command>" (e.g., help integrate) for detailed usage.');
    onOutput('');
  }

  _CommandInfo? _findCommandInfo(String query) {
    final normalized = query.toLowerCase();

    for (final info in _commandInfos) {
      if (info.matches(normalized)) {
        return info;
      }
    }

    return null;
  }

  String _formatCommandName(_CommandInfo info) {
    if (info.aliases.isEmpty) {
      return info.display;
    }

    return '${info.display} | ${info.aliases.join(', ')}';
  }

  void _printCommandDetail(_CommandInfo info) {
    onOutput('');
    onOutput('════════ COMMAND DETAIL ═══════════════════');
    onOutput('');
    onOutput('Command: ${info.display}');

    if (info.aliases.isNotEmpty) {
      onOutput('Aliases: ${info.aliases.join(', ')}');
    }

    onOutput('Category: ${info.category}');
    onOutput('');
    onOutput(info.summary);

    if (info.usage.isNotEmpty) {
      onOutput('');
      onOutput('Usage:');
      for (final usage in info.usage) {
        onOutput('  $usage');
      }
    }

    if (info.examples.isNotEmpty) {
      onOutput('');
      onOutput('Examples:');
      for (final example in info.examples) {
        onOutput('  >> ${example.input}');
        for (final line in example.outputLines) {
          onOutput('  $line');
        }
      }
    }

    if (info.notes.isNotEmpty) {
      onOutput('');
      onOutput('Notes:');
      for (final note in info.notes) {
        onOutput('  • $note');
      }
    }

    onOutput('');
  }

  void _printNumericHelp() {
    onOutput('');
    onOutput('════════ NUMERIC TOOLS ═══════════════════');
    onOutput('');
    onOutput('EQUATION SOLVING:');
    onOutput('  solve <expression> <variable> [initial] | [lower upper]');
    onOutput(
        '    Finds roots with adaptive Newton, secant, or bisection methods.');
    onOutput(
        '    Provide an initial guess or a bracketing interval for best results.');
    onOutput('');
    onOutput('INTERPOLATION:');
    onOutput('  interpolate x1:y1,x2:y2,... value [extrapolate]');
    onOutput('    Performs piecewise-linear interpolation.');
    onOutput(
        '    Add the "extrapolate" flag to allow values outside the sample range.');
    onOutput('');
    onOutput('SEQUENCE FITTING:');
    onOutput(
        '  sequence value1,value2,... [var=<name>] [start=<index>] [simplify=true|false] [raw]');
    onOutput('    Discovers a polynomial that reproduces the numeric series.');
    onOutput('    See "help sequence" for detailed options and examples.');
    onOutput('');
  }

  void _printSequenceHelp() {
    final info = _findCommandInfo('sequence');

    if (info != null) {
      _printCommandDetail(info);
      return;
    }

    onOutput(
        'Usage: sequence value1,value2,... [var=<name>] [start=<index>] [simplify=true|false] [raw]');
    onOutput('');
  }

  void _printBasicsHelp() {
    onOutput('');
    onOutput('════════ BASICS ══════════════════════════');
    onOutput('');
    onOutput('EXPRESSION ENTRY:');
    _printInputBasicsBody();
    onOutput('');
    onOutput('VARIABLES:');
    onOutput(
        '  • Assign with = and reuse in later expressions (e.g., x = 3, 2*x).');
    onOutput('  • List stored values with "variables" (alias: vars).');
    onOutput('  • Reset the workspace with "clear".');
    onOutput('');
    onOutput('TIPS:');
    _printTipsBody();
    onOutput('');
  }

  void _printCommandTable(List<_HelpEntry> entries) {
    if (entries.isEmpty) {
      return;
    }

    var width = 0;

    for (final entry in entries) {
      if (entry.command.length > width) {
        width = entry.command.length;
      }
    }

    width += 2;

    for (final entry in entries) {
      final paddedCommand = entry.command.padRight(width);
      onOutput('  $paddedCommand${entry.description}');
    }
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
    onOutput('BASIC & EXPONENTIAL:');
    onOutput('  sqrt(x)           Square root (complex for negatives)');
    onOutput('  abs(x)            Absolute value or magnitude');
    onOutput('  ln(x)             Natural logarithm');
    onOutput('  exp(x)            Exponential (e^x)');
    onOutput('');
    onOutput('TRIGONOMETRY:');
    onOutput('  sin(x), cos(x), tan(x)      Standard trig functions');
    onOutput('  asin(x), acos(x), atan(x)   Inverse trig functions');
    onOutput('  sec(x), csc(x), cot(x)      Reciprocal trig functions');
    onOutput('');
    onOutput('HYPERBOLIC:');
    onOutput('  sinh(x), cosh(x), tanh(x)   Hyperbolic functions');
    onOutput('  asinh(x), acosh(x), atanh(x) Inverse hyperbolic functions');
    onOutput('  sech(x), csch(x), coth(x)   Reciprocal hyperbolic functions');
    onOutput('');
    onOutput('ROUNDING & SIGN:');
    onOutput('  floor(x)          Largest integer ≤ x');
    onOutput('  ceil(x)           Smallest integer ≥ x');
    onOutput('  round(x)          Nearest integer');
    onOutput('  trunc(x)          Integer part (toward zero)');
    onOutput('  sign(x)           Sign function (-1, 0, 1)');
    onOutput('');
    onOutput('FACTORIALS & SPECIAL:');
    onOutput('  fact(x)           Factorial');
    onOutput('  factorial2(x)     Double factorial');
    onOutput('  gamma(x)          Gamma function');
    onOutput('');
    onOutput('MATRIX & VECTOR:');
    onOutput('  vector(a, b, ...) Create a row vector');
    onOutput('  matrix(row1, row2, ...) Build a matrix from vectors');
    onOutput('  transpose(M)      Matrix transpose');
    onOutput('  det(M)            Matrix determinant');
    onOutput('  trace(M)          Sum of diagonal entries');
    onOutput('  eigenvalues(M)    Eigenvalues of a matrix');
    onOutput('');
    onOutput('MULTI-ARGUMENT & NUMBER THEORY:');
    onOutput('  complex(r, i)     Create complex number');
    onOutput('  fraction(n, d)    Create fraction (n / d)');
    onOutput('  log(val, base)    Logarithm with custom base');
    onOutput('  pow(base, exp)    Power function');
    onOutput('  clamp(val, min, max) Clamp value between bounds');
    onOutput('  min(a, b, ...)    Minimum of multiple values');
    onOutput('  max(a, b, ...)    Maximum of multiple values');
    onOutput('  gcd(a, b)         Greatest common divisor');
    onOutput('  lcm(a, b)         Least common multiple');
    onOutput('');
    onOutput('STATISTICS & RANDOMNESS:');
    onOutput('  average(a, b, ...) Arithmetic mean');
    onOutput('  median(a, b, ...) Median of values');
    onOutput('  mode(a, b, ...)   Mode of values');
    onOutput('  stdev(a, b, ...)  Sample standard deviation (min 2 args)');
    onOutput('  variance(a, b, ...) Sample variance (min 2 args)');
    onOutput('  random()          Random value in [0, 1)');
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
    onOutput('  >> gcd(24, 18)');
    onOutput('  6');
    onOutput('');
    onOutput('HYPERBOLIC & RECIPROCAL:');
    onOutput('  >> sinh(1)');
    onOutput('  1.1752011936438014');
    onOutput('  >> sech(0)');
    onOutput('  1.0');
    onOutput('');
    onOutput('MATRICES & VECTORS:');
    onOutput('  >> vector(1, 2, 3)');
    onOutput('  [[1, 2, 3]]');
    onOutput('  >> M = matrix(vector(1, 2), vector(3, 4))');
    onOutput('  [[1, 2], [3, 4]]');
    onOutput('  >> det(M)');
    onOutput('  -2');
    onOutput('');
    onOutput('SYMBOLIC COMPUTATION:');
    onOutput('  >> simplify x + x + 2*x');
    onOutput('  4*x');
    onOutput('  >> derivative x^2+2*x+1 x');
    onOutput('  2*x + 2');
    onOutput('  >> nthderiv x^4 x 2');
    onOutput('  12*x^2');
    onOutput('  >> integrate sin(x) x');
    onOutput('  -cos(x) + C');
    onOutput('  >> integrate sin(x) x 0 pi');
    onOutput('  Antiderivative: -cos(x)');
    onOutput('  Definite value: 2');
    onOutput('  >> solve x^2 - 2 x 0 2');
    onOutput('  Solution: x = 1.4142135623730951');
    onOutput('  Residual: ~1e-15');
    onOutput('  Method: Bisection');
    onOutput('  >> interpolate 0:0,10:20,20:40 15');
    onOutput('  Interpolated value: 30');
    onOutput('  >> sequence 2,5,8,11');
    onOutput('  Sequence expression: 3 * n + 2');
    onOutput('  >> gradient x^2+y^2 x,y');
    onOutput('  ∂/∂x: 2*x');
    onOutput('  ∂/∂y: 2*y');
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
    onOutput(_replVersionLabel);
    onOutput('$_replDescription for Dart');
    onOutput('');
  }

  num _evaluateNumeric(String expression) {
    final value = _interpreter.eval(expression).value;

    if (value is num) {
      return value;
    }

    throw ArgumentError(
      'Integral bounds must evaluate to a real number: $expression',
    );
  }

  /// Handles symbolic computation commands.
  bool _handleSymbolicCommands(String input) {
    if (input.startsWith('simplify ')) {
      final expression = input.substring(9);
      try {
        final result = _symbolicInterpreter.simplify(expression);
        onOutput(result);
        return true;
      } catch (e) {
        onOutput('Error simplifying expression: $e');
        return true;
      }
    }

    if (input.startsWith('derivative ')) {
      final parts = input.substring(11).split(' ');

      if (parts.length < 2) {
        onOutput('Usage: derivative <expression> <variable>');
        onOutput('Example: derivative x^2+2*x+1 x');

        return true;
      }

      final variable = parts.last;
      final expression = parts.sublist(0, parts.length - 1).join(' ');

      try {
        final result = _symbolicInterpreter.derivative(expression, variable);

        onOutput(result);

        return true;
      } catch (e) {
        onOutput('Error computing derivative: $e');

        return true;
      }
    }

    if (input.startsWith('nthderivative ') || input.startsWith('nthderiv ')) {
      final commandPrefix =
          input.startsWith('nthderivative ') ? 'nthderivative ' : 'nthderiv ';
      final parts = input.substring(commandPrefix.length).split(' ');

      if (parts.length < 3) {
        onOutput(
            'Usage: nthderivative|nthderiv <expression> <variable> <order>');
        onOutput('Example: nthderiv x^4 x 2');

        return true;
      }

      final variable = parts[parts.length - 2];
      final orderStr = parts.last;
      final expression = parts.sublist(0, parts.length - 2).join(' ');

      try {
        final order = int.parse(orderStr);
        final result =
            _symbolicInterpreter.nthDerivative(expression, variable, order);

        onOutput(result);

        return true;
      } catch (e) {
        onOutput('Error computing nth derivative: $e');
        return true;
      }
    }

    if (input.startsWith('integrate ')) {
      final content = input.substring(10).trim();

      if (content.isEmpty) {
        onOutput('Usage: integrate <expression> <variable> [lower upper]');
        onOutput('Examples:');
        onOutput('  integrate x^2 x');
        onOutput('  integrate sin(x) x 0 pi');

        return true;
      }

      final parts = content.split(RegExp(r'\s+'));
      if (parts.length < 2) {
        onOutput('Usage: integrate <expression> <variable> [lower upper]');
        onOutput('Examples:');
        onOutput('  integrate x^2 x');
        onOutput('  integrate sin(x) x 0 pi');

        return true;
      }

      final variablePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');

      if (parts.length >= 4 &&
          variablePattern.hasMatch(parts[parts.length - 3])) {
        final variable = parts[parts.length - 3];
        final lowerStr = parts[parts.length - 2];
        final upperStr = parts[parts.length - 1];
        final expressionTokens = parts.sublist(0, parts.length - 3);

        if (expressionTokens.isEmpty) {
          onOutput('Usage: integrate <expression> <variable> [lower upper]');
          onOutput('Examples:');
          onOutput('  integrate x^2 x');
          onOutput('  integrate sin(x) x 0 pi');
          return true;
        }

        final expression = expressionTokens.join(' ');

        try {
          final lower = _evaluateNumeric(lowerStr);
          final upper = _evaluateNumeric(upperStr);
          final result = _symbolicInterpreter.integral(
            expression,
            variable,
            lowerBound: lower,
            upperBound: upper,
          );

          onOutput('Antiderivative: ${result.expression}');
          if (result.hasDefiniteValue) {
            onOutput('Definite value: ${result.definiteValue}');
          }

          return true;
        } catch (e) {
          onOutput('Error computing integral: $e');
          return true;
        }
      }

      final variable = parts.last;
      if (!variablePattern.hasMatch(variable)) {
        onOutput('Usage: integrate <expression> <variable> [lower upper]');
        onOutput('Examples:');
        onOutput('  integrate x^2 x');
        onOutput('  integrate sin(x) x 0 pi');
        return true;
      }

      final expressionTokens = parts.sublist(0, parts.length - 1);
      if (expressionTokens.isEmpty) {
        onOutput('Usage: integrate <expression> <variable> [lower upper]');
        onOutput('Examples:');
        onOutput('  integrate x^2 x');
        onOutput('  integrate sin(x) x 0 pi');
        return true;
      }

      final expression = expressionTokens.join(' ');

      try {
        final result = _symbolicInterpreter.integral(expression, variable);
        onOutput('${result.expression} + C');
      } catch (e) {
        onOutput('Error computing integral: $e');
      }

      return true;
    }

    if (input.startsWith('solve ')) {
      final content = input.substring(6).trim();

      if (content.isEmpty) {
        _printSolveUsage();
        return true;
      }

      final tokens = content.split(RegExp(r'\s+'));
      if (tokens.length < 2) {
        _printSolveUsage();
        return true;
      }

      final numericTokens = <String>[];
      var index = tokens.length - 1;

      while (index >= 0 && _isNumericToken(tokens[index])) {
        numericTokens.insert(0, tokens[index]);
        index--;
      }

      if (index < 0) {
        _printSolveUsage();
        return true;
      }

      final variable = tokens[index];
      final variablePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');

      if (!variablePattern.hasMatch(variable)) {
        _printSolveUsage();
        return true;
      }

      final expressionTokens = tokens.sublist(0, index);

      if (expressionTokens.isEmpty) {
        _printSolveUsage();
        return true;
      }

      final equation = expressionTokens.join(' ');

      try {
        EquationSolution solution;

        if (numericTokens.isEmpty) {
          solution = _equationSolver.solve(equation, variable);
        } else if (numericTokens.length == 1) {
          final initial = double.parse(numericTokens.first);
          solution = _equationSolver.solve(
            equation,
            variable,
            initialGuess: initial,
          );
        } else if (numericTokens.length == 2) {
          final lower = double.parse(numericTokens[0]);
          final upper = double.parse(numericTokens[1]);
          solution = _equationSolver.solve(
            equation,
            variable,
            lowerBound: lower,
            upperBound: upper,
          );
        } else {
          _printSolveUsage();
          return true;
        }

        final rootValue = solution.root.value;
        final methodName = solution.method.isEmpty
            ? 'Unknown'
            : '${solution.method[0].toUpperCase()}${solution.method.substring(1)}';
        final residual = solution.residual;
        final residualStr = residual == 0
            ? '0'
            : residual.abs() >= 1e4 || residual.abs() <= 1e-4
                ? residual.toStringAsExponential(6)
                : residual.toString();

        onOutput('Solution: $variable = $rootValue');
        onOutput('Residual: $residualStr');
        onOutput('Iterations: ${solution.iterations}');
        onOutput('Method: $methodName');

        if (!solution.converged) {
          onOutput(
            'Warning: Solver reached the iteration limit without meeting the tolerance.',
          );
        }

        return true;
      } catch (e) {
        onOutput('Error solving equation: $e');
        return true;
      }
    }

    if (input.startsWith('interpolate ')) {
      final content = input.substring(12).trim();

      if (content.isEmpty) {
        _printInterpolateUsage();
        return true;
      }

      final parts = content.split(RegExp(r'\s+'));
      if (parts.length < 2) {
        _printInterpolateUsage();
        return true;
      }

      final dataPart = parts[0];
      final xPart = parts[1];
      final allowExtrapolation =
          parts.length >= 3 && parts[2].toLowerCase() == 'extrapolate';

      try {
        final points = _parsePointSeries(dataPart);
        final xValue = _evaluateNumeric(xPart);
        final result = allowExtrapolation
            ? _symbolicInterpreter.extrapolateLinear(points, xValue)
            : _symbolicInterpreter.interpolateLinear(points, xValue);

        onOutput('Interpolated value: ${result.value}');
        return true;
      } catch (e) {
        onOutput('Error interpolating: $e');
        return true;
      }
    }

    if (input.startsWith('gradient ')) {
      final parts = input.substring(9).split(' ');

      if (parts.length < 2) {
        onOutput('Usage: gradient <expression> <variable1,variable2,...>');
        onOutput('Example: gradient x^2+y^2+z^2 x,y,z');

        return true;
      }

      final variablesStr = parts.last;
      final expression = parts.sublist(0, parts.length - 1).join(' ');
      final variables = variablesStr.split(',').map((v) => v.trim()).toList();

      try {
        final result = _symbolicInterpreter.gradient(expression, variables);

        onOutput('Gradient:');

        for (final entry in result.entries) {
          onOutput('  ∂/∂${entry.key}: ${entry.value}');
        }

        return true;
      } catch (e) {
        onOutput('Error computing gradient: $e');

        return true;
      }
    }

    if (input.startsWith('analyze ')) {
      final expression = input.substring(8);

      try {
        final info = _symbolicInterpreter.analyzeExpression(expression);
        onOutput('Expression Analysis:');
        onOutput('  Expression: ${info.expression}');
        onOutput('  Variables: ${info.variables.join(', ')}');
        onOutput('  Functions: ${info.functions.join(', ')}');
        onOutput('  Node count: ${info.nodeCount}');
        onOutput('  Max depth: ${info.maxDepth}');
        onOutput('  Complexity: ${info.complexity}');

        return true;
      } catch (e) {
        onOutput('Error analyzing expression: $e');

        return true;
      }
    }

    if (input == 'sequence' || input.startsWith('sequence ')) {
      final args = input.length > 8 ? input.substring(9).trim() : '';
      _processSequenceCommand(args);
      return true;
    }

    return false;
  }

  void _processSequenceCommand(String args) {
    if (args.isEmpty || args.toLowerCase() == 'help') {
      _printSequenceHelp();
      return;
    }

    final rawParts =
        args.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();

    if (rawParts.isEmpty) {
      _printSequenceHelp();
      return;
    }

    final valueParts = <String>[];
    final optionParts = <String>[];

    var optionsStarted = false;
    for (final part in rawParts) {
      final lower = part.toLowerCase();
      final isOption = lower.startsWith('var=') ||
          lower.startsWith('variable=') ||
          lower.startsWith('start=') ||
          lower.startsWith('simplify=') ||
          lower == 'raw';

      if (!optionsStarted && !isOption) {
        valueParts.add(part);
      } else {
        optionsStarted = true;
        optionParts.add(part);
      }
    }

    if (valueParts.isEmpty) {
      onOutput('No sequence values provided.');
      _printSequenceHelp();
      return;
    }

    final valueString = valueParts.join(' ');
    final rawValues = valueString.split(',');
    final values = <num>[];

    try {
      for (final raw in rawValues) {
        final trimmed = raw.trim();
        if (trimmed.isEmpty) {
          continue;
        }
        values.add(_evaluateNumeric(trimmed));
      }
    } catch (e) {
      onOutput('Error parsing sequence values: $e');
      return;
    }

    if (values.isEmpty) {
      onOutput('Please provide at least one numeric value.');
      _printSequenceHelp();
      return;
    }

    var variable = 'n';
    num startIndex = 0;
    var simplify = true;

    for (final token in optionParts) {
      final lower = token.toLowerCase();

      if (lower == 'raw') {
        simplify = false;
        continue;
      }

      final eqIndex = token.indexOf('=');
      if (eqIndex == -1) {
        onOutput('Unknown option: $token');
        _printSequenceHelp();
        return;
      }

      final key = token.substring(0, eqIndex).toLowerCase();
      final value = token.substring(eqIndex + 1);

      switch (key) {
        case 'var':
        case 'variable':
          variable = value;
        case 'start':
          try {
            startIndex = _evaluateNumeric(value);
          } catch (e) {
            onOutput('Invalid start index: $e');
            return;
          }
        case 'simplify':
          final lowered = value.toLowerCase();
          if (lowered == 'true') {
            simplify = true;
          } else if (lowered == 'false') {
            simplify = false;
          } else {
            onOutput('simplify must be true or false.');
            return;
          }
        default:
          onOutput('Unknown option: $token');
          _printSequenceHelp();
          return;
      }
    }

    final variablePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');
    if (!variablePattern.hasMatch(variable)) {
      onOutput('Invalid variable name: $variable');
      onOutput(
        'Variable names must start with a letter and contain only letters, digits, and underscores.',
      );
      return;
    }

    try {
      final result = _symbolicInterpreter.sequenceFormula(
        values,
        variable: variable,
        startIndex: startIndex,
        simplify: simplify,
      );

      onOutput('Sequence expression: ${result.expression}');
    } catch (e) {
      onOutput('Error generating sequence formula: $e');
    }
  }

  /// Prints symbolic computation help information.
  void _printSymbolicHelp() {
    onOutput('');
    onOutput('═══════════ SYMBOLIC COMPUTATION ═══════════');
    onOutput('');
    onOutput('SIMPLIFICATION:');
    onOutput('  simplify <expression>');
    onOutput('    Simplifies algebraic expressions');
    onOutput('    Example: simplify x + x + 2*x  →  4*x');
    onOutput('    Example: simplify (x+1)^2  →  x^2 + 2*x + 1');
    onOutput('');
    onOutput('DIFFERENTIATION:');
    onOutput('  derivative <expression> <variable>');
    onOutput('    Computes the first derivative');
    onOutput('    Example: derivative x^2+2*x+1 x  →  2*x + 2');
    onOutput('');
    onOutput('  nthderivative|nthderiv <expression> <variable> <order>');
    onOutput('    Computes higher-order derivatives (alias: nthderiv)');
    onOutput('    Example: nthderiv x^4 x 2  →  12*x^2');
    onOutput('');
    onOutput('INTEGRATION:');
    onOutput('  integrate <expression> <variable> [lower upper]');
    onOutput('    Computes indefinite or definite integrals');
    onOutput('    Example: integrate sin(x) x  →  -cos(x) + C');
    onOutput('    Example: integrate sin(x) x 0 pi  →  2');
    onOutput('');
    onOutput('EQUATION SOLVING:');
    onOutput('  solve <expression> <variable> [initial] | [lower upper]');
    onOutput(
        '    Finds numeric roots with Newton, secant, or bisection methods');
    onOutput('    Example: solve x^2 - 2 x 0 2');
    onOutput('    Example: solve sin(x) = 0 x 3.0');
    onOutput('');
    onOutput('INTERPOLATION & EXTRAPOLATION:');
    onOutput('  interpolate x1:y1,x2:y2,... value [extrapolate]');
    onOutput(
        '    Performs piecewise-linear interpolation and optional extrapolation');
    onOutput('    Example: interpolate 0:0,10:20,20:40 15  →  30');
    onOutput('    Example: interpolate 0:0,10:20 25 extrapolate');
    onOutput('');
    onOutput('SEQUENCE SYNTHESIS:');
    onOutput(
        '  sequence value1,value2,... [var=<name>] [start=<index>] [simplify=false]');
    onOutput('    Discovers a polynomial that reproduces the provided series');
    onOutput('    Example: sequence 2,5,8,11  →  3 * n + 2');
    onOutput('');
    onOutput('MULTIVARIABLE CALCULUS:');
    onOutput('  gradient <expression> <var1,var2,...>');
    onOutput('    Computes the gradient vector');
    onOutput('    Example: gradient x^2+y^2 x,y');
    onOutput('    Output: ∂/∂x: 2*x, ∂/∂y: 2*y');
    onOutput('');
    onOutput('ANALYSIS:');
    onOutput('  analyze <expression>');
    onOutput('    Analyzes expression structure and properties');
    onOutput('    Shows variables, functions, complexity, etc.');
    onOutput('');
    onOutput('TIPS:');
    onOutput('  • All symbolic operations work with variables');
    onOutput('  • Use parentheses for complex expressions');
    onOutput('  • Results are automatically simplified');
    onOutput('  • Variable names are case-sensitive');
    onOutput('');
  }

  bool _isNumericToken(String token) => double.tryParse(token) != null;

  void _printSolveUsage() {
    onOutput('Usage: solve <expression> <variable> [initial] | [lower upper]');
    onOutput('Examples:');
    onOutput('  solve x^2 - 2 x 0 2');
    onOutput('  solve sin(x) = 0 x 3.0');
  }

  List<Tuple2<dynamic, dynamic>> _parsePointSeries(String input) {
    final entries = input.split(',');
    if (entries.length < 2) {
      throw ArgumentError('At least two data points are required.');
    }

    final points = <Tuple2<dynamic, dynamic>>[];
    for (final entry in entries) {
      final parts = entry.split(':');
      if (parts.length != 2) {
        throw ArgumentError('Data points must be in the form x:y');
      }

      final x = _evaluateNumeric(parts[0]);
      final y = _evaluateNumeric(parts[1]);
      points.add(Tuple2(x, y));
    }

    return points;
  }

  void _printInterpolateUsage() {
    onOutput('Usage: interpolate x1:y1,x2:y2,... value [extrapolate]');
    onOutput('Examples:');
    onOutput('  interpolate 0:0,10:20,20:40 15');
    onOutput('  interpolate 0:0,10:20 25 extrapolate');
  }
}

class _HelpEntry {
  const _HelpEntry(this.command, this.description);

  final String command;
  final String description;
}

class _CommandInfo {
  const _CommandInfo({
    required this.key,
    required this.display,
    required this.summary,
    required this.category,
    this.aliases = const [],
    this.usage = const [],
    this.examples = const [],
    this.notes = const [],
  });

  final String key;
  final String display;
  final String summary;
  final String category;
  final List<String> aliases;
  final List<String> usage;
  final List<_CommandExample> examples;
  final List<String> notes;

  bool matches(String query) {
    final lower = query.toLowerCase();

    if (key == lower) {
      return true;
    }

    for (final alias in aliases) {
      if (alias.toLowerCase() == lower) {
        return true;
      }
    }

    return false;
  }
}

class _CommandExample {
  const _CommandExample(this.input, [this.outputLines = const []]);

  final String input;
  final List<String> outputLines;
}

const List<_CommandInfo> _commandInfos = [
  _CommandInfo(
    key: 'help',
    display: 'help',
    summary: 'Show the help overview or a specific topic.',
    category: 'Session',
    aliases: ['?'],
    usage: [
      'help',
      'help topics',
      'help <topic>',
      'help <command>',
    ],
    examples: [
      _CommandExample('help numeric'),
      _CommandExample('help solve'),
    ],
    notes: [
      'Topics include: commands, numeric, symbolic, sequence, basics, operators, functions, constants, examples.',
    ],
  ),
  _CommandInfo(
    key: 'exit',
    display: 'exit',
    summary: 'Leave the REPL session.',
    category: 'Session',
    usage: ['exit'],
  ),
  _CommandInfo(
    key: 'version',
    display: 'version',
    summary: 'Display Fn Express version information.',
    category: 'Session',
    usage: ['version'],
  ),
  _CommandInfo(
    key: 'variables',
    display: 'variables',
    summary: 'List all variables you have defined.',
    category: 'State',
    aliases: ['vars'],
    usage: ['variables', 'vars'],
  ),
  _CommandInfo(
    key: 'clear',
    display: 'clear',
    summary: 'Remove all stored variables.',
    category: 'State',
    usage: ['clear'],
  ),
  _CommandInfo(
    key: 'simplify',
    display: 'simplify <expression>',
    summary: 'Algebraically simplify an expression.',
    category: 'Symbolic',
    usage: ['simplify <expression>'],
    examples: [
      _CommandExample('simplify x + x + 2*x', ['4*x']),
      _CommandExample('simplify (x+1)^2', ['x^2 + 2*x + 1']),
    ],
  ),
  _CommandInfo(
    key: 'derivative',
    display: 'derivative <expression> <variable>',
    summary: 'Differentiate an expression with respect to a variable.',
    category: 'Calculus',
    usage: ['derivative <expression> <variable>'],
    examples: [
      _CommandExample('derivative x^2+2*x+1 x', ['2*x + 2']),
    ],
    notes: [
      'The variable argument must be a valid identifier.',
    ],
  ),
  _CommandInfo(
    key: 'nthderivative',
    display: 'nthderivative <expression> <variable> <order>',
    summary: 'Compute a higher-order derivative.',
    category: 'Calculus',
    aliases: ['nthderiv'],
    usage: [
      'nthderivative <expression> <variable> <order>',
      'nthderiv <expression> <variable> <order>',
    ],
    examples: [
      _CommandExample('nthderiv x^4 x 2', ['12*x^2']),
    ],
  ),
  _CommandInfo(
    key: 'integrate',
    display: 'integrate <expression> <variable> [lower upper]',
    summary: 'Compute indefinite or definite integrals.',
    category: 'Calculus',
    usage: [
      'integrate <expression> <variable>',
      'integrate <expression> <variable> <lower> <upper>',
    ],
    examples: [
      _CommandExample('integrate sin(x) x', ['-cos(x) + C']),
      _CommandExample('integrate sin(x) x 0 pi', [
        'Antiderivative: -cos(x)',
        'Definite value: 2',
      ]),
    ],
    notes: [
      'Bounds must evaluate to numeric values when provided.',
    ],
  ),
  _CommandInfo(
    key: 'gradient',
    display: 'gradient <expression> <var1,var2,...>',
    summary: 'Compute partial derivatives for each variable.',
    category: 'Calculus',
    usage: ['gradient <expression> <var1,var2,...>'],
    examples: [
      _CommandExample('gradient x^2+y^2 x,y', [
        '∂/∂x: 2*x',
        '∂/∂y: 2*y',
      ]),
    ],
    notes: [
      'Supply comma-separated variables (e.g., x,y,z).',
    ],
  ),
  _CommandInfo(
    key: 'analyze',
    display: 'analyze <expression>',
    summary: 'Inspect variables, functions, and structural complexity.',
    category: 'Analysis',
    usage: ['analyze <expression>'],
    examples: [
      _CommandExample('analyze sin(x) + cos(y)', [
        'Expression Analysis:',
        '  Variables: x, y',
        '  Functions: sin, cos',
      ]),
    ],
    notes: [
      'Reports variables, function usage, node counts, and complexity estimates.',
    ],
  ),
  _CommandInfo(
    key: 'solve',
    display: 'solve <expression> <variable> [initial] | [lower upper]',
    summary: 'Find numeric roots of an equation.',
    category: 'Numeric',
    usage: [
      'solve <expression> <variable> [initial guess]',
      'solve <expression> <variable> [lower upper]',
    ],
    examples: [
      _CommandExample('solve x^2 - 2 x 0 2', [
        'Solution: x = 1.4142135623730951',
        'Method: Bisection',
      ]),
      _CommandExample('solve sin(x) = 0 x 3.0', [
        'Solution: x = 3.141592653589793',
      ]),
    ],
    notes: [
      'Provide either a single initial guess or a lower/upper bracketing interval.',
      'Outputs include the residual and iteration count for transparency.',
    ],
  ),
  _CommandInfo(
    key: 'interpolate',
    display: 'interpolate x1:y1,x2:y2,... value [extrapolate]',
    summary:
        'Perform piecewise-linear interpolation or optional extrapolation.',
    category: 'Numeric',
    usage: [
      'interpolate x1:y1,x2:y2,... value',
      'interpolate x1:y1,x2:y2,... value extrapolate',
    ],
    examples: [
      _CommandExample(
          'interpolate 0:0,10:20,20:40 15', ['Interpolated value: 30']),
      _CommandExample(
          'interpolate 0:0,10:20 25 extrapolate', ['Interpolated value: 50']),
    ],
    notes: [
      'Provide at least two data points in x:y form separated by commas.',
    ],
  ),
  _CommandInfo(
    key: 'sequence',
    display: 'sequence value1,value2,... [options]',
    summary: 'Fit a polynomial expression to a numeric sequence.',
    category: 'Sequences',
    usage: [
      'sequence value1,value2,...',
      'sequence value1,value2,... var=<name>',
      'sequence value1,value2,... start=<index>',
      'sequence value1,value2,... simplify=false',
      'sequence value1,value2,... raw',
    ],
    examples: [
      _CommandExample('sequence 2,5,8,11', ['Sequence expression: 3 * n + 2']),
      _CommandExample(
          'sequence 1,4,9,16 start=1', ['Sequence expression: (n + 1)^2']),
    ],
    notes: [
      'Use var=<name> to change the index variable (default: n).',
      'Use start=<index> to set the index of the first term (default: 0).',
      'simplify=false or the raw flag returns the unsimplified polynomial.',
    ],
  ),
];
