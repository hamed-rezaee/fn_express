import 'dart:math' as math;

import 'package:fn_express/src/ast_builder.dart';
import 'package:fn_express/src/ast_node.dart';
import 'package:fn_express/src/differentiation_engine.dart';
import 'package:fn_express/src/expression_normalizer.dart';
import 'package:fn_express/src/expression_simplifier.dart';
import 'package:fn_express/src/interpreter.dart';
import 'package:fn_express/src/lexer.dart';
import 'package:fn_express/src/number_value.dart';
import 'package:fn_express/src/parser.dart';
import 'package:fn_express/src/token.dart';

/// Result of solving an equation.
class EquationSolution {
  /// Creates a new equation solution instance.
  EquationSolution({
    required this.variable,
    required this.root,
    required this.iterations,
    required this.residual,
    required this.converged,
    required this.method,
  });

  /// Variable that was solved for.
  final String variable;

  /// The computed root value.
  final NumberValue root;

  /// Number of iterations performed by the solver.
  final int iterations;

  /// Absolute residual |f(root)|.
  final double residual;

  /// Whether the solver satisfied the requested tolerance.
  final bool converged;

  /// Name of the method that produced this solution.
  final String method;

  @override
  String toString() =>
      'EquationSolution(variable: $variable, root: ${root.value}, '
      'residual: $residual, iterations: $iterations, '
      'converged: $converged, method: $method)';
}

/// Provides numeric equation solving utilities for single-variable equations.
///
/// The solver supports Newton-Raphson, Secant, and Bisection methods. By
/// default, Newton-Raphson is attempted with an optional initial guess. If
/// bounds are supplied, a robust bisection strategy is used instead. When
/// Newton-Raphson fails to converge, the solver falls back to a secant step.
class EquationSolver {
  /// Creates a new solver instance.
  ///
  /// If an [Interpreter] is supplied, it will be used for parsing and
  /// evaluation, allowing the solver to honour existing variables, constants,
  /// and function definitions. Otherwise a fresh interpreter is created.
  EquationSolver([Interpreter? interpreter])
      : _interpreter = interpreter ?? Interpreter(),
        _simplifier = ExpressionSimplifier(),
        _differentiationEngine = DifferentiationEngine(),
        _astBuilder = AstBuilder();

  final Interpreter _interpreter;
  final ExpressionSimplifier _simplifier;
  final DifferentiationEngine _differentiationEngine;
  final AstBuilder _astBuilder;

  static final RegExp _variablePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');

  /// Solves an equation for [variable].
  ///
  /// [equation] can be written either in implicit form (`f(x)`) or with an
  /// equality (`lhs = rhs`). When no bounds are supplied, Newton-Raphson is
  /// attempted with an optional [initialGuess]. Providing both [lowerBound] and
  /// [upperBound] enables bisection which guarantees convergence on continuous
  /// functions with opposite signs at the interval endpoints.
  EquationSolution solve(
    String equation,
    String variable, {
    num? initialGuess,
    num? lowerBound,
    num? upperBound,
    double tolerance = 1e-9,
    int maxIterations = 50,
    bool simplify = true,
  }) {
    if (equation.trim().isEmpty) {
      throw ArgumentError('Equation cannot be empty.');
    }

    if (!_variablePattern.hasMatch(variable)) {
      throw ArgumentError('Invalid variable name: $variable');
    }

    if ((lowerBound != null) != (upperBound != null)) {
      throw ArgumentError('Both lower and upper bounds must be provided.');
    }

    if (lowerBound != null && upperBound != null && lowerBound == upperBound) {
      throw ArgumentError('Lower and upper bounds must differ.');
    }

    final safeTolerance = tolerance > 0 ? tolerance : 1e-12;
    final safeIterations = maxIterations > 0 ? maxIterations : 50;

    final functionAst = _buildEquationAst(equation, simplify: simplify);

    if (lowerBound != null && upperBound != null) {
      return _bisectionSolve(
        functionAst,
        variable,
        lowerBound.toDouble(),
        upperBound.toDouble(),
        safeTolerance,
        safeIterations,
      );
    }

    final derivativeAst = _differentiationEngine.differentiate(
      functionAst,
      variable,
      simplify: simplify,
    );

    final guess = (initialGuess ?? 0).toDouble();

    final newtonAttempt = _newtonSolve(
      functionAst,
      derivativeAst,
      variable,
      guess,
      safeTolerance,
      safeIterations,
    );

    if (newtonAttempt != null && newtonAttempt.converged) {
      return newtonAttempt;
    }

    final secantAttempt = _secantSolve(
      functionAst,
      variable,
      guess,
      guess == 0 ? 1.0 : guess * 1.1,
      safeTolerance,
      safeIterations,
    );

    if (secantAttempt != null && secantAttempt.converged) {
      return secantAttempt;
    }

    if (secantAttempt != null) {
      return secantAttempt;
    }

    if (newtonAttempt != null) {
      return newtonAttempt;
    }

    throw StateError(
      'Failed to converge to a solution within $safeIterations iterations.',
    );
  }

