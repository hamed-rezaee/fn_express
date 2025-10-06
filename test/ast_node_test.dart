import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('NumberNode', () {
    test('evaluates to its value', () {
      final node = NumberNode(IntegerValue(42));
      final result = node.evaluate({});
      expect(result.value, equals(42));
    });

    test('simplify returns itself', () {
      final node = NumberNode(DoubleValue(3.14));
      final simplified = node.simplify();
      expect(simplified, equals(node));
    });

    test('derivative is zero', () {
      final node = NumberNode(IntegerValue(5));
      final derivative = node.derivative('x');
      expect(derivative, isA<NumberNode>());
      expect((derivative as NumberNode).value.value, equals(0));
    });

    test('toExpression returns string representation', () {
      final node = NumberNode(IntegerValue(10));
      expect(node.toExpression(), equals('10'));
    });
  });

  group('VariableNode', () {
    test('evaluates using variable context', () {
      final node = VariableNode('x');
      final variables = {'x': IntegerValue(5)};
      final result = node.evaluate(variables);
      expect(result.value, equals(5));
    });

    test('throws on undefined variable', () {
      final node = VariableNode('y');
      expect(() => node.evaluate({}), throwsArgumentError);
    });

    test('simplify returns itself', () {
      final node = VariableNode('x');
      final simplified = node.simplify();
      expect(simplified, equals(node));
    });

    test('derivative with respect to same variable is 1', () {
      final node = VariableNode('x');
      final derivative = node.derivative('x');
      expect(derivative, isA<NumberNode>());
      expect((derivative as NumberNode).value.value, equals(1));
    });

    test('derivative with respect to different variable is 0', () {
      final node = VariableNode('x');
      final derivative = node.derivative('y');
      expect(derivative, isA<NumberNode>());
      expect((derivative as NumberNode).value.value, equals(0));
    });

    test('toExpression returns variable name', () {
      final node = VariableNode('alpha');
      expect(node.toExpression(), equals('alpha'));
    });
  });

  group('BinaryOperationNode - Evaluation', () {
    test('addition', () {
      final node = BinaryOperationNode(
        '+',
        NumberNode(IntegerValue(2)),
        NumberNode(IntegerValue(3)),
      );
      final result = node.evaluate({});
      expect(result.value, equals(5));
    });

    test('subtraction', () {
      final node = BinaryOperationNode(
        '-',
        NumberNode(IntegerValue(10)),
        NumberNode(IntegerValue(3)),
      );
      final result = node.evaluate({});
      expect(result.value, equals(7));
    });

    test('multiplication', () {
      final node = BinaryOperationNode(
        '*',
        NumberNode(IntegerValue(4)),
        NumberNode(IntegerValue(5)),
      );
      final result = node.evaluate({});
      expect(result.value, equals(20));
    });

    test('division', () {
      final node = BinaryOperationNode(
        '/',
        NumberNode(IntegerValue(10)),
        NumberNode(IntegerValue(2)),
      );
      final result = node.evaluate({});
      expect(result.value, equals(5));
    });

    test('exponentiation', () {
      final node = BinaryOperationNode(
        '^',
        NumberNode(IntegerValue(2)),
        NumberNode(IntegerValue(3)),
      );
      final result = node.evaluate({});
      expect(result.value, equals(8));
    });

    test('modulo', () {
      final node = BinaryOperationNode(
        '%',
        NumberNode(IntegerValue(10)),
        NumberNode(IntegerValue(3)),
      );
      final result = node.evaluate({});
      expect(result.value, equals(1));
    });
  });

  group('BinaryOperationNode - Simplification', () {
    test('simplifies addition with zero', () {
      final node = BinaryOperationNode(
        '+',
        NumberNode(IntegerValue(0)),
        VariableNode('x'),
      );
      final simplified = node.simplify();
      expect(simplified, isA<VariableNode>());
    });

    test('simplifies multiplication by zero', () {
      final node = BinaryOperationNode(
        '*',
        VariableNode('x'),
        NumberNode(IntegerValue(0)),
      );
      final simplified = node.simplify();
      expect(simplified, isA<NumberNode>());
      expect((simplified as NumberNode).value.value, equals(0));
    });

    test('simplifies multiplication by one', () {
      final node = BinaryOperationNode(
        '*',
        VariableNode('x'),
        NumberNode(IntegerValue(1)),
      );
      final simplified = node.simplify();
      expect(simplified, isA<VariableNode>());
    });

    test('simplifies power of zero', () {
      final node = BinaryOperationNode(
        '^',
        VariableNode('x'),
        NumberNode(IntegerValue(0)),
      );
      final simplified = node.simplify();
      expect(simplified, isA<NumberNode>());
      expect((simplified as NumberNode).value.value, equals(1));
    });

    test('simplifies power of one', () {
      final node = BinaryOperationNode(
        '^',
        VariableNode('x'),
        NumberNode(IntegerValue(1)),
      );
      final simplified = node.simplify();
      expect(simplified, isA<VariableNode>());
    });

    test('simplifies constant expressions', () {
      final node = BinaryOperationNode(
        '+',
        NumberNode(IntegerValue(2)),
        NumberNode(IntegerValue(3)),
      );
      final simplified = node.simplify();
      expect(simplified, isA<NumberNode>());
      expect((simplified as NumberNode).value.value, equals(5));
    });
  });

  group('BinaryOperationNode - Differentiation', () {
    test('derivative of sum', () {
      // d/dx(x + 5) = 1
      final node = BinaryOperationNode(
        '+',
        VariableNode('x'),
        NumberNode(IntegerValue(5)),
      );
      final derivative = node.derivative('x');
      expect(derivative, isA<BinaryOperationNode>());
    });

    test('derivative of difference', () {
      // d/dx(x - y) = 1
      final node = BinaryOperationNode(
        '-',
        VariableNode('x'),
        VariableNode('y'),
      );
      final derivative = node.derivative('x');
      expect(derivative, isA<BinaryOperationNode>());
    });

    test('derivative of product uses product rule', () {
      // d/dx(x * y)
      final node = BinaryOperationNode(
        '*',
        VariableNode('x'),
        VariableNode('y'),
      );
      final derivative = node.derivative('x');
      expect(derivative, isA<BinaryOperationNode>());
      expect((derivative as BinaryOperationNode).operator, equals('+'));
    });

    test('derivative of quotient uses quotient rule', () {
      // d/dx(x / y)
      final node = BinaryOperationNode(
        '/',
        VariableNode('x'),
        VariableNode('y'),
      );
      final derivative = node.derivative('x');
      expect(derivative, isA<BinaryOperationNode>());
      expect((derivative as BinaryOperationNode).operator, equals('/'));
    });

    test('derivative of power with constant exponent', () {
      // d/dx(x^2) = 2*x^1
      final node = BinaryOperationNode(
        '^',
        VariableNode('x'),
        NumberNode(IntegerValue(2)),
      );
      final derivative = node.derivative('x');
      expect(derivative, isA<BinaryOperationNode>());
    });
  });

  group('UnaryOperationNode', () {
    test('negation evaluates correctly', () {
      final node = UnaryOperationNode(
        '-',
        NumberNode(IntegerValue(5)),
      );
      final result = node.evaluate({});
      expect(result.value, equals(-5));
    });

    test('positive unary operation', () {
      final node = UnaryOperationNode(
        '+',
        NumberNode(IntegerValue(5)),
      );
      final result = node.evaluate({});
      expect(result.value, equals(5));
    });

    test('simplifies double negation', () {
      final node = UnaryOperationNode(
        '-',
        UnaryOperationNode('-', VariableNode('x')),
      );
      final simplified = node.simplify();
      expect(simplified, isA<VariableNode>());
    });

    test('derivative of negation', () {
      // d/dx(-x) = -1
      final node = UnaryOperationNode('-', VariableNode('x'));
      final derivative = node.derivative('x');
      expect(derivative, isA<UnaryOperationNode>());
    });

    test('toExpression with parentheses', () {
      final node = UnaryOperationNode(
        '-',
        BinaryOperationNode(
          '+',
          VariableNode('x'),
          NumberNode(IntegerValue(1)),
        ),
      );
      final expr = node.toExpression();
      expect(expr, contains('-'));
      expect(expr, contains('('));
    });
  });

  group('FunctionNode', () {
    test('evaluates sqrt', () {
      final node = FunctionNode('sqrt', NumberNode(IntegerValue(16)));
      final result = node.evaluate({});
      expect(result.value, equals(4.0));
    });

    test('evaluates sin', () {
      final node = FunctionNode('sin', NumberNode(IntegerValue(0)));
      final result = node.evaluate({});
      expect(result.value, equals(0.0));
    });

    test('evaluates abs', () {
      final node = FunctionNode('abs', NumberNode(IntegerValue(-5)));
      final result = node.evaluate({});
      expect(result.value, equals(5.0));
    });

    test('evaluates ln', () {
      final node = FunctionNode('ln', NumberNode(DoubleValue(2.71828)));
      final result = node.evaluate({});
      expect(result.value, closeTo(1.0, 0.001));
    });

    test('derivative of sin', () {
      // d/dx(sin(x)) = cos(x)
      final node = FunctionNode('sin', VariableNode('x'));
      final derivative = node.derivative('x');
      expect(derivative, isA<BinaryOperationNode>());
    });

    test('derivative of cos', () {
      // d/dx(cos(x)) = -sin(x)
      final node = FunctionNode('cos', VariableNode('x'));
      final derivative = node.derivative('x');
      expect(derivative, isA<BinaryOperationNode>());
    });

    test('derivative of ln', () {
      // d/dx(ln(x)) = 1/x
      final node = FunctionNode('ln', VariableNode('x'));
      final derivative = node.derivative('x');
      expect(derivative, isA<BinaryOperationNode>());
      expect((derivative as BinaryOperationNode).operator, equals('/'));
    });

    test('toExpression with single argument', () {
      final node = FunctionNode('sin', VariableNode('x'));
      expect(node.toExpression(), equals('sin(x)'));
    });

    test('toExpression with multiple arguments', () {
      final node = FunctionNode(
        'complex',
        NumberNode(IntegerValue(2)),
        [NumberNode(IntegerValue(3))],
      );
      expect(node.toExpression(), equals('complex(2, 3)'));
    });
  });
}
