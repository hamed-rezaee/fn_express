import 'package:fn_express/src/ast_node.dart';
import 'package:fn_express/src/expression_simplifier.dart';
import 'package:fn_express/src/number_value.dart';

/// Provides symbolic integration capabilities for mathematical expressions.
///
/// The integration engine covers common classes of functions including
/// polynomials, exponential functions with linear arguments, and the
/// elementary trigonometric functions. Results are returned as AST nodes
/// so that additional symbolic processing (simplification, differentiation,
/// evaluation) can be performed downstream.
class IntegrationEngine {
  /// Creates a new integration engine.
  IntegrationEngine([ExpressionSimplifier? simplifier])
      : _simplifier = simplifier ?? ExpressionSimplifier();

  final ExpressionSimplifier _simplifier;

  /// Computes the (indefinite) integral of [expression] with respect to
  /// [variable].
  ///
  /// The engine recognises polynomials, exponential functions with linear
  /// arguments, and the basic trigonometric functions. Expressions that fall
  /// outside these categories will throw an [ArgumentError].
  AstNode integrate(
    AstNode expression,
    String variable, {
    bool simplify = true,
  }) {
    final result = _integrate(expression, variable);
    return simplify ? _simplifier.simplify(result) : result;
  }

  AstNode _integrate(AstNode node, String variable) {
    if (_isConstantWithRespectTo(node, variable)) {
      return BinaryOperationNode('*', node, VariableNode(variable));
    }

    if (node is VariableNode) {
      if (node.name == variable) {
        return BinaryOperationNode(
          '/',
          BinaryOperationNode(
            '^',
            VariableNode(variable),
            NumberNode(IntegerValue(2)),
          ),
          NumberNode(IntegerValue(2)),
        );
      }

      return BinaryOperationNode('*', node, VariableNode(variable));
    }

    if (node is BinaryOperationNode) {
      return _integrateBinary(node, variable);
    }

    if (node is UnaryOperationNode) {
      return UnaryOperationNode(
        node.operator,
        _integrate(node.operand, variable),
      );
    }

    if (node is FunctionNode) {
      return _integrateFunction(node, variable);
    }

    throw ArgumentError(
      'Integration not implemented for node type: ${node.runtimeType}',
    );
  }

  AstNode _integrateBinary(BinaryOperationNode node, String variable) {
    switch (node.operator) {
      case '+':
      case '-':
        return BinaryOperationNode(
          node.operator,
          _integrate(node.left, variable),
          _integrate(node.right, variable),
        );
      case '*':
        if (_isConstantWithRespectTo(node.left, variable)) {
          return BinaryOperationNode(
            '*',
            node.left,
            _integrate(node.right, variable),
          );
        }
        if (_isConstantWithRespectTo(node.right, variable)) {
          return BinaryOperationNode(
            '*',
            node.right,
            _integrate(node.left, variable),
          );
        }
      case '/':
        if (_isConstantWithRespectTo(node.right, variable)) {
          return BinaryOperationNode(
            '/',
            _integrate(node.left, variable),
            node.right,
          );
        }
      case '^':
        if (node.left is VariableNode &&
            (node.left as VariableNode).name == variable &&
            node.right is NumberNode) {
          return _integratePower(node.right as NumberNode, variable);
        }

        if (node.right is NumberNode) {
          return _integratePowerWithBase(
            node.left,
            node.right as NumberNode,
            variable,
          );
        }
    }

    throw ArgumentError(
      'Integration rule not implemented for expression: ${node.toExpression()}',
    );
  }

  AstNode _integratePower(NumberNode exponentNode, String variable) {
    return _integratePowerWithBase(
      VariableNode(variable),
      exponentNode,
      variable,
      allowVariableShortcut: true,
    );
  }

  AstNode _integratePowerWithBase(
    AstNode base,
    NumberNode exponentNode,
    String variable, {
    bool allowVariableShortcut = false,
  }) {
    final exponentValue = exponentNode.value;

    if (allowVariableShortcut &&
        base is VariableNode &&
        base.name == variable) {
      final variableNode = VariableNode(variable);

      if (_isMinusOneValue(exponentValue)) {
        return _lnWithComplexAwareArgument(variableNode);
      }

      final incrementValue = exponentValue + IntegerValue(1);
      final newExponentNode = NumberNode(incrementValue);

      return BinaryOperationNode(
        '/',
        BinaryOperationNode('^', variableNode, newExponentNode),
        NumberNode(incrementValue),
      );
    }

    final derivative = _simplifier.simplify(base.derivative(variable));

    if (!_isConstantWithRespectTo(derivative, variable) ||
        _isZeroNode(derivative)) {
      throw ArgumentError(
        'Integration rule not implemented for expression: '
        '${BinaryOperationNode('^', base, exponentNode).toExpression()}',
      );
    }

    if (_isMinusOneValue(exponentValue)) {
      return BinaryOperationNode(
        '/',
        _lnWithComplexAwareArgument(base),
        derivative,
      );
    }

    final incrementValue = exponentValue + IntegerValue(1);
    final incrementNode = NumberNode(incrementValue);

    final numerator = BinaryOperationNode('^', base, incrementNode);

    final denominator = BinaryOperationNode(
      '*',
      NumberNode(incrementValue),
      derivative,
    );

    return BinaryOperationNode('/', numerator, denominator);
  }

