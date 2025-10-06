import 'package:fn_express/src/ast_node.dart';
import 'package:fn_express/src/expression_simplifier.dart';
import 'package:fn_express/src/number_value.dart';

/// Result returned by [SequenceAnalyzer] when generating a closed-form
/// expression for a numeric series.
class SequenceGeneratorResult {
  /// Creates a new [SequenceGeneratorResult].
  SequenceGeneratorResult({
    required this.expression,
    required this.degree,
    required List<double> coefficients,
    required List<List<double>> differenceTable,
    required this.variable,
    required this.startIndex,
    required double Function(num n) evaluator,
  })  : coefficients = List.unmodifiable(coefficients),
        differenceTable = differenceTable
            .map(List<double>.unmodifiable)
            .toList(growable: false),
        _evaluator = evaluator;

  /// Simplified symbolic expression that generates the sequence.
  final String expression;

  /// Degree of the resulting polynomial.
  final int degree;

  /// Polynomial coefficients in powers of \(n - startIndex\).
  final List<double> coefficients;

  /// Forward-difference table used during synthesis (useful for inspection).
  final List<List<double>> differenceTable;

  /// Name of the index variable used in the expression.
  final String variable;

  /// Starting index assumed for the first provided term.
  final num startIndex;

  final double Function(num n) _evaluator;

  /// Evaluates the generated polynomial at [n].
  double termAt(num n) => _evaluator(n);

  /// Generates [count] consecutive terms beginning at [startIndex].
  List<double> generateTerms(int count) {
    return List<double>.generate(
      count,
      (idx) => termAt(startIndex + idx),
      growable: false,
    );
  }
}

/// Provides utilities for discovering closed-form polynomial expressions that
/// reproduce a numeric series.
class SequenceAnalyzer {
  /// Creates a new [SequenceAnalyzer].
  SequenceAnalyzer({ExpressionSimplifier? simplifier, double tolerance = 1e-9})
      : _simplifier = simplifier ?? ExpressionSimplifier(),
        _tolerance = tolerance;

  final ExpressionSimplifier _simplifier;
  final double _tolerance;

  /// Synthesises a polynomial expression that exactly fits the provided
  /// [values].
  ///
  /// The first value is assumed to occur at [startIndex] (default `0`).
  /// When [simplify] is true the resulting AST is algebraically simplified
  /// before being converted to an expression string.
  SequenceGeneratorResult generatePolynomial(
    List<num> values, {
    String variable = 'n',
    num startIndex = 0,
    bool simplify = true,
  }) {
    if (values.isEmpty) {
      throw ArgumentError('At least one value is required to synthesize');
    }

    final differenceTable = _buildDifferenceTable(values);
    final coefficients = _computePolynomialCoefficients(differenceTable);
    final trimmedCoefficients = _trimCoefficients(coefficients);
    final ast = _buildPolynomialAst(trimmedCoefficients, variable, startIndex);
    final simplified = simplify ? _simplifier.simplify(ast) : ast;

    return SequenceGeneratorResult(
      expression: simplified.toExpression(),
      degree: trimmedCoefficients.length - 1,
      coefficients: trimmedCoefficients,
      differenceTable: differenceTable,
      variable: variable,
      startIndex: startIndex,
      evaluator: (n) => _evaluatePolynomial(trimmedCoefficients, n, startIndex),
    );
  }

  List<List<double>> _buildDifferenceTable(List<num> values) {
    final table = <List<double>>[
      values.map((v) => v.toDouble()).toList(growable: false)
    ];

    while (table.last.length > 1) {
      final prev = table.last;
      final next = List<double>.generate(
        prev.length - 1,
        (i) => prev[i + 1] - prev[i],
        growable: false,
      );
      table.add(next);
    }

    return table;
  }

  List<double> _computePolynomialCoefficients(List<List<double>> table) {
    if (table.isEmpty) {
      return <double>[];
    }

    final coefficients = List<double>.filled(table.first.length, 0);
    var basis = <double>[1];

    for (var order = 0; order < table.length; order++) {
      final delta = table[order].first;
      final coeff = delta / _factorial(order);
      _accumulatePolynomial(coefficients, basis, coeff);
      basis = _multiplyPolynomial(basis, <double>[-order.toDouble(), 1]);
    }

    return coefficients;
  }

  List<double> _trimCoefficients(List<double> coefficients) {
    if (coefficients.isEmpty) {
      return <double>[0];
    }

    var last = coefficients.length - 1;
    while (last > 0 && coefficients[last].abs() < _tolerance) {
      last--;
    }

    if (last == 0 && coefficients[0].abs() < _tolerance) {
      return <double>[0];
    }

    return coefficients.sublist(0, last + 1);
  }

  AstNode _buildPolynomialAst(
    List<double> coefficients,
    String variable,
    num startIndex,
  ) {
    if (coefficients.length == 1) {
      return NumberNode(_numberValueFromDouble(coefficients.first));
    }

    AstNode node = NumberNode(
      _numberValueFromDouble(coefficients.last),
    );

    for (var i = coefficients.length - 2; i >= 0; i--) {
      node = BinaryOperationNode(
        '*',
        node,
        _shiftedVariable(variable, startIndex),
      );

      final coeff = coefficients[i];
      if (coeff.abs() < _tolerance) {
        continue;
      }

      node = BinaryOperationNode(
        '+',
        node,
        NumberNode(_numberValueFromDouble(coeff)),
      );
    }

    return node;
  }

  AstNode _shiftedVariable(String variable, num startIndex) {
    final variableNode = VariableNode(variable);

    if (startIndex == 0) {
      return variableNode;
    }

    final shiftValue = _numberValueFromDouble(startIndex.toDouble().abs());
    final shiftNode = NumberNode(shiftValue);

    if (startIndex > 0) {
      return BinaryOperationNode('-', variableNode, shiftNode);
    }

    return BinaryOperationNode('+', variableNode, shiftNode);
  }

  NumberValue _numberValueFromDouble(double value) {
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() <= _tolerance && rounded.abs() <= 1e12) {
      return IntegerValue(rounded.toInt());
    }

    return DoubleValue(value);
  }

  void _accumulatePolynomial(
    List<double> target,
    List<double> poly,
    double scale,
  ) {
    for (var i = 0; i < poly.length; i++) {
      target[i] += poly[i] * scale;
    }
  }

  List<double> _multiplyPolynomial(List<double> a, List<double> b) {
    final result = List<double>.filled(a.length + b.length - 1, 0);

    for (var i = 0; i < a.length; i++) {
      for (var j = 0; j < b.length; j++) {
        result[i + j] += a[i] * b[j];
      }
    }

    return result;
  }

  double _factorial(int order) {
    if (order <= 1) {
      return 1;
    }

    var result = 1.0;
    for (var i = 2; i <= order; i++) {
      result *= i;
    }

    return result;
  }

  double _evaluatePolynomial(
    List<double> coefficients,
    num n,
    num startIndex,
  ) {
    final shifted = (n - startIndex).toDouble();
    var result = coefficients.last;

    for (var i = coefficients.length - 2; i >= 0; i--) {
      result = result * shifted + coefficients[i];
    }

    return result;
  }
}
