// ignore_for_file: lines_longer_than_80_chars

import 'dart:math' as math;

import 'package:fn_express/src/complex.dart';
import 'package:fn_express/src/number_value.dart';

/// Abstract base class for all nodes in the abstract syntax tree (AST).
///
/// The AST represents mathematical expressions in a tree structure that enables operations like simplification, differentiation, and evaluation.
/// Each node knows how to evaluate itself, simplify itself, and compute its derivative with respect to a variable.
abstract class AstNode {
  /// Evaluates this node to a numeric value using the provided variable context.
  NumberValue evaluate(Map<String, NumberValue> variables);

  /// Simplifies this expression by applying algebraic rules.
  ///
  /// Returns a new AST node representing the simplified expression.
  AstNode simplify();

  /// Computes the derivative of this expression with respect to [variable].
  ///
  /// Returns a new AST node representing the derivative.
  AstNode derivative(String variable);

  /// Returns a string representation of this expression.
  String toExpression();

  @override
  String toString() => toExpression();
}

/// Represents a numeric constant in the AST.
class NumberNode extends AstNode {
  /// Creates a number node with the given [value].
  NumberNode(this.value);

  /// The numeric value of this node.
  final NumberValue value;

  @override
  NumberValue evaluate(Map<String, NumberValue> variables) => value;

  @override
  AstNode simplify() => this;

  @override
  AstNode derivative(String variable) => NumberNode(IntegerValue(0));

  @override
  String toExpression() => value.toString();
}

/// Represents a variable in the AST.
class VariableNode extends AstNode {
  /// Creates a variable node with the given [name].
  VariableNode(this.name);

  /// The name of the variable (e.g., 'x', 'y').
  final String name;

  @override
  NumberValue evaluate(Map<String, NumberValue> variables) {
    if (!variables.containsKey(name)) {
      throw ArgumentError('Undefined variable: $name');
    }

    return variables[name]!;
  }

  @override
  AstNode simplify() => this;

  @override
  AstNode derivative(String variable) =>
      NumberNode(IntegerValue(variable == name ? 1 : 0));

  @override
  String toExpression() => name;
}

/// Represents a binary operation in the AST.
class BinaryOperationNode extends AstNode {
  /// Creates a binary operation node with the given [operator], [left], and [right] operands.
  BinaryOperationNode(this.operator, this.left, this.right);

  /// The operator (e.g., '+', '-', '*', '/', '^').
  final String operator;

  /// The left operand.
  final AstNode left;

  /// The right operand.
  final AstNode right;

  @override
  NumberValue evaluate(Map<String, NumberValue> variables) {
    final leftVal = left.evaluate(variables);
    final rightVal = right.evaluate(variables);

    return switch (operator) {
      '+' => leftVal + rightVal,
      '-' => leftVal - rightVal,
      '*' => leftVal * rightVal,
      '/' => leftVal / rightVal,
      '^' => leftVal.power(rightVal),
      '%' => leftVal.modulo(rightVal),
      _ => throw ArgumentError('Unknown operator: $operator'),
    };
  }

  @override
  AstNode simplify() {
    final simplifiedLeft = left.simplify();
    final simplifiedRight = right.simplify();

    if (simplifiedLeft is NumberNode && simplifiedRight is NumberNode) {
      try {
        final result =
            BinaryOperationNode(operator, simplifiedLeft, simplifiedRight)
                .evaluate({});

        return NumberNode(result);
      } on Exception catch (_) {}
    }

    return _applySimplificationRules(operator, simplifiedLeft, simplifiedRight);
  }

  @override
  AstNode derivative(String variable) => switch (operator) {
        '+' => BinaryOperationNode(
            '+', left.derivative(variable), right.derivative(variable)),
        '-' => BinaryOperationNode(
            '-', left.derivative(variable), right.derivative(variable)),
        '*' => _productRule(variable),
        '/' => _quotientRule(variable),
        '^' => _powerRule(variable),
        _ => throw ArgumentError(
            'Derivative not supported for operator: $operator',
          ),
      };

  /// Product rule: (f * g)' = f' * g + f * g'
  AstNode _productRule(String variable) => BinaryOperationNode(
        '+',
        BinaryOperationNode('*', left.derivative(variable), right),
        BinaryOperationNode('*', left, right.derivative(variable)),
      );

