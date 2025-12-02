// ignore_for_file: lines_longer_than_80_chars

import 'package:fn_express/src/ast_node.dart';
import 'package:fn_express/src/number_value.dart';

/// Provides advanced simplification rules for mathematical expressions.
///
/// This class contains sophisticated algebraic simplification rules that go beyond the basic simplifications built into AST nodes.
/// It can handle more complex patterns and multi-step simplifications.
class ExpressionSimplifier {
  /// Creates a new expression simplifier.
  ExpressionSimplifier();

  /// Performs deep simplification on an expression tree.
  ///
  /// This method applies multiple passes of simplification until no further improvements can be made.
  /// It includes advanced rules for:
  /// - Distributive law
  /// - Associative law
  /// - Commutative law
  /// - Trigonometric identities (sin²+cos²=1, tan=sin/cos, etc.)
  /// - Logarithmic rules (product, quotient, power rules)
  /// - Exponential rules (power laws)
  /// - Rational expression simplification
  /// - Common factor extraction
  /// - Polynomial simplification
  ///
  /// Returns a simplified [AstNode] representing the same expression.
  AstNode simplify(AstNode expression) {
    var current = expression;
    AstNode previous;
    var iterations = 0;

    const maxIterations = 15;

    do {
      previous = current;
      current = _applySinglePass(current);
      iterations++;
    } while (current.toExpression() != previous.toExpression() &&
        iterations < maxIterations);

    return current;
  }

  /// Applies a single pass of simplification rules.
  AstNode _applySinglePass(AstNode node) {
    var simplified = node.simplify();

    // Order matters: apply rules from most specific to most general
    simplified = _applyAlgebraicIdentities(simplified);
    simplified = _applyTrigonometricIdentities(simplified);
    simplified = _applyLogarithmicRules(simplified);
    simplified = _applyExponentialRules(simplified);
    simplified = _applyRationalSimplification(simplified);
    simplified = _applyFactorization(simplified);
    simplified = _applyDistributiveLaw(simplified);
    simplified = _applyAssociativeLaw(simplified);
    simplified = _combineTerms(simplified);
    simplified = _factorCommonTerms(simplified);
    simplified = _simplifyNestedOperations(simplified);
    simplified = _applyCommutativeLaw(simplified);
    simplified = _normalizeSubtraction(simplified);
    // Apply combine terms again after normalization to catch any new combinations
    simplified = _combineTerms(simplified);

    return simplified;
  }

  /// Applies basic algebraic identities.
  AstNode _applyAlgebraicIdentities(AstNode node) {
    if (node is BinaryOperationNode) {
      final left = _applyAlgebraicIdentities(node.left);
      final right = _applyAlgebraicIdentities(node.right);

      // x - x = 0
      if (node.operator == '-' && left.toExpression() == right.toExpression()) {
        return NumberNode(IntegerValue(0));
      }

      // x / x = 1
      if (node.operator == '/' &&
          left.toExpression() == right.toExpression() &&
          !_isZero(left)) {
        return NumberNode(IntegerValue(1));
      }

      // x^0 = 1
      if (node.operator == '^' && _isZero(right)) {
        return NumberNode(IntegerValue(1));
      }

      // x^1 = x
      if (node.operator == '^' && _isOne(right)) {
        return left;
      }

      // 0^x = 0 (for x != 0)
      if (node.operator == '^' && _isZero(left) && !_isZero(right)) {
        return NumberNode(IntegerValue(0));
      }

      // 1^x = 1
      if (node.operator == '^' && _isOne(left)) {
        return NumberNode(IntegerValue(1));
      }

      if (left != node.left || right != node.right) {
        return BinaryOperationNode(node.operator, left, right);
      }
    } else if (node is UnaryOperationNode) {
      final operand = _applyAlgebraicIdentities(node.operand);

      // Double negation: -(-x) = x
      if (node.operator == '-' &&
          operand is UnaryOperationNode &&
          operand.operator == '-') {
        return operand.operand;
      }

      if (operand != node.operand) {
        return UnaryOperationNode(node.operator, operand);
      }
    } else if (node is FunctionNode) {
      final arg = _applyAlgebraicIdentities(node.argument);
      final args = node.arguments?.map(_applyAlgebraicIdentities).toList();

      if (arg != node.argument ||
          (args != null && !_listsEqual(args, node.arguments!))) {
        return FunctionNode(node.name, arg, args);
      }
    }

    return node;
  }

  /// Applies the distributive law: a*(b+c) = a*b + a*c
  AstNode _applyDistributiveLaw(AstNode node) {
    if (node is BinaryOperationNode && node.operator == '*') {
      if (node.right is BinaryOperationNode) {
        final rightOp = node.right as BinaryOperationNode;
        if (rightOp.operator == '+') {
          return BinaryOperationNode(
            '+',
            BinaryOperationNode('*', node.left, rightOp.left),
            BinaryOperationNode('*', node.left, rightOp.right),
          ).simplify();
        }
        if (rightOp.operator == '-') {
          return BinaryOperationNode(
            '-',
            BinaryOperationNode('*', node.left, rightOp.left),
            BinaryOperationNode('*', node.left, rightOp.right),
          ).simplify();
        }
      }

      if (node.left is BinaryOperationNode) {
        final leftOp = node.left as BinaryOperationNode;
        if (leftOp.operator == '+') {
          return BinaryOperationNode(
            '+',
            BinaryOperationNode('*', leftOp.left, node.right),
            BinaryOperationNode('*', leftOp.right, node.right),
          ).simplify();
        }
        if (leftOp.operator == '-') {
          return BinaryOperationNode(
            '-',
            BinaryOperationNode('*', leftOp.left, node.right),
            BinaryOperationNode('*', leftOp.right, node.right),
          ).simplify();
        }
      }
    }

    if (node is BinaryOperationNode) {
      final newLeft = _applyDistributiveLaw(node.left);
      final newRight = _applyDistributiveLaw(node.right);
      if (newLeft != node.left || newRight != node.right) {
        return BinaryOperationNode(node.operator, newLeft, newRight);
      }
    } else if (node is UnaryOperationNode) {
      final newOperand = _applyDistributiveLaw(node.operand);
      if (newOperand != node.operand) {
        return UnaryOperationNode(node.operator, newOperand);
      }
    } else if (node is FunctionNode) {
      final newArg = _applyDistributiveLaw(node.argument);
      final newArgs = node.arguments?.map(_applyDistributiveLaw).toList();
      if (newArg != node.argument ||
          (newArgs != null && !_listsEqual(newArgs, node.arguments!))) {
        return FunctionNode(node.name, newArg, newArgs);
      }
    }

    return node;
  }

