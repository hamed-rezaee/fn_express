// ignore_for_file: lines_longer_than_80_chars

import 'package:fn_express/src/ast_builder.dart';
import 'package:fn_express/src/ast_node.dart';
import 'package:fn_express/src/differentiation_engine.dart';
import 'package:fn_express/src/equation_solver.dart';
import 'package:fn_express/src/expression_normalizer.dart';
import 'package:fn_express/src/expression_simplifier.dart';
import 'package:fn_express/src/integration_engine.dart';
import 'package:fn_express/src/interpolation_engine.dart';
import 'package:fn_express/src/interpreter.dart';
import 'package:fn_express/src/lexer.dart';
import 'package:fn_express/src/number_value.dart';
import 'package:fn_express/src/parser.dart';
import 'package:fn_express/src/sequence_analyzer.dart';
import 'package:fn_express/src/token.dart';
import 'package:fn_express/src/tuple.dart';

/// Enhanced interpreter that adds symbolic manipulation capabilities.
///
/// This class extends the basic interpreter functionality with advanced features like expression simplification and symbolic differentiation.
/// It maintains backward compatibility while providing new symbolic operations.
class SymbolicInterpreter {
  /// Creates a new symbolic interpreter.
  SymbolicInterpreter([Interpreter? baseInterpreter])
      : _interpreter = baseInterpreter ?? Interpreter(),
        _simplifier = ExpressionSimplifier(),
        _differentiationEngine = DifferentiationEngine(),
        _integrationEngine = IntegrationEngine(),
        _astBuilder = AstBuilder() {
    _equationSolver = EquationSolver(_interpreter);
    _interpolationEngine = InterpolationEngine();
    _sequenceAnalyzer = SequenceAnalyzer(simplifier: _simplifier);
  }

  final Interpreter _interpreter;
  final ExpressionSimplifier _simplifier;
  final DifferentiationEngine _differentiationEngine;
  final IntegrationEngine _integrationEngine;
  final AstBuilder _astBuilder;
  late final EquationSolver _equationSolver;
  late final InterpolationEngine _interpolationEngine;
  late final SequenceAnalyzer _sequenceAnalyzer;

  /// Gets the underlying interpreter for direct access to variables and functions.
  Interpreter get interpreter => _interpreter;

  /// Gets the equation solver used for numeric root finding.
  EquationSolver get equationSolver => _equationSolver;

  /// Gets the interpolation engine for numeric interpolation and extrapolation.
  InterpolationEngine get interpolationEngine => _interpolationEngine;

  /// Gets the sequence analyzer for sequence synthesis utilities.
  SequenceAnalyzer get sequenceAnalyzer => _sequenceAnalyzer;

  /// Evaluates an expression and returns the numeric result.
  ///
  /// This method maintains compatibility with the original interpreter
  /// while providing the foundation for symbolic operations.
  NumberValue eval(String expression) {
    return _interpreter.eval(expression);
  }

  /// Parses an expression into an Abstract Syntax Tree.
  ///
  /// This method converts a string expression into an AST that can be
  /// used for symbolic operations like simplification and differentiation.
  ///
  /// Returns an [AstNode] representing the parsed expression.
  ///
  /// Example:
  /// ```dart
  /// final ast = interpreter.parse('x^2 + 2*x + 1');
  /// ```
  AstNode parse(String expression) {
    final normalised = ExpressionNormalizer.normalize(expression);
    final lexer = Lexer(
        normalised,
        _interpreter.functions.keys
            .toSet()
            .union(_interpreter.multiArgFunctions.keys.toSet()),
        _interpreter.constants.keys.toSet());
    final tokens = lexer.tokenize();
    final parser = Parser(tokens);
    final rpnQueue = parser.toPostfix();
    final functionArgCounts = _countFunctionArguments(tokens);

    return _astBuilder.buildFromRpnWithArgCounts(rpnQueue, functionArgCounts);
  }

  /// Simplifies a mathematical expression algebraically.
  ///
  /// This method takes a string expression, parses it into an AST,
  /// applies algebraic simplification rules, and returns the simplified
  /// expression as a string.
  ///
  /// Parameters:
  /// - [expression]: The expression to simplify
  ///
  /// Returns a string representing the simplified expression.
  ///
  /// Example:
  /// ```dart
  /// final result = interpreter.simplify('x + x + 2*x'); // Returns '4*x'
  /// ```
  String simplify(String expression) {
    final ast = parse(expression);
    final simplified = _simplifier.simplify(ast);

    return simplified.toExpression();
  }

