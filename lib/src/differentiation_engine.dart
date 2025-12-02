// ignore_for_file: lines_longer_than_80_chars

import 'package:fn_express/src/ast_node.dart';
import 'package:fn_express/src/expression_simplifier.dart';
import 'package:fn_express/src/number_value.dart';

/// Provides symbolic differentiation capabilities for mathematical expressions.
///
/// This class can compute derivatives of mathematical expressions with respect to any variable.
/// It supports all basic operations and common mathematical functions, applying the chain rule, product rule, and quotient rule as needed.
class DifferentiationEngine {
  /// Creates a new differentiation engine.
  DifferentiationEngine([ExpressionSimplifier? simplifier])
      : _simplifier = simplifier ?? ExpressionSimplifier();

  final ExpressionSimplifier _simplifier;

  /// Computes the derivative of an expression with respect to a variable.
  ///
  /// This method takes an AST representing a mathematical expression and computes its derivative symbolically using standard calculus rules.
  /// The result is automatically simplified.
  ///
  /// Parameters:
  /// - [expression]: The AST node representing the expression to differentiate
  /// - [variable]: The variable to differentiate with respect to
  /// - [simplify]: Whether to simplify the result (default: true)
  ///
  /// Returns a new [AstNode] representing the derivative.
  ///
  /// Example:
  /// ```dart
  /// // d/dx(x^2 + 2*x + 1) = 2*x + 2
  /// final derivative = engine.differentiate(expression, 'x');
  /// ```
  AstNode differentiate(
    AstNode expression,
    String variable, {
    bool simplify = true,
  }) {
    final derivative = _computeDerivative(expression, variable);

    return simplify ? _simplifier.simplify(derivative) : derivative;
  }

  /// Computes higher-order derivatives.
  ///
  /// This method computes the nth derivative of an expression by repeatedly applying the differentiation operation.
  ///
  /// Parameters:
  /// - [expression]: The AST node representing the expression to differentiate
  /// - [variable]: The variable to differentiate with respect to
  /// - [order]: The order of the derivative (1 = first derivative, 2 = second, etc.)
  /// - [simplify]: Whether to simplify intermediate results (default: true)
  ///
  /// Returns a new [AstNode] representing the nth derivative.
  AstNode nthDerivative(
    AstNode expression,
    String variable,
    int order, {
    bool simplify = true,
  }) {
    if (order < 0) {
      throw ArgumentError('Derivative order must be non-negative');
    }
    if (order == 0) {
      return expression;
    }

    var current = expression;

    for (var i = 0; i < order; i++) {
      current = differentiate(current, variable, simplify: simplify);
    }

    return current;
  }

  /// Computes partial derivatives for multi-variable expressions.
  ///
  /// This method computes the partial derivative with respect to one variable, treating all other variables as constants.
  AstNode partialDerivative(
    AstNode expression,
    String variable, {
    bool simplify = true,
  }) =>
      differentiate(expression, variable, simplify: simplify);

  /// Computes the gradient vector for multi-variable expressions.
  ///
  /// The gradient is a vector of partial derivatives with respect to each variable.
  /// This method returns a map where keys are variable names and values are the corresponding partial derivatives.
  Map<String, AstNode> gradient(
    AstNode expression,
    List<String> variables, {
    bool simplify = true,
  }) {
    final gradientMap = <String, AstNode>{};

    for (final variable in variables) {
      gradientMap[variable] =
          partialDerivative(expression, variable, simplify: simplify);
    }

    return gradientMap;
  }

  /// Internal method that performs the actual derivative computation.
  AstNode _computeDerivative(AstNode node, String variable) {
    if (node is NumberNode) {
      return NumberNode(IntegerValue(0));
    } else if (node is VariableNode) {
      return NumberNode(IntegerValue(node.name == variable ? 1 : 0));
    } else if (node is BinaryOperationNode) {
      return _differentiateOperation(node, variable);
    } else if (node is UnaryOperationNode) {
      return _differentiateUnaryOperation(node, variable);
    } else if (node is FunctionNode) {
      return _differentiateFunction(node, variable);
    } else {
      throw ArgumentError(
        'Unsupported node type for differentiation: ${node.runtimeType}',
      );
    }
  }