  /// Applies associative law to group like terms.
  AstNode _applyAssociativeLaw(AstNode node) {
    if (node is BinaryOperationNode &&
        (node.operator == '+' || node.operator == '*')) {
      final terms = _flattenOperation(node, node.operator);
      final grouped = _groupLikeTerms(terms, node.operator);

      return _buildFromTerms(grouped, node.operator);
    }

    if (node is BinaryOperationNode) {
      final newLeft = _applyAssociativeLaw(node.left);
      final newRight = _applyAssociativeLaw(node.right);

      if (newLeft != node.left || newRight != node.right) {
        return BinaryOperationNode(node.operator, newLeft, newRight);
      }
    }

    return node;
  }

  /// Applies basic trigonometric identities.
  AstNode _applyTrigonometricIdentities(AstNode node) {
    // sin²(x) + cos²(x) = 1
    if (node is BinaryOperationNode && node.operator == '+') {
      if (_isPowerOfFunction(node.left, 'sin', 2) &&
          _isPowerOfFunction(node.right, 'cos', 2)) {
        final sinArg = _getArgumentFromPower(node.left);
        final cosArg = _getArgumentFromPower(node.right);

        if (sinArg?.toExpression() == cosArg?.toExpression()) {
          return NumberNode(IntegerValue(1));
        }
      }

      // cos²(x) + sin²(x) = 1 (commutative)
      if (_isPowerOfFunction(node.left, 'cos', 2) &&
          _isPowerOfFunction(node.right, 'sin', 2)) {
        final cosArg = _getArgumentFromPower(node.left);
        final sinArg = _getArgumentFromPower(node.right);

        if (sinArg?.toExpression() == cosArg?.toExpression()) {
          return NumberNode(IntegerValue(1));
        }
      }
    }

    // 1 - sin²(x) = cos²(x)
    if (node is BinaryOperationNode && node.operator == '-') {
      if (_isOne(node.left) && _isPowerOfFunction(node.right, 'sin', 2)) {
        final arg = _getArgumentFromPower(node.right);
        if (arg != null) {
          return BinaryOperationNode(
            '^',
            FunctionNode('cos', arg),
            NumberNode(IntegerValue(2)),
          );
        }
      }

      // 1 - cos²(x) = sin²(x)
      if (_isOne(node.left) && _isPowerOfFunction(node.right, 'cos', 2)) {
        final arg = _getArgumentFromPower(node.right);
        if (arg != null) {
          return BinaryOperationNode(
            '^',
            FunctionNode('sin', arg),
            NumberNode(IntegerValue(2)),
          );
        }
      }
    }

    // tan(x) = sin(x) / cos(x)
    if (node is BinaryOperationNode && node.operator == '/') {
      if (node.left is FunctionNode && node.right is FunctionNode) {
        final leftFunc = node.left as FunctionNode;
        final rightFunc = node.right as FunctionNode;

        if (leftFunc.name == 'sin' && rightFunc.name == 'cos') {
          if (leftFunc.argument.toExpression() ==
              rightFunc.argument.toExpression()) {
            return FunctionNode('tan', leftFunc.argument);
          }
        }
      }
    }

    // sec²(x) - 1 = tan²(x)
    if (node is BinaryOperationNode && node.operator == '-') {
      if (_isPowerOfFunction(node.left, 'sec', 2) && _isOne(node.right)) {
        final arg = _getArgumentFromPower(node.left);
        if (arg != null) {
          return BinaryOperationNode(
            '^',
            FunctionNode('tan', arg),
            NumberNode(IntegerValue(2)),
          );
        }
      }
    }

    // 1 + tan²(x) = sec²(x)
    if (node is BinaryOperationNode && node.operator == '+') {
      if (_isOne(node.left) && _isPowerOfFunction(node.right, 'tan', 2)) {
        final arg = _getArgumentFromPower(node.right);
        if (arg != null) {
          return BinaryOperationNode(
            '^',
            FunctionNode('sec', arg),
            NumberNode(IntegerValue(2)),
          );
        }
      }
    }

    // Recursively apply to children
    if (node is BinaryOperationNode) {
      final newLeft = _applyTrigonometricIdentities(node.left);
      final newRight = _applyTrigonometricIdentities(node.right);

      if (newLeft != node.left || newRight != node.right) {
        return BinaryOperationNode(node.operator, newLeft, newRight);
      }
    } else if (node is UnaryOperationNode) {
      final newOperand = _applyTrigonometricIdentities(node.operand);
      if (newOperand != node.operand) {
        return UnaryOperationNode(node.operator, newOperand);
      }
    } else if (node is FunctionNode) {
      final newArg = _applyTrigonometricIdentities(node.argument);
      final newArgs =
          node.arguments?.map(_applyTrigonometricIdentities).toList();

      if (newArg != node.argument ||
          (newArgs != null && !_listsEqual(newArgs, node.arguments!))) {
        return FunctionNode(node.name, newArg, newArgs);
      }
    }

    return node;
  }