  /// Simplifies an AST node and returns the simplified AST.
  ///
  /// This method provides direct AST-to-AST simplification for cases
  /// where you already have an AST and want to avoid string conversion.
  AstNode simplifyAst(AstNode ast) {
    return _simplifier.simplify(ast);
  }

  /// Computes the derivative of an expression with respect to a variable.
  ///
  /// This method performs symbolic differentiation, applying standard
  /// calculus rules like the product rule, quotient rule, and chain rule.
  ///
  /// Parameters:
  /// - [expression]: The expression to differentiate
  /// - [variable]: The variable to differentiate with respect to
  /// - [simplify]: Whether to simplify the result (default: true)
  ///
  /// Returns a string representing the derivative.
  ///
  /// Example:
  /// ```dart
  /// final result = interpreter.derivative('x^2 + 2*x + 1', 'x');
  /// // Returns '2*x + 2'
  /// ```
  String derivative(
    String expression,
    String variable, {
    bool simplify = true,
  }) {
    final ast = parse(expression);
    final derivative =
        _differentiationEngine.differentiate(ast, variable, simplify: simplify);
    return derivative.toExpression();
  }

  /// Computes an integral with optional definite bounds.
  IntegralResult integral(
    String expression,
    String variable, {
    num? lowerBound,
    num? upperBound,
    bool simplify = true,
  }) {
    if ((lowerBound == null) ^ (upperBound == null)) {
      throw ArgumentError('Both lower and upper bounds must be provided.');
    }

    final ast = parse(expression);
    final antiderivative =
        _integrationEngine.integrate(ast, variable, simplify: simplify);

    NumberValue? definite;
    if (lowerBound != null && upperBound != null) {
      final lower = _numberValueFromNum(lowerBound);
      final upper = _numberValueFromNum(upperBound);
      final upperEval = _evaluateWithVariable(antiderivative, variable, upper);
      final lowerEval = _evaluateWithVariable(antiderivative, variable, lower);
      definite = upperEval - lowerEval;
    }

    return IntegralResult(
        antiderivative: antiderivative, definiteValue: definite);
  }

  /// Solves an equation numerically for the specified [variable].
  ///
  /// This delegates to the underlying [EquationSolver] instance and supports
  /// both implicit equations (`f(x)`) and explicit equalities (`lhs = rhs`).
  EquationSolution solveEquation(
    String equation,
    String variable, {
    num? initialGuess,
    num? lowerBound,
    num? upperBound,
    double tolerance = 1e-9,
    int maxIterations = 50,
    bool simplify = true,
  }) {
    return _equationSolver.solve(
      equation,
      variable,
      initialGuess: initialGuess,
      lowerBound: lowerBound,
      upperBound: upperBound,
      tolerance: tolerance,
      maxIterations: maxIterations,
      simplify: simplify,
    );
  }

  /// Computes a linearly interpolated value for [x] using [points].
  NumberValue interpolateLinear(List<Tuple2<dynamic, dynamic>> points, num x) {
    final normalised = _normalisePoints(points);
    return _interpolationEngine.interpolateLinear(normalised, x);
  }

  /// Computes a linearly extrapolated value for [x] using [points].
  NumberValue extrapolateLinear(List<Tuple2<dynamic, dynamic>> points, num x) {
    final normalised = _normalisePoints(points);
    return _interpolationEngine.extrapolateLinear(normalised, x);
  }

  /// Discovers a closed-form polynomial expression that generates [values].
  SequenceGeneratorResult sequenceFormula(
    List<num> values, {
    String variable = 'n',
    num startIndex = 0,
    bool simplify = true,
  }) {
    return _sequenceAnalyzer.generatePolynomial(
      values,
      variable: variable,
      startIndex: startIndex,
      simplify: simplify,
    );
  }

  /// Builds a Taylor series expansion up to [order] about [center].
  String series(
    String expression,
    String variable,
    int order, {
    num center = 0,
    bool simplify = true,
  }) {
    if (order < 0) {
      throw ArgumentError('Series order must be non-negative');
    }

    final ast = parse(expression);
    final centerValue = _numberValueFromNum(center);
    AstNode? result;

    for (var k = 0; k <= order; k++) {
      final derivativeAst = k == 0
          ? ast
          : _differentiationEngine.nthDerivative(
              ast,
              variable,
              k,
              simplify: simplify,
            );

      final derivativeValue =
          _evaluateWithVariable(derivativeAst, variable, centerValue);
      final factorialValue = _factorialValue(k);
      final coefficient = derivativeValue / factorialValue;

      final coefficientNode = NumberNode(coefficient);

      AstNode term;
      if (k == 0) {
        term = coefficientNode;
      } else {
        final base = center == 0
            ? VariableNode(variable)
            : BinaryOperationNode(
                '-',
                VariableNode(variable),
                NumberNode(centerValue),
              );
        term = BinaryOperationNode(
          '*',
          coefficientNode,
          BinaryOperationNode(
            '^',
            base,
            NumberNode(IntegerValue(k)),
          ),
        );
      }

      result = result == null ? term : BinaryOperationNode('+', result, term);
    }

    if (result == null) {
      return '0';
    }

    final simplified = simplify ? _simplifier.simplify(result) : result;
    return simplified.toExpression();
  }