  /// Differentiates binary operations using appropriate rules.
  AstNode _differentiateOperation(BinaryOperationNode node, String variable) {
    final left = node.left;
    final right = node.right;
    final leftDerivative = _computeDerivative(left, variable);
    final rightDerivative = _computeDerivative(right, variable);

    switch (node.operator) {
      case '+':
      case '-':
        return BinaryOperationNode(
            node.operator, leftDerivative, rightDerivative);

      case '*':
        return BinaryOperationNode(
          '+',
          BinaryOperationNode('*', leftDerivative, right),
          BinaryOperationNode('*', left, rightDerivative),
        );

      case '/':
        return BinaryOperationNode(
          '/',
          BinaryOperationNode(
            '-',
            BinaryOperationNode('*', leftDerivative, right),
            BinaryOperationNode('*', left, rightDerivative),
          ),
          BinaryOperationNode('^', right, NumberNode(IntegerValue(2))),
        );

      case '^':
        return _differentiatePower(left, right, variable);

      case '%':
        throw ArgumentError(
          'Differentiation of modulo operation not supported',
        );

      default:
        throw ArgumentError('Unknown binary operator: ${node.operator}');
    }
  }

  /// Differentiates power expressions using the power rule and chain rule.
  AstNode _differentiatePower(AstNode base, AstNode exponent, String variable) {
    final baseDerivative = _computeDerivative(base, variable);
    final exponentDerivative = _computeDerivative(exponent, variable);

    final isExponentConstant = _isConstantWithRespectTo(exponent, variable);
    final isBaseConstant = _isConstantWithRespectTo(base, variable);

    if (isExponentConstant && isBaseConstant) {
      return NumberNode(IntegerValue(0));
    } else if (isExponentConstant) {
      return BinaryOperationNode(
        '*',
        BinaryOperationNode(
          '*',
          exponent,
          BinaryOperationNode(
            '^',
            base,
            BinaryOperationNode('-', exponent, NumberNode(IntegerValue(1))),
          ),
        ),
        baseDerivative,
      );
    } else if (isBaseConstant) {
      return BinaryOperationNode(
        '*',
        BinaryOperationNode(
          '*',
          BinaryOperationNode('^', base, exponent),
          FunctionNode('ln', base),
        ),
        exponentDerivative,
      );
    } else {
      return BinaryOperationNode(
        '*',
        BinaryOperationNode('^', base, exponent),
        BinaryOperationNode(
          '+',
          BinaryOperationNode(
            '*',
            exponentDerivative,
            FunctionNode('ln', base),
          ),
          BinaryOperationNode(
            '*',
            exponent,
            BinaryOperationNode('/', baseDerivative, base),
          ),
        ),
      );
    }
  }

  /// Differentiates unary operations.
  AstNode _differentiateUnaryOperation(
      UnaryOperationNode node, String variable) {
    final operandDerivative = _computeDerivative(node.operand, variable);

    switch (node.operator) {
      case '-':
        return UnaryOperationNode('-', operandDerivative);
      case '+':
        return operandDerivative;
      default:
        throw ArgumentError('Unknown unary operator: ${node.operator}');
    }
  }

  /// Differentiates function calls using known derivatives and chain rule.
  AstNode _differentiateFunction(FunctionNode node, String variable) {
    final additionalArguments = node.arguments ?? const [];

    for (final argument in additionalArguments) {
      if (!_isConstantWithRespectTo(argument, variable)) {
        throw ArgumentError(
          'Differentiation not implemented for function ${node.name} '
          'with non-constant parameter.',
        );
      }
    }

    final argumentDerivative = _computeDerivative(node.argument, variable);
    final functionDerivative = _getFunctionDerivative(node, variable);

    return BinaryOperationNode('*', functionDerivative, argumentDerivative);
  }