  /// Applies logarithmic rules.
  AstNode _applyLogarithmicRules(AstNode node) {
    if (node is BinaryOperationNode) {
      // ln(a) + ln(b) = ln(a*b)
      if (node.operator == '+' &&
          node.left is FunctionNode &&
          node.right is FunctionNode) {
        final leftFunc = node.left as FunctionNode;
        final rightFunc = node.right as FunctionNode;

        if (leftFunc.name == 'ln' && rightFunc.name == 'ln') {
          return FunctionNode(
            'ln',
            BinaryOperationNode('*', leftFunc.argument, rightFunc.argument),
          );
        }

        if (leftFunc.name == 'log' && rightFunc.name == 'log') {
          return FunctionNode(
            'log',
            BinaryOperationNode('*', leftFunc.argument, rightFunc.argument),
          );
        }
      }

      // ln(a) - ln(b) = ln(a/b)
      if (node.operator == '-' &&
          node.left is FunctionNode &&
          node.right is FunctionNode) {
        final leftFunc = node.left as FunctionNode;
        final rightFunc = node.right as FunctionNode;

        if (leftFunc.name == 'ln' && rightFunc.name == 'ln') {
          return FunctionNode(
            'ln',
            BinaryOperationNode('/', leftFunc.argument, rightFunc.argument),
          );
        }

        if (leftFunc.name == 'log' && rightFunc.name == 'log') {
          return FunctionNode(
            'log',
            BinaryOperationNode('/', leftFunc.argument, rightFunc.argument),
          );
        }
      }

      // n * ln(a) = ln(a^n)
      if (node.operator == '*') {
        if (node.left is NumberNode && node.right is FunctionNode) {
          final rightFunc = node.right as FunctionNode;
          if (rightFunc.name == 'ln') {
            return FunctionNode(
              'ln',
              BinaryOperationNode('^', rightFunc.argument, node.left),
            );
          }
        }

        if (node.right is NumberNode && node.left is FunctionNode) {
          final leftFunc = node.left as FunctionNode;
          if (leftFunc.name == 'ln') {
            return FunctionNode(
              'ln',
              BinaryOperationNode('^', leftFunc.argument, node.right),
            );
          }
        }
      }
    }

    // ln(e^x) = x
    if (node is FunctionNode && node.name == 'ln') {
      if (node.argument is BinaryOperationNode) {
        final arg = node.argument as BinaryOperationNode;
        if (arg.operator == '^' && arg.left is VariableNode) {
          final base = arg.left as VariableNode;
          if (base.name == 'e') {
            return arg.right;
          }
        }
      }
    }

    // e^(ln(x)) = x
    if (node is BinaryOperationNode && node.operator == '^') {
      if (node.left is VariableNode && node.right is FunctionNode) {
        final base = node.left as VariableNode;
        final exp = node.right as FunctionNode;
        if (base.name == 'e' && exp.name == 'ln') {
          return exp.argument;
        }
      }
    }

    // Recursively apply to children
    if (node is BinaryOperationNode) {
      final newLeft = _applyLogarithmicRules(node.left);
      final newRight = _applyLogarithmicRules(node.right);

      if (newLeft != node.left || newRight != node.right) {
        return BinaryOperationNode(node.operator, newLeft, newRight);
      }
    } else if (node is UnaryOperationNode) {
      final newOperand = _applyLogarithmicRules(node.operand);
      if (newOperand != node.operand) {
        return UnaryOperationNode(node.operator, newOperand);
      }
    } else if (node is FunctionNode) {
      final newArg = _applyLogarithmicRules(node.argument);
      final newArgs = node.arguments?.map(_applyLogarithmicRules).toList();

      if (newArg != node.argument ||
          (newArgs != null && !_listsEqual(newArgs, node.arguments!))) {
        return FunctionNode(node.name, newArg, newArgs);
      }
    }

    return node;
  }

  /// Applies exponential rules.
  AstNode _applyExponentialRules(AstNode node) {
    // a^m * a^n = a^(m+n)
    if (node is BinaryOperationNode && node.operator == '*') {
      if (node.left is BinaryOperationNode &&
          node.right is BinaryOperationNode) {
        final leftPow = node.left as BinaryOperationNode;
        final rightPow = node.right as BinaryOperationNode;

        if (leftPow.operator == '^' && rightPow.operator == '^') {
          if (leftPow.left.toExpression() == rightPow.left.toExpression()) {
            return BinaryOperationNode(
              '^',
              leftPow.left,
              BinaryOperationNode('+', leftPow.right, rightPow.right),
            ).simplify();
          }
        }
      }

      // a^m * a = a^(m+1)
      if (node.left is BinaryOperationNode) {
        final leftPow = node.left as BinaryOperationNode;
        if (leftPow.operator == '^' &&
            leftPow.left.toExpression() == node.right.toExpression()) {
          return BinaryOperationNode(
            '^',
            leftPow.left,
            BinaryOperationNode(
                '+', leftPow.right, NumberNode(IntegerValue(1))),
          ).simplify();
        }
      }

      // a * a^m = a^(m+1)
      if (node.right is BinaryOperationNode) {
        final rightPow = node.right as BinaryOperationNode;
        if (rightPow.operator == '^' &&
            rightPow.left.toExpression() == node.left.toExpression()) {
          return BinaryOperationNode(
            '^',
            rightPow.left,
            BinaryOperationNode(
                '+', rightPow.right, NumberNode(IntegerValue(1))),
          ).simplify();
        }
      }
    }

    // a^m / a^n = a^(m-n)
    if (node is BinaryOperationNode && node.operator == '/') {
      if (node.left is BinaryOperationNode &&
          node.right is BinaryOperationNode) {
        final leftPow = node.left as BinaryOperationNode;
        final rightPow = node.right as BinaryOperationNode;

        if (leftPow.operator == '^' && rightPow.operator == '^') {
          if (leftPow.left.toExpression() == rightPow.left.toExpression()) {
            return BinaryOperationNode(
              '^',
              leftPow.left,
              BinaryOperationNode('-', leftPow.right, rightPow.right),
            ).simplify();
          }
        }
      }

      // a^m / a = a^(m-1)
      if (node.left is BinaryOperationNode) {
        final leftPow = node.left as BinaryOperationNode;
        if (leftPow.operator == '^' &&
            leftPow.left.toExpression() == node.right.toExpression()) {
          return BinaryOperationNode(
            '^',
            leftPow.left,
            BinaryOperationNode(
                '-', leftPow.right, NumberNode(IntegerValue(1))),
          ).simplify();
        }
      }

      // a / a^m = a^(1-m)
      if (node.right is BinaryOperationNode) {
        final rightPow = node.right as BinaryOperationNode;
        if (rightPow.operator == '^' &&
            rightPow.left.toExpression() == node.left.toExpression()) {
          return BinaryOperationNode(
            '^',
            rightPow.left,
            BinaryOperationNode(
                '-', NumberNode(IntegerValue(1)), rightPow.right),
          ).simplify();
        }
      }
    }

    // (a^m)^n = a^(m*n)
    if (node is BinaryOperationNode && node.operator == '^') {
      if (node.left is BinaryOperationNode) {
        final innerPow = node.left as BinaryOperationNode;
        if (innerPow.operator == '^') {
          return BinaryOperationNode(
            '^',
            innerPow.left,
            BinaryOperationNode('*', innerPow.right, node.right),
          ).simplify();
        }
      }
    }

    // Recursively apply to children
    if (node is BinaryOperationNode) {
      final newLeft = _applyExponentialRules(node.left);
      final newRight = _applyExponentialRules(node.right);

      if (newLeft != node.left || newRight != node.right) {
        return BinaryOperationNode(node.operator, newLeft, newRight);
      }
    } else if (node is UnaryOperationNode) {
      final newOperand = _applyExponentialRules(node.operand);
      if (newOperand != node.operand) {
        return UnaryOperationNode(node.operator, newOperand);
      }
    } else if (node is FunctionNode) {
      final newArg = _applyExponentialRules(node.argument);
      final newArgs = node.arguments?.map(_applyExponentialRules).toList();

      if (newArg != node.argument ||
          (newArgs != null && !_listsEqual(newArgs, node.arguments!))) {
        return FunctionNode(node.name, newArg, newArgs);
      }
    }

    return node;
  }