  /// Computes the derivative and returns it as an AST.
  ///
  /// This method provides direct AST-to-AST differentiation.
  AstNode derivativeAst(AstNode ast, String variable, {bool simplify = true}) {
    return _differentiationEngine.differentiate(ast, variable,
        simplify: simplify);
  }

  /// Computes higher-order derivatives.
  ///
  /// This method computes the nth derivative of an expression by repeatedly
  /// applying the differentiation operation.
  ///
  /// Parameters:
  /// - [expression]: The expression to differentiate
  /// - [variable]: The variable to differentiate with respect to
  /// - [order]: The order of the derivative (1 = first, 2 = second, etc.)
  /// - [simplify]: Whether to simplify intermediate results (default: true)
  ///
  /// Returns a string representing the nth derivative.
  ///
  /// Example:
  /// ```dart
  /// final result = interpreter.nthDerivative('x^4', 'x', 2); // Returns '12*x^2'
  /// ```
  String nthDerivative(String expression, String variable, int order,
      {bool simplify = true}) {
    final ast = parse(expression);
    final derivative = _differentiationEngine
        .nthDerivative(ast, variable, order, simplify: simplify);
    return derivative.toExpression();
  }

  /// Computes partial derivatives for multi-variable expressions.
  ///
  /// This method computes the partial derivative with respect to one variable,
  /// treating all other variables as constants.
  String partialDerivative(String expression, String variable,
      {bool simplify = true}) {
    final ast = parse(expression);
    final derivative = _differentiationEngine.partialDerivative(ast, variable,
        simplify: simplify);
    return derivative.toExpression();
  }

  /// Computes the gradient vector for multi-variable expressions.
  ///
  /// The gradient is a vector of partial derivatives with respect to each variable.
  /// This method returns a map where keys are variable names and values are
  /// the corresponding partial derivatives as strings.
  Map<String, String> gradient(String expression, List<String> variables,
      {bool simplify = true}) {
    final ast = parse(expression);
    final gradientAst =
        _differentiationEngine.gradient(ast, variables, simplify: simplify);

    final gradientStrings = <String, String>{};
    for (final entry in gradientAst.entries) {
      gradientStrings[entry.key] = entry.value.toExpression();
    }

    return gradientStrings;
  }

  /// Evaluates the gradient at the numeric point specified by [at] and
  /// returns a column vector matrix.
  MatrixValue gradientVector(
    String expression,
    List<String> variables,
    Map<String, num> at, {
    bool simplify = true,
  }) {
    final ast = parse(expression);
    final gradientAst =
        _differentiationEngine.gradient(ast, variables, simplify: simplify);

    final rows = <List<NumberValue>>[];

    for (final variable in variables) {
      if (!at.containsKey(variable)) {
        throw ArgumentError('Missing value for variable $variable');
      }

      final derivativeAst = gradientAst[variable]!;
      final evaluated = _evaluateWithVariable(
        derivativeAst,
        variable,
        _numberValueFromNum(at[variable]!),
      );
      rows.add([evaluated]);
    }

    return MatrixValue.fromRows(rows);
  }

  /// Evaluates an AST with the current variable context.
  ///
  /// This method evaluates an AST node using the variables and constants
  /// defined in the underlying interpreter.
  NumberValue evaluateAst(AstNode ast) {
    final context = <String, NumberValue>{}
      ..addAll(_interpreter.variables)
      ..addAll(_interpreter.constants);

    return ast.evaluate(context);
  }

  /// Sets a variable value in the interpreter.
  void setVariable(String name, NumberValue value) {
    _interpreter.variables[name] = value;
  }

  /// Gets a variable value from the interpreter.
  NumberValue? getVariable(String name) {
    return _interpreter.variables[name];
  }

  /// Gets all current variables.
  Map<String, NumberValue> get variables => _interpreter.variables;

  /// Gets all available constants.
  Map<String, NumberValue> get constants => _interpreter.constants;