  /// Quotient rule: (f / g)' = (f' * g - f * g') / g^2
  AstNode _quotientRule(String variable) => BinaryOperationNode(
        '/',
        BinaryOperationNode(
          '-',
          BinaryOperationNode('*', left.derivative(variable), right),
          BinaryOperationNode('*', left, right.derivative(variable)),
        ),
        BinaryOperationNode('^', right, NumberNode(IntegerValue(2))),
      );

  /// Power rule and chain rule for exponentation
  AstNode _powerRule(String variable) {
    if (right is NumberNode) {
      final exponent = right as NumberNode;
      final newExponent =
          BinaryOperationNode('-', right, NumberNode(IntegerValue(1)));

      return BinaryOperationNode(
        '*',
        BinaryOperationNode(
          '*',
          exponent,
          BinaryOperationNode('^', left, newExponent),
        ),
        left.derivative(variable),
      );
    }

    return BinaryOperationNode(
      '*',
      BinaryOperationNode('^', left, right),
      BinaryOperationNode(
        '+',
        BinaryOperationNode(
          '*',
          right.derivative(variable),
          FunctionNode('ln', left),
        ),
        BinaryOperationNode(
          '*',
          right,
          BinaryOperationNode('/', left.derivative(variable), left),
        ),
      ),
    );
  }

  AstNode _applySimplificationRules(String op, AstNode left, AstNode right) {
    if (op == '+') {
      if (left is NumberNode && _isZero(left.value)) return right;
      if (right is NumberNode && _isZero(right.value)) return left;
    }

    if (op == '-') {
      if (right is NumberNode && _isZero(right.value)) return left;

      if (left is NumberNode && _isZero(left.value)) {
        return UnaryOperationNode('-', right);
      }

      if (left.toExpression() == right.toExpression()) {
        return NumberNode(IntegerValue(0));
      }
    }

    if (op == '*') {
      if (left is NumberNode && _isZero(left.value)) {
        return NumberNode(IntegerValue(0));
      }

      if (right is NumberNode && _isZero(right.value)) {
        return NumberNode(IntegerValue(0));
      }

      if (left is NumberNode && _isOne(left.value)) return right;

      if (right is NumberNode && _isOne(right.value)) return left;
    }

    if (op == '/') {
      if (left is NumberNode && _isZero(left.value)) {
        return NumberNode(IntegerValue(0));
      }

      if (right is NumberNode && _isOne(right.value)) return left;

      if (left.toExpression() == right.toExpression()) {
        return NumberNode(IntegerValue(1));
      }
    }

    if (op == '^') {
      if (right is NumberNode && _isZero(right.value)) {
        return NumberNode(IntegerValue(1));
      }

      if (right is NumberNode && _isOne(right.value)) return left;

      if (left is NumberNode && _isZero(left.value)) {
        return NumberNode(IntegerValue(0));
      }

      if (left is NumberNode && _isOne(left.value)) {
        return NumberNode(IntegerValue(1));
      }
    }

    return BinaryOperationNode(op, left, right);
  }

  bool _isZero(NumberValue value) {
    final raw = value.value;

    if (raw is num) {
      return raw == 0;
    }

    if (raw is Complex) {
      return raw.real == 0 && raw.imaginary == 0;
    }

    return false;
  }

  bool _isOne(NumberValue value) {
    final raw = value.value;

    if (raw is num) {
      return raw == 1;
    }

    if (raw is Complex) {
      return raw.real == 1 && raw.imaginary == 0;
    }

    return false;
  }

  @override
  String toExpression() {
    final leftStr = left.toExpression();
    final rightStr = right.toExpression();

    final needsLeftParens = _needsParentheses(left, operator, true);
    final needsRightParens = _needsParentheses(right, operator, false);

    final leftExpr = needsLeftParens ? '($leftStr)' : leftStr;
    final rightExpr = needsRightParens ? '($rightStr)' : rightStr;

    return '$leftExpr $operator $rightExpr';
  }

  bool _needsParentheses(AstNode node, String parentOp, bool isLeft) {
    if (node is! BinaryOperationNode) return false;

    final nodePrecedence = _getPrecedence(node.operator);
    final parentPrecedence = _getPrecedence(parentOp);

    if (nodePrecedence < parentPrecedence) return true;
    if (nodePrecedence > parentPrecedence) return false;

    if (parentOp == '^' && !isLeft) return true;
    if (parentOp == '-' && !isLeft) return true;
    if (parentOp == '/' && !isLeft) return true;

    return false;
  }

  int _getPrecedence(String op) => switch (op) {
        '^' => 4,
        '*' || '/' || '%' => 3,
        '+' || '-' => 2,
        _ => 0,
      };
}