  /// Applies polynomial and algebraic factorization patterns.
  ///
  /// This method recognizes and factors common algebraic patterns including:
  /// - Difference of squares: a² - b² = (a+b)(a-b)
  /// - Perfect square trinomials: a² + 2ab + b² = (a+b)²
  /// - Perfect square trinomials: a² - 2ab + b² = (a-b)²
  /// - Sum of cubes: a³ + b³ = (a+b)(a² - ab + b²)
  /// - Difference of cubes: a³ - b³ = (a-b)(a² + ab + b²)
  /// - Simple quadratics: x² + bx + c (when factorable)
  /// - Common monomial factors: extracted in _factorCommonTerms
  AstNode _applyFactorization(AstNode node) {
    // Difference of squares: a² - b²
    if (_isDifferenceOfSquares(node)) {
      return _factorDifferenceOfSquares(node as BinaryOperationNode);
    }

    // Perfect square trinomial: a² ± 2ab + b²
    if (_isPerfectSquareTrinomial(node)) {
      return _factorPerfectSquareTrinomial(node);
    }

    // Difference of cubes: a³ - b³
    if (_isDifferenceOfCubes(node)) {
      return _factorDifferenceOfCubes(node as BinaryOperationNode);
    }

    // Sum of cubes: a³ + b³
    if (_isSumOfCubes(node)) {
      return _factorSumOfCubes(node as BinaryOperationNode);
    }

    // Simple quadratic: x² + bx + c
    if (_isSimpleQuadratic(node)) {
      final factored = _factorSimpleQuadratic(node);
      if (factored != null) return factored;
    }

    // Recursively apply to children
    if (node is BinaryOperationNode) {
      final left = _applyFactorization(node.left);
      final right = _applyFactorization(node.right);

      if (left != node.left || right != node.right) {
        return BinaryOperationNode(node.operator, left, right);
      }
    } else if (node is UnaryOperationNode) {
      final operand = _applyFactorization(node.operand);
      if (operand != node.operand) {
        return UnaryOperationNode(node.operator, operand);
      }
    } else if (node is FunctionNode) {
      final arg = _applyFactorization(node.argument);
      final args = node.arguments?.map(_applyFactorization).toList();

      if (arg != node.argument ||
          (args != null && !_listsEqual(args, node.arguments!))) {
        return FunctionNode(node.name, arg, args);
      }
    }

    return node;
  }

  /// Checks if expression is a difference of squares: a² - b²
  bool _isDifferenceOfSquares(AstNode node) {
    if (node is! BinaryOperationNode || node.operator != '-') return false;

    // Direct squares: x^2 - y^2
    if (_isPowerOf(node.left, 2) && _isPowerOf(node.right, 2)) return true;

    // Higher even powers are also squares: x^4 = (x^2)^2
    if (_isPowerOf(node.left, 4) && _isPowerOf(node.right, 4)) return true;
    if (_isPowerOf(node.left, 6) && _isPowerOf(node.right, 6)) return true;
    if (_isPowerOf(node.left, 8) && _isPowerOf(node.right, 8)) return true;

    return false;
  }

  /// Factors difference of squares: a² - b² = (a+b)(a-b)
  AstNode _factorDifferenceOfSquares(BinaryOperationNode node) {
    var a = _getBase(node.left);
    var b = _getBase(node.right);

    if (a == null || b == null) return node;

    // For x^4, we need to extract x^2 as the base
    if (_isPowerOf(node.left, 4)) {
      final base = _getBase(node.left);
      if (base != null) {
        a = BinaryOperationNode('^', base, NumberNode(IntegerValue(2)));
      }
    }
    if (_isPowerOf(node.right, 4)) {
      final base = _getBase(node.right);
      if (base != null) {
        b = BinaryOperationNode('^', base, NumberNode(IntegerValue(2)));
      }
    }

    // (a + b)(a - b)
    return BinaryOperationNode(
      '*',
      BinaryOperationNode('+', a, b),
      BinaryOperationNode('-', a, b),
    ).simplify();
  }

  /// Checks if expression is a perfect square trinomial
  bool _isPerfectSquareTrinomial(AstNode node) {
    // Pattern: a² ± 2ab + b²
    if (node is! BinaryOperationNode || node.operator != '+') return false;

    // Try to identify the three terms
    final terms = _flattenOperation(node, '+');
    if (terms.length != 3) return false;

    // Look for two perfect squares and one cross term
    var squares = 0;
    var crossTerms = 0;

    for (final term in terms) {
      if (_isPowerOf(term, 2)) {
        squares++;
      } else if (_isCrossTerm(term)) {
        crossTerms++;
      }
    }

    return squares == 2 && crossTerms == 1;
  }

  /// Factors perfect square trinomial
  AstNode _factorPerfectSquareTrinomial(AstNode node) {
    final terms = _flattenOperation(node as BinaryOperationNode, '+');

    // Find the square terms and cross term
    AstNode? a;
    AstNode? b;

    var isNegativeCross = false;

    for (final term in terms) {
      if (_isPowerOf(term, 2)) {
        if (a == null) {
          a = _getBase(term);
        } else {
          b = _getBase(term);
        }
      } else if (_isCrossTerm(term)) {
        // Check if cross term is negative
        if (term is BinaryOperationNode && term.operator == '*') {
          if (term.left is NumberNode) {
            final coeff = term.left as NumberNode;
            final raw = coeff.value.value;
            if (raw is num) {
              isNegativeCross = raw < 0;
            }
          }
        }
      }
    }

    if (a == null || b == null) return node;

    // (a ± b)²
    final binomial = isNegativeCross
        ? BinaryOperationNode('-', a, b)
        : BinaryOperationNode('+', a, b);

    return BinaryOperationNode('^', binomial, NumberNode(IntegerValue(2)))
        .simplify();
  }

  /// Checks if expression is a difference of cubes: a³ - b³
  bool _isDifferenceOfCubes(AstNode node) {
    if (node is! BinaryOperationNode || node.operator != '-') return false;

    return _isPowerOf(node.left, 3) && _isPowerOf(node.right, 3);
  }