  EquationSolution _bisectionSolve(
    AstNode functionAst,
    String variable,
    double lower,
    double upper,
    double tolerance,
    int maxIterations,
  ) {
    var a = lower;
    var b = upper;
    var fa = _asReal(_evaluateAt(functionAst, variable, a), tolerance);
    var fb = _asReal(_evaluateAt(functionAst, variable, b), tolerance);

    if (fa.abs() <= tolerance) {
      return EquationSolution(
        variable: variable,
        root: _numberFromDouble(a, tolerance),
        iterations: 0,
        residual: fa.abs(),
        converged: true,
        method: 'bisection',
      );
    }

    if (fb.abs() <= tolerance) {
      return EquationSolution(
        variable: variable,
        root: _numberFromDouble(b, tolerance),
        iterations: 0,
        residual: fb.abs(),
        converged: true,
        method: 'bisection',
      );
    }

    if (fa * fb > 0) {
      throw ArgumentError(
        'Function must have opposite signs at the bounds. '
        'f($lower) = $fa, f($upper) = $fb',
      );
    }

    var iterations = 0;
    var mid = a;
    var fm = fa;

    while (iterations < maxIterations) {
      mid = (a + b) / 2;
      fm = _asReal(_evaluateAt(functionAst, variable, mid), tolerance);
      final intervalWidth = (b - a).abs() / 2;
      final residual = fm.abs();
      final converged = residual <= tolerance || intervalWidth <= tolerance;

      if (converged) {
        return EquationSolution(
          variable: variable,
          root: _numberFromDouble(mid, tolerance),
          iterations: iterations + 1,
          residual: residual,
          converged: true,
          method: 'bisection',
        );
      }

      if (fa * fm < 0) {
        b = mid;
        fb = fm;
      } else {
        a = mid;
        fa = fm;
      }

      iterations++;
    }

    final residual = fm.abs();
    return EquationSolution(
      variable: variable,
      root: _numberFromDouble(mid, tolerance),
      iterations: maxIterations,
      residual: residual,
      converged: residual <= tolerance,
      method: 'bisection',
    );
  }

  EquationSolution? _newtonSolve(
    AstNode functionAst,
    AstNode derivativeAst,
    String variable,
    double initialGuess,
    double tolerance,
    int maxIterations,
  ) {
    var x = initialGuess;
    var iterations = 0;

    while (iterations < maxIterations) {
      final fx = _asReal(_evaluateAt(functionAst, variable, x), tolerance);
      final residual = fx.abs();

      if (residual <= tolerance) {
        return EquationSolution(
          variable: variable,
          root: _numberFromDouble(x, tolerance),
          iterations: iterations,
          residual: residual,
          converged: true,
          method: 'newton',
        );
      }

      final derivative =
          _asReal(_evaluateAt(derivativeAst, variable, x), tolerance);
      if (derivative.abs() < tolerance) {
        return EquationSolution(
          variable: variable,
          root: _numberFromDouble(x, tolerance),
          iterations: iterations,
          residual: residual,
          converged: false,
          method: 'newton',
        );
      }

      final nextX = x - fx / derivative;
      if (!nextX.isFinite) {
        return EquationSolution(
          variable: variable,
          root: _numberFromDouble(x, tolerance),
          iterations: iterations,
          residual: residual,
          converged: false,
          method: 'newton',
        );
      }

      final delta = (nextX - x).abs();
      x = nextX;
      iterations++;

      final nextFx = _asReal(_evaluateAt(functionAst, variable, x), tolerance);
      final nextResidual = nextFx.abs();
      final converged =
          nextResidual <= tolerance || delta <= math.max(tolerance, 1e-12);

      if (converged) {
        return EquationSolution(
          variable: variable,
          root: _numberFromDouble(x, tolerance),
          iterations: iterations,
          residual: nextResidual,
          converged: nextResidual <= tolerance,
          method: 'newton',
        );
      }
    }

    final fx = _asReal(_evaluateAt(functionAst, variable, x), tolerance);
    return EquationSolution(
      variable: variable,
      root: _numberFromDouble(x, tolerance),
      iterations: maxIterations,
      residual: fx.abs(),
      converged: fx.abs() <= tolerance,
      method: 'newton',
    );
  }

