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
        case 'help symbolic':
          _printSymbolicHelp();
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
    onOutput('╭─────────────────────────────────────╮');
    onOutput('│          Fn Express REPL            │');
    onOutput('│   Mathematical Expression Parser    │');
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
    onOutput('COMMANDS:');
    onOutput('  help              Show this help message');
    onOutput('  help operators    Show available operators');
    onOutput('  help functions    Show available functions');
    onOutput('  help constants    Show available constants');
    onOutput('  help symbolic     Show symbolic computation commands');
    onOutput('  help examples     Show usage examples');
    onOutput('  variables         Show defined variables');
    onOutput('  clear             Clear all variables');
    onOutput('  version           Show version info');
    onOutput('  solve             Solve equations numerically');
    onOutput('  interpolate       Interpolate or extrapolate data points');
    onOutput('  sequence          Generate a polynomial for a numeric series');
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
    onOutput('Fn Express REPL v2.0.0');
    onOutput('Mathematical Expression Parser for Dart');
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
      _printSequenceUsage();
      return;
    }

    final rawParts =
        args.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();

    if (rawParts.isEmpty) {
      _printSequenceUsage();
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
      _printSequenceUsage();
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
      _printSequenceUsage();
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
        _printSequenceUsage();
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
          _printSequenceUsage();
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

  void _printSequenceUsage() {
    onOutput(
        'Usage: sequence value1,value2,... [var=<name>] [start=<index>] [simplify=true|false] [raw]');
    onOutput('Examples:');
    onOutput('  sequence 2,5,8,11');
    onOutput('  sequence 1,4,9,16 start=1');
    onOutput('  sequence 3,6,9 var=k start=1');
    onOutput('Options:');
    onOutput('  var=<name>        Set the index variable (default: n)');
    onOutput(
        '  start=<index>     Set the starting index for the first term (default: 0)');
    onOutput(
        '  simplify=false    Skip algebraic simplification of the resulting expression');
    onOutput('  raw               Alias for simplify=false');
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