  /// Factors difference of cubes: a³ - b³ = (a-b)(a² + ab + b²)
  AstNode _factorDifferenceOfCubes(BinaryOperationNode node) {
    final a = _getBase(node.left);
    final b = _getBase(node.right);

    if (a == null || b == null) return node;

    // (a - b)(a² + ab + b²)
    final factor1 = BinaryOperationNode('-', a, b);
    final factor2 = BinaryOperationNode(
      '+',
      BinaryOperationNode(
          '+',
          BinaryOperationNode('^', a, NumberNode(IntegerValue(2))),
          BinaryOperationNode('*', a, b)),
      BinaryOperationNode('^', b, NumberNode(IntegerValue(2))),
    );

    return BinaryOperationNode('*', factor1, factor2).simplify();
  }

  /// Checks if expression is a sum of cubes: a³ + b³
  bool _isSumOfCubes(AstNode node) {
    if (node is! BinaryOperationNode || node.operator != '+') return false;

    return _isPowerOf(node.left, 3) && _isPowerOf(node.right, 3);
  }

  /// Factors sum of cubes: a³ + b³ = (a+b)(a² - ab + b²)
  AstNode _factorSumOfCubes(BinaryOperationNode node) {
    final a = _getBase(node.left);
    final b = _getBase(node.right);

    if (a == null || b == null) return node;

    // (a + b)(a² - ab + b²)
    final factor1 = BinaryOperationNode('+', a, b);
    final factor2 = BinaryOperationNode(
      '+',
      BinaryOperationNode('^', a, NumberNode(IntegerValue(2))),
      BinaryOperationNode(
        '-',
        BinaryOperationNode('*', a, b),
        BinaryOperationNode('^', b, NumberNode(IntegerValue(2))),
      ),
    );

    return BinaryOperationNode('*', factor1, factor2).simplify();
  }

  /// Checks if expression is a simple quadratic of form x² + bx + c
  bool _isSimpleQuadratic(AstNode node) {
    if (node is! BinaryOperationNode) return false;

    final terms = _flattenAdditionSubtraction(node);
    if (terms.length != 3) return false;

    // Look for x², bx, and constant c
    var hasSquare = false;
    var hasLinear = false;
    var hasConstant = false;

    for (final term in terms) {
      if (_isPowerOf(term, 2)) {
        hasSquare = true;
      } else if (_isLinearTerm(term)) {
        hasLinear = true;
      } else if (term is NumberNode) {
        hasConstant = true;
      }
    }

    return hasSquare && hasLinear && hasConstant;
  }

  /// Attempts to factor simple quadratic x² + bx + c = (x + p)(x + q)
  AstNode? _factorSimpleQuadratic(AstNode node) {
    final terms = _flattenAdditionSubtraction(node as BinaryOperationNode);

    AstNode? variable;
    num? b;
    num? c;

    for (final term in terms) {
      if (_isPowerOf(term, 2)) {
        variable = _getBase(term);
      } else if (_isLinearTerm(term)) {
        final coeff = _extractCoefficient(term);
        if (coeff is NumberNode) {
          final raw = coeff.value.value;
          if (raw is num) {
            b = raw;
          } else {
            return null;
          }
        }
      } else if (term is NumberNode) {
        final raw = term.value.value;
        if (raw is num) {
          c = raw;
        } else {
          return null;
        }
      }
    }

    if (variable == null || b == null || c == null) return null;

    // Find p and q such that p + q = b and p * q = c
    final factors = _findFactorPair(c, b);
    if (factors == null) return null;

    final p = factors.$1;
    final q = factors.$2;

    // (x + p)(x + q)
    final factor1 = BinaryOperationNode(
      '+',
      variable,
      NumberNode(p is int ? IntegerValue(p) : DoubleValue(p.toDouble())),
    );
    final factor2 = BinaryOperationNode(
      '+',
      variable,
      NumberNode(q is int ? IntegerValue(q) : DoubleValue(q.toDouble())),
    );

    return BinaryOperationNode('*', factor1, factor2).simplify();
  }

  /// Finds factor pair (p, q) where p * q = product and p + q = sum
  (num, num)? _findFactorPair(num product, num sum) {
    if (product == 0) return null;

    // Try common factor pairs
    final absProduct = product.abs();
    for (var i = 1; i <= absProduct; i++) {
      if (absProduct % i == 0) {
        final j = absProduct ~/ i;
        final candidates = [
          (i, j),
          (-i, -j),
          (i, -j),
          (-i, j),
        ];

        for (final (p, q) in candidates) {
          if (p * q == product && p + q == sum) {
            return (p, q);
          }
        }
      }
    }

    return null;
  }

  /// Checks if node is raised to a specific power
  bool _isPowerOf(AstNode node, int power) {
    // Explicit power expression: x^2
    if (node is BinaryOperationNode && node.operator == '^') {
      if (node.right is NumberNode) {
        final exp = node.right as NumberNode;
        return exp.value.value == power;
      }
    }

    // Check if number is a perfect power: 4 is 2^2, 8 is 2^3, etc.
    if (node is NumberNode && power > 1) {
      final value = node.value.value;
      if (value is int && value > 0) {
        final root = _nthRoot(value, power);
        if (root != null) {
          return _pow(root, power) == value;
        }
      }
    }

    return false;
  }

  /// Gets the base of a power expression
  AstNode? _getBase(AstNode node) {
    if (node is BinaryOperationNode && node.operator == '^') {
      return node.left;
    }

    // For perfect power numbers, return the root
    if (node is NumberNode) {
      final value = node.value.value;
      if (value is int && value > 0) {
        // Try square root
        final sqrt = _nthRoot(value, 2);
        if (sqrt != null && sqrt * sqrt == value) {
          return NumberNode(IntegerValue(sqrt));
        }
        // Try cube root
        final cbrt = _nthRoot(value, 3);
        if (cbrt != null && cbrt * cbrt * cbrt == value) {
          return NumberNode(IntegerValue(cbrt));
        }
      }
    }

    return node;
  }

  /// Calculates the nth root of a number (returns null if not a perfect root)
  int? _nthRoot(int value, int n) {
    if (value < 0 && n.isEven) return null;
    if (value == 0) return 0;
    if (value == 1) return 1;

    final absValue = value.abs();
    var low = 1;
    var high = absValue;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final midN = _pow(mid, n);

      if (midN == absValue) {
        return value < 0 ? -mid : mid;
      } else if (midN < absValue) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return null;
  }