  /// Returns the derivative of a known function.
  AstNode _getFunctionDerivative(FunctionNode node, String variable) {
    final argument = node.argument;
    final extraArguments = node.arguments ?? const [];

    switch (node.name) {
      case 'sin':
        return FunctionNode('cos', argument);
      case 'cos':
        return UnaryOperationNode('-', FunctionNode('sin', argument));
      case 'tan':
        return BinaryOperationNode(
          '^',
          FunctionNode('sec', argument),
          NumberNode(IntegerValue(2)),
        );
      case 'cot':
        return UnaryOperationNode(
          '-',
          BinaryOperationNode(
            '^',
            FunctionNode('csc', argument),
            NumberNode(IntegerValue(2)),
          ),
        );
      case 'sec':
        return BinaryOperationNode(
          '*',
          FunctionNode('sec', argument),
          FunctionNode('tan', argument),
        );
      case 'csc':
        return UnaryOperationNode(
          '-',
          BinaryOperationNode(
            '*',
            FunctionNode('csc', argument),
            FunctionNode('cot', argument),
          ),
        );
      case 'asin':
        return BinaryOperationNode(
          '/',
          NumberNode(IntegerValue(1)),
          FunctionNode(
            'sqrt',
            BinaryOperationNode(
              '-',
              NumberNode(IntegerValue(1)),
              BinaryOperationNode('^', argument, NumberNode(IntegerValue(2))),
            ),
          ),
        );
      case 'acos':
        return UnaryOperationNode(
          '-',
          BinaryOperationNode(
            '/',
            NumberNode(IntegerValue(1)),
            FunctionNode(
              'sqrt',
              BinaryOperationNode(
                '-',
                NumberNode(IntegerValue(1)),
                BinaryOperationNode('^', argument, NumberNode(IntegerValue(2))),
              ),
            ),
          ),
        );
      case 'atan':
        return BinaryOperationNode(
          '/',
          NumberNode(IntegerValue(1)),
          BinaryOperationNode(
            '+',
            NumberNode(IntegerValue(1)),
            BinaryOperationNode('^', argument, NumberNode(IntegerValue(2))),
          ),
        );
      case 'sinh':
        return FunctionNode('cosh', argument);
      case 'cosh':
        return FunctionNode('sinh', argument);
      case 'tanh':
        return BinaryOperationNode(
          '-',
          NumberNode(IntegerValue(1)),
          BinaryOperationNode(
            '^',
            FunctionNode('tanh', argument),
            NumberNode(IntegerValue(2)),
          ),
        );
      case 'sech':
        return UnaryOperationNode(
          '-',
          BinaryOperationNode(
            '*',
            FunctionNode('sech', argument),
            FunctionNode('tanh', argument),
          ),
        );
      case 'csch':
        return UnaryOperationNode(
          '-',
          BinaryOperationNode(
            '*',
            FunctionNode('csch', argument),
            FunctionNode('coth', argument),
          ),
        );
      case 'coth':
        return UnaryOperationNode(
          '-',
          BinaryOperationNode(
            '^',
            FunctionNode('csch', argument),
            NumberNode(IntegerValue(2)),
          ),
        );
      case 'asinh':
        return BinaryOperationNode(
          '/',
          NumberNode(IntegerValue(1)),
          FunctionNode(
            'sqrt',
            BinaryOperationNode(
              '+',
              NumberNode(IntegerValue(1)),
              BinaryOperationNode('^', argument, NumberNode(IntegerValue(2))),
            ),
          ),
        );
      case 'acosh':
        return BinaryOperationNode(
          '/',
          NumberNode(IntegerValue(1)),
          FunctionNode(
            'sqrt',
            BinaryOperationNode(
              '-',
              BinaryOperationNode('^', argument, NumberNode(IntegerValue(2))),
              NumberNode(IntegerValue(1)),
            ),
          ),
        );
      case 'atanh':
        return BinaryOperationNode(
          '/',
          NumberNode(IntegerValue(1)),
          BinaryOperationNode(
            '-',
            NumberNode(IntegerValue(1)),
            BinaryOperationNode('^', argument, NumberNode(IntegerValue(2))),
          ),
        );
      case 'exp':
        return FunctionNode('exp', argument);
      case 'ln':
        return BinaryOperationNode('/', NumberNode(IntegerValue(1)), argument);
      case 'log':
        final base = extraArguments.isNotEmpty
            ? extraArguments.first
            : NumberNode(IntegerValue(10));

        if (!_isConstantWithRespectTo(base, variable)) {
          throw ArgumentError(
            'Differentiation of logarithm with variable base is not supported',
          );
        }

        return BinaryOperationNode(
          '/',
          NumberNode(IntegerValue(1)),
          BinaryOperationNode(
            '*',
            argument,
            FunctionNode('ln', base),
          ),
        );
      case 'sqrt':
        return BinaryOperationNode(
          '/',
          NumberNode(IntegerValue(1)),
          BinaryOperationNode(
            '*',
            NumberNode(IntegerValue(2)),
            FunctionNode('sqrt', argument),
          ),
        );
      case 'abs':
        return FunctionNode('sign', argument);
      case 'sign':
        return NumberNode(IntegerValue(0));
      case 'floor':
      case 'ceil':
      case 'round':
      case 'trunc':
        return NumberNode(IntegerValue(0));

      default:
        throw ArgumentError(
            'Derivative not implemented for function: ${node.name}');
    }
  }

  /// Checks if an expression is constant with respect to a variable.
  bool _isConstantWithRespectTo(AstNode node, String variable) {
    if (node is NumberNode) {
      return true;
    } else if (node is VariableNode) {
      return node.name != variable;
    } else if (node is BinaryOperationNode) {
      return _isConstantWithRespectTo(node.left, variable) &&
          _isConstantWithRespectTo(node.right, variable);
    } else if (node is UnaryOperationNode) {
      return _isConstantWithRespectTo(node.operand, variable);
    } else if (node is FunctionNode) {
      return _isConstantWithRespectTo(node.argument, variable) &&
          (node.arguments
                  ?.every((arg) => _isConstantWithRespectTo(arg, variable)) ??
              true);
    }
    return false;
  }
}