/// Represents a unary operation in the AST.
class UnaryOperationNode extends AstNode {
  /// Creates a unary operation node with the given [operator] and [operand].
  UnaryOperationNode(this.operator, this.operand);

  /// The operator (e.g., '-', '+').
  final String operator;

  /// The operand.
  final AstNode operand;

  @override
  NumberValue evaluate(Map<String, NumberValue> variables) {
    final operandVal = operand.evaluate(variables);

    return switch (operator) {
      '-' => operandVal.negate(),
      '+' => operandVal,
      _ => throw ArgumentError('Unknown unary operator: $operator'),
    };
  }

  @override
  AstNode simplify() {
    final simplifiedOperand = operand.simplify();

    if (simplifiedOperand is NumberNode) {
      final result =
          UnaryOperationNode(operator, simplifiedOperand).evaluate({});
      return NumberNode(result);
    }

    if (operator == '-' &&
        simplifiedOperand is UnaryOperationNode &&
        simplifiedOperand.operator == '-') {
      return simplifiedOperand.operand;
    }

    return UnaryOperationNode(operator, simplifiedOperand);
  }

  @override
  AstNode derivative(String variable) => switch (operator) {
        '-' => UnaryOperationNode('-', operand.derivative(variable)),
        '+' => operand.derivative(variable),
        _ => throw ArgumentError(
            'Derivative not supported for unary operator: $operator'),
      };

  @override
  String toExpression() {
    final operandStr = operand.toExpression();
    final needsParens = operand is BinaryOperationNode;
    final operandExpr = needsParens ? '($operandStr)' : operandStr;

    return '$operator$operandExpr';
  }
}

/// Represents a function call in the AST.
class FunctionNode extends AstNode {
  /// Creates a function node with the given [name] and [argument].
  FunctionNode(this.name, this.argument, [this.arguments]);

  /// The function name (e.g., 'sin', 'cos', 'ln').
  final String name;

  /// The main argument to the function.
  final AstNode argument;

  /// Additional arguments for functions that take multiple parameters.
  final List<AstNode>? arguments;

  @override
  NumberValue evaluate(Map<String, NumberValue> variables) {
    // This method requires interpreter context for function evaluation.
    // For basic function evaluation without interpreter, we can implement
    // some common functions directly here.
    final argValue = argument.evaluate(variables);

    // Handle built-in mathematical functions that don't require interpreter
    switch (name) {
      case 'abs':
        if (argValue is ComplexValue) {
          final real = argValue.value.real;
          final imag = argValue.value.imaginary;
          return DoubleValue(
            math.sqrt(real * real + imag * imag),
          );
        }
        return DoubleValue((argValue.value as num).abs().toDouble());

      case 'sqrt':
        final numValue = argValue.value as num;
        if (numValue < 0) {
          return ComplexValue(Complex(0, math.sqrt(-numValue)));
        }
        return DoubleValue(math.sqrt(numValue));

      case 'sin':
        return DoubleValue(math.sin(argValue.value as num));
      case 'cos':
        return DoubleValue(math.cos(argValue.value as num));
      case 'tan':
        return DoubleValue(math.tan(argValue.value as num));
      case 'asin':
        final val = argValue.value as num;
        if (val < -1 || val > 1) {
          throw ArgumentError('Arcsine domain error: input must be in [-1, 1]');
        }
        return DoubleValue(math.asin(val));
      case 'acos':
        final val = argValue.value as num;
        if (val < -1 || val > 1) {
          throw ArgumentError(
              'Arccosine domain error: input must be in [-1, 1]');
        }
        return DoubleValue(math.acos(val));
      case 'atan':
        return DoubleValue(math.atan(argValue.value as num));

      case 'ln':
        final val = argValue.value as num;
        if (val <= 0) {
          throw ArgumentError(
              'Natural logarithm undefined for non-positive numbers');
        }
        return DoubleValue(math.log(val));

      case 'exp':
        return DoubleValue(math.exp(argValue.value as num));

      case 'floor':
        if (argValue is ComplexValue) {
          throw ArgumentError('Floor not supported for complex numbers');
        }
        return IntegerValue((argValue.value as num).floor());

      case 'ceil':
        if (argValue is ComplexValue) {
          throw ArgumentError('Ceil not supported for complex numbers');
        }
        return IntegerValue((argValue.value as num).ceil());

      case 'round':
        if (argValue is ComplexValue) {
          throw ArgumentError('Round not supported for complex numbers');
        }
        return IntegerValue((argValue.value as num).round());

      case 'sign':
        if (argValue is ComplexValue) {
          throw ArgumentError('Sign not supported for complex numbers');
        }
        final val = argValue.value as num;
        if (val > 0) return IntegerValue(1);
        if (val < 0) return IntegerValue(-1);
        return IntegerValue(0);

      default:
        throw UnimplementedError(
          'Function $name requires interpreter context for evaluation. '
          'Use SymbolicInterpreter.evaluateAst() instead.',
        );
    }
  }