  AstNode _integrateFunction(FunctionNode node, String variable) {
    final argument = node.argument;
    final argumentDerivative =
        _simplifier.simplify(argument.derivative(variable));
    final isLinear = _isConstantWithRespectTo(argumentDerivative, variable);

    AstNode scaledResult(AstNode integral) {
      if (!isLinear) return integral;

      if (_isZeroNode(argumentDerivative)) {
        throw ArgumentError(
          'Integration not implemented for ${node.name} with '
          'argument derivative equal to zero.',
        );
      }

      if (argumentDerivative is NumberNode) {
        final coeff = argumentDerivative.value;
        return BinaryOperationNode(
          '/',
          integral,
          NumberNode(coeff),
        );
      }

      return BinaryOperationNode(
        '/',
        integral,
        argumentDerivative,
      );
    }

    switch (node.name) {
      case 'sin':
        return scaledResult(
          UnaryOperationNode('-', FunctionNode('cos', argument)),
        );
      case 'cos':
        return scaledResult(FunctionNode('sin', argument));
      case 'exp':
        return scaledResult(FunctionNode('exp', argument));
      case 'tan':
        return scaledResult(
          UnaryOperationNode(
            '-',
            FunctionNode(
              'ln',
              FunctionNode('abs', FunctionNode('cos', argument)),
            ),
          ),
        );
      case 'cot':
        return scaledResult(
          FunctionNode(
            'ln',
            FunctionNode('abs', FunctionNode('sin', argument)),
          ),
        );
      case 'sec':
        return scaledResult(
          FunctionNode(
            'ln',
            FunctionNode(
              'abs',
              BinaryOperationNode(
                '+',
                FunctionNode('tan', argument),
                FunctionNode('sec', argument),
              ),
            ),
          ),
        );
      case 'csc':
        return scaledResult(
          UnaryOperationNode(
            '-',
            FunctionNode(
              'ln',
              FunctionNode(
                'abs',
                BinaryOperationNode(
                  '+',
                  FunctionNode('csc', argument),
                  FunctionNode('cot', argument),
                ),
              ),
            ),
          ),
        );
      case 'ln':
        if (_isConstantWithRespectTo(argument, variable)) {
          return BinaryOperationNode(
            '*',
            FunctionNode('ln', argument),
            VariableNode(variable),
          );
        }
    }

    throw ArgumentError(
      'Integration rule not implemented for function: ${node.name}',
    );
  }

  bool _isConstantWithRespectTo(AstNode node, String variable) {
    if (node is NumberNode) return true;
    if (node is VariableNode) return node.name != variable;
    if (node is UnaryOperationNode) {
      return _isConstantWithRespectTo(node.operand, variable);
    }
    if (node is BinaryOperationNode) {
      return _isConstantWithRespectTo(node.left, variable) &&
          _isConstantWithRespectTo(node.right, variable);
    }
    if (node is FunctionNode) {
      if (!_containsVariable(node.argument, variable)) {
        return true;
      }
      return false;
    }
    return false;
  }

  bool _containsVariable(AstNode node, String variable) {
    if (node is VariableNode) return node.name == variable;
    if (node is UnaryOperationNode) {
      return _containsVariable(node.operand, variable);
    }
    if (node is BinaryOperationNode) {
      return _containsVariable(node.left, variable) ||
          _containsVariable(node.right, variable);
    }
    if (node is FunctionNode) {
      if (_containsVariable(node.argument, variable)) return true;
      if (node.arguments != null) {
        for (final arg in node.arguments!) {
          if (_containsVariable(arg, variable)) return true;
        }
      }
    }
    return false;
  }

  AstNode _lnWithComplexAwareArgument(AstNode base) {
    final argument =
        _containsComplexConstant(base) ? base : FunctionNode('abs', base);

    return FunctionNode('ln', argument);
  }

  bool _containsComplexConstant(AstNode node) {
    if (node is NumberNode) {
      return node.value is ComplexValue;
    }

    if (node is UnaryOperationNode) {
      return _containsComplexConstant(node.operand);
    }

    if (node is BinaryOperationNode) {
      return _containsComplexConstant(node.left) ||
          _containsComplexConstant(node.right);
    }

    if (node is FunctionNode) {
      if (_containsComplexConstant(node.argument)) {
        return true;
      }

      if (node.arguments != null) {
        for (final arg in node.arguments!) {
          if (_containsComplexConstant(arg)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  bool _isMinusOneValue(NumberValue value) {
    if (value is IntegerValue) {
      return value.value == -1;
    }

    if (value is DoubleValue) {
      return value.value == -1;
    }

    if (value is ComplexValue) {
      return value.value.real == -1 && value.value.imaginary == 0;
    }

    return false;
  }

  bool _isZeroNode(AstNode node) {
    if (node is NumberNode) {
      final value = node.value;

      if (value is IntegerValue) {
        return value.value == 0;
      }

      if (value is DoubleValue) {
        return value.value == 0;
      }

      if (value is ComplexValue) {
        return value.value.real == 0 && value.value.imaginary == 0;
      }
    }

    return false;
  }
}