  /// Analyzes an expression and returns information about it.
  ///
  /// This method provides detailed information about an expression including
  /// the variables it contains, its complexity, and other structural properties.
  ExpressionInfo analyzeExpression(String expression) {
    final ast = parse(expression);
    return _analyzeAst(ast);
  }

  NumberValue _evaluateWithVariable(
    AstNode ast,
    String variable,
    NumberValue value,
  ) {
    final hadValue = _interpreter.variables.containsKey(variable);
    final previous = _interpreter.variables[variable];

    try {
      _interpreter.variables[variable] = value;
      return evaluateAst(ast);
    } finally {
      if (hadValue) {
        _interpreter.variables[variable] = previous!;
      } else {
        _interpreter.variables.remove(variable);
      }
    }
  }

  NumberValue _numberValueFromNum(num value) {
    if (value % 1 == 0) {
      return IntegerValue(value.toInt());
    }

    return DoubleValue(value.toDouble());
  }

  NumberValue _factorialValue(int order) {
    if (order <= 1) {
      return IntegerValue(1);
    }

    NumberValue result = IntegerValue(1);
    for (var i = 2; i <= order; i++) {
      result = result * IntegerValue(i);
    }

    return result;
  }

  /// Internal method to count function arguments from tokens.
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

  /// Analyzes an AST and returns structural information.
  ExpressionInfo _analyzeAst(AstNode ast) {
    final variables = <String>{};
    final functions = <String>{};
    var nodeCount = 0;
    var maxDepth = 0;

    void traverse(AstNode node, int depth) {
      nodeCount++;
      maxDepth = depth > maxDepth ? depth : maxDepth;

      if (node is VariableNode) {
        variables.add(node.name);
      } else if (node is FunctionNode) {
        functions.add(node.name);
        traverse(node.argument, depth + 1);
        node.arguments?.forEach((arg) => traverse(arg, depth + 1));
      } else if (node is BinaryOperationNode) {
        traverse(node.left, depth + 1);
        traverse(node.right, depth + 1);
      } else if (node is UnaryOperationNode) {
        traverse(node.operand, depth + 1);
      }
    }

    traverse(ast, 0);

    return ExpressionInfo(
      variables: variables.toList(),
      functions: functions.toList(),
      nodeCount: nodeCount,
      maxDepth: maxDepth,
      expression: ast.toExpression(),
    );
  }

  List<Tuple2<num, num>> _normalisePoints(
      List<Tuple2<dynamic, dynamic>> points) {
    return points.map((point) {
      final x = _toNum(point.item1, 'x');
      final y = _toNum(point.item2, 'y');
      return Tuple2<num, num>(x, y);
    }).toList();
  }

  num _toNum(dynamic value, String coordinate) {
    if (value is num) {
      return value;
    }
    if (value is NumberValue) {
      final raw = value.value;
      if (raw is num) {
        return raw;
      }
    }
    throw ArgumentError('Point $coordinate-value must be numeric, got $value');
  }
}

/// Contains information about the structure and properties of an expression.
class ExpressionInfo {
  /// Creates new expression information.
  ExpressionInfo({
    required this.variables,
    required this.functions,
    required this.nodeCount,
    required this.maxDepth,
    required this.expression,
  });

  /// List of all variables in the expression.
  final List<String> variables;

  /// List of all functions used in the expression.
  final List<String> functions;

  /// Total number of nodes in the AST.
  final int nodeCount;

  /// Maximum depth of the AST.
  final int maxDepth;

  /// String representation of the expression.
  final String expression;

  /// Returns the complexity score of the expression.
  ///
  /// This is a simple heuristic based on node count and depth.
  int get complexity => nodeCount + maxDepth * 2;

  @override
  String toString() {
    return 'ExpressionInfo(\n'
        '  variables: $variables,\n'
        '  functions: $functions,\n'
        '  nodeCount: $nodeCount,\n'
        '  maxDepth: $maxDepth,\n'
        '  complexity: $complexity,\n'
        '  expression: "$expression"\n'
        ')';
  }
}

/// Result of an integration request.
class IntegralResult {
  /// Creates a new integral result.
  IntegralResult({required this.antiderivative, this.definiteValue});

  /// The antiderivative as an AST node.
  final AstNode antiderivative;

  /// The definite integral value if bounds were provided.
  final NumberValue? definiteValue;

  /// String representation of the antiderivative.
  String get expression => antiderivative.toExpression();

  /// Whether the result contains a definite integral evaluation.
  bool get hasDefiniteValue => definiteValue != null;
}