  EquationSolution? _secantSolve(
    AstNode functionAst,
    String variable,
    double x0,
    double x1,
    double tolerance,
    int maxIterations,
  ) {
    var prevX = x0;
    var currX = x1;
    var fPrev = _asReal(_evaluateAt(functionAst, variable, prevX), tolerance);
    var fCurr = _asReal(_evaluateAt(functionAst, variable, currX), tolerance);

    if (fPrev.abs() <= tolerance) {
      return EquationSolution(
        variable: variable,
        root: _numberFromDouble(prevX, tolerance),
        iterations: 0,
        residual: fPrev.abs(),
        converged: true,
        method: 'secant',
      );
    }

    if (fCurr.abs() <= tolerance) {
      return EquationSolution(
        variable: variable,
        root: _numberFromDouble(currX, tolerance),
        iterations: 0,
        residual: fCurr.abs(),
        converged: true,
        method: 'secant',
      );
    }

    var iterations = 0;

    while (iterations < maxIterations) {
      final denominator = fCurr - fPrev;
      if (denominator.abs() < tolerance) {
        return EquationSolution(
          variable: variable,
          root: _numberFromDouble(currX, tolerance),
          iterations: iterations,
          residual: fCurr.abs(),
          converged: fCurr.abs() <= tolerance,
          method: 'secant',
        );
      }

      final nextX = currX - fCurr * (currX - prevX) / denominator;
      if (!nextX.isFinite) {
        return EquationSolution(
          variable: variable,
          root: _numberFromDouble(currX, tolerance),
          iterations: iterations,
          residual: fCurr.abs(),
          converged: false,
          method: 'secant',
        );
      }

      prevX = currX;
      fPrev = fCurr;
      currX = nextX;
      fCurr = _asReal(_evaluateAt(functionAst, variable, currX), tolerance);

      final converged = fCurr.abs() <= tolerance;
      iterations++;

      if (converged) {
        return EquationSolution(
          variable: variable,
          root: _numberFromDouble(currX, tolerance),
          iterations: iterations,
          residual: fCurr.abs(),
          converged: true,
          method: 'secant',
        );
      }
    }

    return EquationSolution(
      variable: variable,
      root: _numberFromDouble(currX, tolerance),
      iterations: maxIterations,
      residual: fCurr.abs(),
      converged: fCurr.abs() <= tolerance,
      method: 'secant',
    );
  }

  AstNode _buildEquationAst(String equation, {required bool simplify}) {
    final parts = equation.split('=');

    if (parts.length == 1) {
      final ast = _parseExpression(parts.first.trim());
      return simplify ? _simplifier.simplify(ast) : ast;
    }

    if (parts.length != 2) {
      throw ArgumentError('Only a single equality sign is supported.');
    }

    final left = _parseExpression(parts[0].trim());
    final right = _parseExpression(parts[1].trim());
    final difference = BinaryOperationNode('-', left, right);

    return simplify ? _simplifier.simplify(difference) : difference;
  }

  AstNode _parseExpression(String expression) {
    final normalised = ExpressionNormalizer.normalize(expression);
    final functions = _interpreter.functions.keys
        .toSet()
        .union(_interpreter.multiArgFunctions.keys.toSet());

    final lexer = Lexer(
      normalised,
      functions,
      _interpreter.constants.keys.toSet(),
    );

    final tokens = lexer.tokenize();
    final parser = Parser(tokens);
    final rpnQueue = parser.toPostfix();
    final functionArgCounts = _countFunctionArguments(tokens);

    return _astBuilder.buildFromRpnWithArgCounts(rpnQueue, functionArgCounts);
  }

  Map<String, int> _countFunctionArguments(List<Token> tokens) {
    final counts = <String, int>{};
    String? currentFunction;
    var currentArgCount = 0;
    var parenDepth = 0;

    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];

      if (token is FunctionToken) {
        currentFunction = token.value;
        currentArgCount = 1;
      } else if (token is LeftParenToken && currentFunction != null) {
        parenDepth++;
      } else if (token is RightParenToken && currentFunction != null) {
        parenDepth--;
        if (parenDepth == 0) {
          counts[currentFunction] = currentArgCount;
          currentFunction = null;
          currentArgCount = 0;
        }
      } else if (token is CommaToken &&
          currentFunction != null &&
          parenDepth == 1) {
        currentArgCount++;
      }
    }

    return counts;
  }

  NumberValue _evaluateAt(AstNode ast, String variable, double x) {
    final hadValue = _interpreter.variables.containsKey(variable);
    final previous = hadValue ? _interpreter.variables[variable]! : null;

    try {
      _interpreter.variables[variable] = DoubleValue(x);
      final context = <String, NumberValue>{}
        ..addAll(_interpreter.constants)
        ..addAll(_interpreter.variables);

      return ast.evaluate(context);
    } finally {
      if (hadValue) {
        _interpreter.variables[variable] = previous!;
      } else {
        _interpreter.variables.remove(variable);
      }
    }
  }

  double _asReal(NumberValue value, double tolerance) {
    if (value is IntegerValue) {
      return value.value.toDouble();
    }

    if (value is DoubleValue) {
      return value.value;
    }

    if (value is ComplexValue) {
      final imag = value.value.imaginary;
      if (imag.abs() <= math.max(tolerance, 1e-12)) {
        return value.value.real;
      }

      throw ArgumentError(
        'Complex values are not supported by the equation solver: ${value.value}',
      );
    }

    throw ArgumentError(
      'Unsupported number type returned by evaluation: ${value.runtimeType}',
    );
  }

  NumberValue _numberFromDouble(double value, double tolerance) {
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() <= math.max(tolerance, 1e-12) &&
        rounded % 1 == 0) {
      return IntegerValue(rounded.toInt());
    }

    return DoubleValue(value);
  }
}