  /// Calculates base^exponent for integers
  int _pow(int base, int exponent) {
    if (exponent == 0) return 1;
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  /// Checks if term is a cross term like 2ab
  bool _isCrossTerm(AstNode term) {
    if (term is! BinaryOperationNode || term.operator != '*') return false;

    // Look for pattern: coefficient * var1 * var2
    final factors = _getFactors(term);

    // Should have at least 2 variables or a coefficient with 2 variables
    return factors.length >= 2;
  }

  /// Checks if term is a linear term (first degree)
  bool _isLinearTerm(AstNode term) {
    if (term is VariableNode) return true;

    if (term is BinaryOperationNode && term.operator == '*') {
      // Pattern: coefficient * variable
      if (term.left is NumberNode && term.right is VariableNode) return true;
      if (term.right is NumberNode && term.left is VariableNode) return true;
    }

    return false;
  }

  /// Combines like terms in addition and multiplication.
  AstNode _combineTerms(AstNode node) {
    if (node is BinaryOperationNode &&
        (node.operator == '+' || node.operator == '-')) {
      final terms = _flattenAdditionSubtraction(node);

      final groupedTerms = <String, List<AstNode>>{};

      for (final term in terms) {
        final variable = _extractVariable(term);
        final key = variable.toExpression();

        if (!groupedTerms.containsKey(key)) {
          groupedTerms[key] = [];
        }

        groupedTerms[key]!.add(term);
      }

      final combinedTerms = <AstNode>[];

      for (final group in groupedTerms.values) {
        if (group.length == 1) {
          combinedTerms.add(group.first);
        } else {
          var totalCoeff = NumberNode(IntegerValue(0));
          final variable = _extractVariable(group.first);

          for (final term in group) {
            final coeff = _extractCoefficient(term);

            totalCoeff = BinaryOperationNode('+', totalCoeff, coeff).simplify()
                as NumberNode;
          }

          if (_isZeroValue(totalCoeff.value)) {
            continue;
          } else if (_isOneValue(totalCoeff.value) &&
              variable.toExpression() != '1') {
            combinedTerms.add(variable);
          } else if (_isNegativeOneValue(totalCoeff.value) &&
              variable.toExpression() != '1') {
            combinedTerms.add(
              BinaryOperationNode('*', NumberNode(IntegerValue(-1)), variable)
                  .simplify(),
            );
          } else if (variable.toExpression() == '1') {
            // For constants, just add the coefficient directly
            combinedTerms.add(totalCoeff);
          } else {
            combinedTerms
                .add(BinaryOperationNode('*', totalCoeff, variable).simplify());
          }
        }
      }

      return _buildFromTerms(combinedTerms, '+');
    }

    return node;
  }

  /// Applies rational expression simplification.
  AstNode _applyRationalSimplification(AstNode node) {
    if (node is BinaryOperationNode && node.operator == '/') {
      // Cancel common factors in numerator and denominator
      final commonFactor = _findCommonFactor(node.left, node.right);

      if (commonFactor != null && !_isOne(commonFactor)) {
        final newNum = _divideByFactor(node.left, commonFactor);
        final newDenom = _divideByFactor(node.right, commonFactor);

        if (newNum != null && newDenom != null) {
          return BinaryOperationNode('/', newNum, newDenom).simplify();
        }
      }

      // (a/b) / (c/d) = (a*d) / (b*c)
      if (node.left is BinaryOperationNode &&
          node.right is BinaryOperationNode) {
        final leftDiv = node.left as BinaryOperationNode;
        final rightDiv = node.right as BinaryOperationNode;

        if (leftDiv.operator == '/' && rightDiv.operator == '/') {
          return BinaryOperationNode(
            '/',
            BinaryOperationNode('*', leftDiv.left, rightDiv.right),
            BinaryOperationNode('*', leftDiv.right, rightDiv.left),
          ).simplify();
        }
      }
    }

    // Recursively apply to children
    if (node is BinaryOperationNode) {
      final newLeft = _applyRationalSimplification(node.left);
      final newRight = _applyRationalSimplification(node.right);

      if (newLeft != node.left || newRight != node.right) {
        return BinaryOperationNode(node.operator, newLeft, newRight);
      }
    } else if (node is UnaryOperationNode) {
      final newOperand = _applyRationalSimplification(node.operand);
      if (newOperand != node.operand) {
        return UnaryOperationNode(node.operator, newOperand);
      }
    } else if (node is FunctionNode) {
      final newArg = _applyRationalSimplification(node.argument);
      final newArgs =
          node.arguments?.map(_applyRationalSimplification).toList();

      if (newArg != node.argument ||
          (newArgs != null && !_listsEqual(newArgs, node.arguments!))) {
        return FunctionNode(node.name, newArg, newArgs);
      }
    }

    return node;
  }

  /// Factors out common terms from expressions.
  AstNode _factorCommonTerms(AstNode node) {
    if (node is BinaryOperationNode && node.operator == '+') {
      final terms = _flattenOperation(node, '+');

      if (terms.length < 2) return node;

      // Find GCD of all coefficients
      final factors = <AstNode>[];
      for (final term in terms) {
        factors.addAll(_getFactors(term));
      }

      // Find common factors
      final commonFactors = <String, AstNode>{};
      for (final factor in factors) {
        final key = factor.toExpression();
        commonFactors[key] = factor;
      }

      // Check if any factor is common to all terms
      for (final factor in commonFactors.values) {
        if (terms.every((term) => _containsFactor(term, factor))) {
          final factored =
              terms.map((term) => _divideByFactor(term, factor)).toList();

          if (factored.every((t) => t != null)) {
            final inner = _buildFromTerms(factored.cast<AstNode>(), '+');
            return BinaryOperationNode('*', factor, inner).simplify();
          }
        }
      }
    }

    return node;
  }

  /// Simplifies nested operations like (a+b)+c to a+b+c.
  AstNode _simplifyNestedOperations(AstNode node) {
    if (node is BinaryOperationNode) {
      final left = _simplifyNestedOperations(node.left);
      final right = _simplifyNestedOperations(node.right);

      // Flatten nested same operations
      if (node.operator == '+' || node.operator == '*') {
        final terms = _flattenOperation(node, node.operator);
        final simplified = terms.map(_simplifyNestedOperations).toList();

        if (simplified.length > 2 ||
            simplified.any((t) =>
                t.toExpression() !=
                terms[simplified.indexOf(t)].toExpression())) {
          return _buildFromTerms(simplified, node.operator);
        }
      }

      if (left != node.left || right != node.right) {
        return BinaryOperationNode(node.operator, left, right);
      }
    } else if (node is UnaryOperationNode) {
      final operand = _simplifyNestedOperations(node.operand);
      if (operand != node.operand) {
        return UnaryOperationNode(node.operator, operand);
      }
    } else if (node is FunctionNode) {
      final arg = _simplifyNestedOperations(node.argument);
      final args = node.arguments?.map(_simplifyNestedOperations).toList();

      if (arg != node.argument ||
          (args != null && !_listsEqual(args, node.arguments!))) {
        return FunctionNode(node.name, arg, args);
      }
    }

    return node;
  }

  /// Applies commutative law to normalize expressions.
  AstNode _applyCommutativeLaw(AstNode node) {
    if (node is BinaryOperationNode &&
        (node.operator == '+' || node.operator == '*')) {
      // Sort terms for canonical form
      final terms = _flattenOperation(node, node.operator);
      final sorted = _sortTerms(terms);

      if (!_listsEqual(terms, sorted)) {
        return _buildFromTerms(sorted, node.operator);
      }
    }

    // Recursively apply to children
    if (node is BinaryOperationNode) {
      final left = _applyCommutativeLaw(node.left);
      final right = _applyCommutativeLaw(node.right);

      if (left != node.left || right != node.right) {
        return BinaryOperationNode(node.operator, left, right);
      }
    } else if (node is UnaryOperationNode) {
      final operand = _applyCommutativeLaw(node.operand);
      if (operand != node.operand) {
        return UnaryOperationNode(node.operator, operand);
      }
    } else if (node is FunctionNode) {
      final arg = _applyCommutativeLaw(node.argument);
      final args = node.arguments?.map(_applyCommutativeLaw).toList();

      if (arg != node.argument ||
          (args != null && !_listsEqual(args, node.arguments!))) {
        return FunctionNode(node.name, arg, args);
      }
    }

    return node;
  }

  // Helper methods for new functionality

  bool _isZero(AstNode node) {
    if (node is NumberNode) {
      return _isZeroValue(node.value);
    }
    return false;
  }

  bool _isOne(AstNode node) {
    if (node is NumberNode) {
      return _isOneValue(node.value);
    }
    return false;
  }

  bool _isZeroValue(NumberValue value) {
    if (value is ComplexValue) {
      return value.value.real == 0 && value.value.imaginary == 0;
    }

    return _numberValueEquals(value, 0);
  }

  bool _isOneValue(NumberValue value) => _numberValueEquals(value, 1);

  bool _isNegativeOneValue(NumberValue value) => _numberValueEquals(value, -1);

  bool _numberValueEquals(NumberValue value, num real, [num imaginary = 0]) {
    if (value is IntegerValue) {
      return imaginary == 0 && value.value == real;
    }

    if (value is DoubleValue) {
      return imaginary == 0 && value.value == real;
    }

    if (value is ComplexValue) {
      return value.value.real == real && value.value.imaginary == imaginary;
    }

    return false;
  }

  AstNode? _findCommonFactor(AstNode a, AstNode b) {
    if (a.toExpression() == b.toExpression()) {
      return a;
    }

    // Simple case: both are products
    if (a is BinaryOperationNode &&
        b is BinaryOperationNode &&
        a.operator == '*' &&
        b.operator == '*') {
      if (a.left.toExpression() == b.left.toExpression()) {
        return a.left;
      }
      if (a.right.toExpression() == b.right.toExpression()) {
        return a.right;
      }
    }

    return null;
  }

  AstNode? _divideByFactor(AstNode node, AstNode factor) {
    if (node.toExpression() == factor.toExpression()) {
      return NumberNode(IntegerValue(1));
    }

    if (node is BinaryOperationNode && node.operator == '*') {
      if (node.left.toExpression() == factor.toExpression()) {
        return node.right;
      }
      if (node.right.toExpression() == factor.toExpression()) {
        return node.left;
      }
    }

    return null;
  }

  List<AstNode> _getFactors(AstNode node) {
    if (node is BinaryOperationNode && node.operator == '*') {
      return [..._getFactors(node.left), ..._getFactors(node.right)];
    }
    return [node];
  }

  bool _containsFactor(AstNode node, AstNode factor) {
    final factors = _getFactors(node);
    return factors.any((f) => f.toExpression() == factor.toExpression());
  }

  List<AstNode> _sortTerms(List<AstNode> terms) {
    final sorted = List<AstNode>.from(terms)
      ..sort((a, b) {
        final aIsNumber = _extractVariable(a).toExpression() == '1';
        final bIsNumber = _extractVariable(b).toExpression() == '1';

        // Constants come first
        if (aIsNumber && !bIsNumber) return -1;
        if (!aIsNumber && bIsNumber) return 1;

        // Both are numbers or both are not
        if (aIsNumber && bIsNumber) {
          // Sort numbers by their coefficient value
          final aCoeff = _extractCoefficient(a);
          final bCoeff = _extractCoefficient(b);
          return aCoeff.toExpression().compareTo(bCoeff.toExpression());
        }

        // Then sort alphabetically by expression for non-constants
        return a.toExpression().compareTo(b.toExpression());
      });

    return sorted;
  }

  /// Normalizes addition with negative coefficients to subtraction for cleaner output.
  AstNode _normalizeSubtraction(AstNode node) {
    if (node is BinaryOperationNode && node.operator == '+') {
      // Check if right side is a negative term (coefficient of -1)
      if (_isNegativeTerm(node.right)) {
        final positiveRight = _makePositive(node.right);
        return BinaryOperationNode('-', node.left, positiveRight);
      }

      // Handle left side being negative (less common but possible)
      if (_isNegativeTerm(node.left) && !_isNegativeTerm(node.right)) {
        final positiveLeft = _makePositive(node.left);
        return BinaryOperationNode('-', node.right, positiveLeft);
      }

      // Recursively normalize both sides
      final newLeft = _normalizeSubtraction(node.left);
      final newRight = _normalizeSubtraction(node.right);

      if (newLeft != node.left || newRight != node.right) {
        // Re-check after normalization
        if (_isNegativeTerm(newRight)) {
          final positiveRight = _makePositive(newRight);
          return BinaryOperationNode('-', newLeft, positiveRight);
        }
        return BinaryOperationNode(node.operator, newLeft, newRight);
      }
    } else if (node is BinaryOperationNode && node.operator == '-') {
      // Recursively normalize subtraction operands
      final newLeft = _normalizeSubtraction(node.left);
      final newRight = _normalizeSubtraction(node.right);

      if (newLeft != node.left || newRight != node.right) {
        return BinaryOperationNode(node.operator, newLeft, newRight);
      }
    } else if (node is BinaryOperationNode) {
      final newLeft = _normalizeSubtraction(node.left);
      final newRight = _normalizeSubtraction(node.right);

      if (newLeft != node.left || newRight != node.right) {
        return BinaryOperationNode(node.operator, newLeft, newRight);
      }
    } else if (node is UnaryOperationNode) {
      final newOperand = _normalizeSubtraction(node.operand);
      if (newOperand != node.operand) {
        return UnaryOperationNode(node.operator, newOperand);
      }
    } else if (node is FunctionNode) {
      final newArg = _normalizeSubtraction(node.argument);
      final newArgs = node.arguments?.map(_normalizeSubtraction).toList();

      if (newArg != node.argument ||
          (newArgs != null && !_listsEqual(newArgs, node.arguments!))) {
        return FunctionNode(node.name, newArg, newArgs);
      }
    }

    return node;
  }

  /// Checks if a term has a negative coefficient.
  bool _isNegativeTerm(AstNode node) {
    // Direct negative number
    if (node is NumberNode) {
      final value = node.value.value;
      if (value is int) return value < 0;
      if (value is double) return value < 0;
      return false;
    }

    // Multiplication with -1 as coefficient
    if (node is BinaryOperationNode && node.operator == '*') {
      if (node.left is NumberNode) {
        final coeff = node.left as NumberNode;
        final value = coeff.value.value;
        if (value is int) return value < 0;
        if (value is double) return value < 0;
      }
    }

    return false;
  }

  /// Converts a negative term to positive by removing the negative coefficient.
  AstNode _makePositive(AstNode node) {
    // Direct negative number
    if (node is NumberNode) {
      final value = node.value.value;
      if (value is int && value < 0) {
        return NumberNode(IntegerValue(-value));
      }
      if (value is double && value < 0) {
        return NumberNode(DoubleValue(-value));
      }
      return node;
    }

    // Multiplication with negative coefficient
    if (node is BinaryOperationNode && node.operator == '*') {
      if (node.left is NumberNode) {
        final coeff = node.left as NumberNode;
        final value = coeff.value.value;

        if (value is int && value < 0) {
          final positiveCoeff = NumberNode(IntegerValue(-value));
          if (_isOneValue(positiveCoeff.value)) {
            return node.right;
          }
          return BinaryOperationNode('*', positiveCoeff, node.right);
        }
        if (value is double && value < 0) {
          final positiveCoeff = NumberNode(DoubleValue(-value));
          if (_isOneValue(positiveCoeff.value)) {
            return node.right;
          }
          return BinaryOperationNode('*', positiveCoeff, node.right);
        }
      }
    }

    return node;
  }

  List<AstNode> _flattenOperation(AstNode node, String operator) {
    if (node is BinaryOperationNode && node.operator == operator) {
      return [
        ..._flattenOperation(node.left, operator),
        ..._flattenOperation(node.right, operator),
      ];
    }
    return [node];
  }

  List<AstNode> _flattenAdditionSubtraction(AstNode node) {
    if (node is BinaryOperationNode) {
      if (node.operator == '+') {
        return [
          ..._flattenAdditionSubtraction(node.left),
          ..._flattenAdditionSubtraction(node.right),
        ];
      } else if (node.operator == '-') {
        return [
          ..._flattenAdditionSubtraction(node.left),
          ..._flattenAdditionSubtraction(node.right).map(_negateTerm),
        ];
      }
    }
    return [node];
  }

  AstNode _negateTerm(AstNode term) {
    if (term is BinaryOperationNode &&
        term.operator == '*' &&
        term.left is NumberNode) {
      final coeff = term.left as NumberNode;
      final variable = term.right;
      final negatedCoeff = _negateNumber(coeff);

      return BinaryOperationNode('*', negatedCoeff, variable);
    } else if (term is NumberNode) {
      return _negateNumber(term);
    } else {
      return BinaryOperationNode('*', NumberNode(IntegerValue(-1)), term);
    }
  }

  NumberNode _negateNumber(NumberNode number) =>
      NumberNode(number.value.negate());

  List<AstNode> _groupLikeTerms(List<AstNode> terms, String operator) => terms;

  AstNode _buildFromTerms(List<AstNode> terms, String operator) {
    if (terms.isEmpty) {
      return NumberNode(IntegerValue(operator == '+' ? 0 : 1));
    }

    if (terms.length == 1) {
      return terms.first;
    }

    // For addition, handle negative terms as subtraction
    if (operator == '+') {
      var result = terms.first;

      for (var i = 1; i < terms.length; i++) {
        final term = terms[i];

        // Check if this term is negative
        if (_isNegativeTerm(term)) {
          final positiveTerm = _makePositive(term);
          result = BinaryOperationNode('-', result, positiveTerm);
        } else {
          result = BinaryOperationNode('+', result, term);
        }
      }

      return result;
    }

    // For other operators, build normally
    var result = terms.first;

    for (var i = 1; i < terms.length; i++) {
      result = BinaryOperationNode(operator, result, terms[i]);
    }

    return result;
  }

  bool _isPowerOfFunction(AstNode node, String funcName, int power) {
    if (node is BinaryOperationNode && node.operator == '^') {
      if (node.left is FunctionNode && node.right is NumberNode) {
        final func = node.left as FunctionNode;
        final exp = node.right as NumberNode;

        return func.name == funcName && exp.value.value == power;
      }
    }

    return false;
  }

  AstNode? _getArgumentFromPower(AstNode node) {
    if (node is BinaryOperationNode && node.operator == '^') {
      if (node.left is FunctionNode) {
        final func = node.left as FunctionNode;

        return func.argument;
      }
    }

    return null;
  }

  AstNode _extractCoefficient(AstNode term) {
    if (term is BinaryOperationNode && term.operator == '*') {
      if (term.left is NumberNode) {
        return term.left;
      }
    }

    return NumberNode(IntegerValue(1));
  }

  AstNode _extractVariable(AstNode term) {
    if (term is BinaryOperationNode && term.operator == '*') {
      if (term.left is NumberNode) {
        return term.right;
      }
    }

    return term;
  }

  bool _listsEqual(List<AstNode> list1, List<AstNode> list2) {
    if (list1.length != list2.length) return false;
    for (var i = 0; i < list1.length; i++) {
      if (list1[i].toExpression() != list2[i].toExpression()) {
        return false;
      }
    }

    return true;
  }
}