  @override
  AstNode simplify() {
    final simplifiedArg = argument.simplify();
    final simplifiedArgs = arguments?.map((arg) => arg.simplify()).toList();

    return FunctionNode(name, simplifiedArg, simplifiedArgs);
  }

  @override
  AstNode derivative(String variable) => switch (name) {
        'sin' => BinaryOperationNode(
            '*',
            FunctionNode('cos', argument),
            argument.derivative(variable),
          ),
        'cos' => BinaryOperationNode(
            '*',
            UnaryOperationNode('-', FunctionNode('sin', argument)),
            argument.derivative(variable),
          ),
        'tan' => BinaryOperationNode(
            '*',
            BinaryOperationNode('^', FunctionNode('sec', argument),
                NumberNode(IntegerValue(2))),
            argument.derivative(variable),
          ),
        'sec' => BinaryOperationNode(
            '*',
            BinaryOperationNode(
              '*',
              FunctionNode('sec', argument),
              FunctionNode('tan', argument),
            ),
            argument.derivative(variable),
          ),
        'csc' => BinaryOperationNode(
            '*',
            UnaryOperationNode(
              '-',
              BinaryOperationNode(
                '*',
                FunctionNode('csc', argument),
                FunctionNode('cot', argument),
              ),
            ),
            argument.derivative(variable),
          ),
        'cot' => BinaryOperationNode(
            '*',
            UnaryOperationNode(
              '-',
              BinaryOperationNode('^', FunctionNode('csc', argument),
                  NumberNode(IntegerValue(2))),
            ),
            argument.derivative(variable),
          ),
        'sinh' => BinaryOperationNode(
            '*',
            FunctionNode('cosh', argument),
            argument.derivative(variable),
          ),
        'cosh' => BinaryOperationNode(
            '*',
            FunctionNode('sinh', argument),
            argument.derivative(variable),
          ),
        'tanh' => BinaryOperationNode(
            '*',
            BinaryOperationNode(
              '-',
              NumberNode(IntegerValue(1)),
              BinaryOperationNode('^', FunctionNode('tanh', argument),
                  NumberNode(IntegerValue(2))),
            ),
            argument.derivative(variable),
          ),
        'sech' => BinaryOperationNode(
            '*',
            UnaryOperationNode(
              '-',
              BinaryOperationNode(
                '*',
                FunctionNode('sech', argument),
                FunctionNode('tanh', argument),
              ),
            ),
            argument.derivative(variable),
          ),
        'csch' => BinaryOperationNode(
            '*',
            UnaryOperationNode(
              '-',
              BinaryOperationNode(
                '*',
                FunctionNode('csch', argument),
                FunctionNode('coth', argument),
              ),
            ),
            argument.derivative(variable),
          ),
        'coth' => BinaryOperationNode(
            '*',
            UnaryOperationNode(
              '-',
              BinaryOperationNode('^', FunctionNode('csch', argument),
                  NumberNode(IntegerValue(2))),
            ),
            argument.derivative(variable),
          ),
        'ln' =>
          BinaryOperationNode('/', argument.derivative(variable), argument),
        'exp' => BinaryOperationNode(
            '*',
            FunctionNode('exp', argument),
            argument.derivative(variable),
          ),
        'sqrt' => BinaryOperationNode(
            '/',
            argument.derivative(variable),
            BinaryOperationNode('*', NumberNode(IntegerValue(2)),
                FunctionNode('sqrt', argument)),
          ),
        'abs' => BinaryOperationNode(
            '*',
            FunctionNode('sign', argument),
            argument.derivative(variable),
          ),
        _ =>
          throw ArgumentError('Derivative not implemented for function: $name'),
      };

  @override
  String toExpression() {
    if (arguments != null && arguments!.isNotEmpty) {
      final argStrs = [
        argument.toExpression(),
        ...arguments!.map((arg) => arg.toExpression())
      ];

      return '$name(${argStrs.join(', ')})';
    }

    return '$name(${argument.toExpression()})';
  }
}
