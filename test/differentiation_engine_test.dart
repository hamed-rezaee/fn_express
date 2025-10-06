import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('DifferentiationEngine', () {
    late DifferentiationEngine engine;

    setUp(() {
      engine = DifferentiationEngine();
    });

    test('differentiates constant to zero', () {
      final expr = NumberNode(IntegerValue(5));
      final derivative = engine.differentiate(expr, 'x');
      expect(derivative, isA<NumberNode>());
      expect((derivative as NumberNode).value.value, equals(0));
    });

    test('differentiates variable to one', () {
      final expr = VariableNode('x');
      final derivative = engine.differentiate(expr, 'x');
      expect(derivative, isA<NumberNode>());
      expect((derivative as NumberNode).value.value, equals(1));
    });

    test('differentiates different variable to zero', () {
      final expr = VariableNode('y');
      final derivative = engine.differentiate(expr, 'x');
      expect(derivative, isA<NumberNode>());
      expect((derivative as NumberNode).value.value, equals(0));
    });

    test('differentiates sum', () {
      final expr = BinaryOperationNode(
        '+',
        VariableNode('x'),
        VariableNode('y'),
      );
      final derivative = engine.differentiate(expr, 'x');
      expect(derivative, isA<AstNode>());
    });

    test('differentiates product using product rule', () {
      final expr = BinaryOperationNode(
        '*',
        VariableNode('x'),
        VariableNode('y'),
      );
      final derivative = engine.differentiate(expr, 'x');
      expect(derivative, isA<VariableNode>());
    });

    test('differentiates quotient using quotient rule', () {
      final expr = BinaryOperationNode(
        '/',
        VariableNode('x'),
        VariableNode('y'),
      );
      final derivative = engine.differentiate(expr, 'x');
      expect(derivative, isA<BinaryOperationNode>());
    });

    test('differentiates power with constant exponent', () {
      final expr = BinaryOperationNode(
        '^',
        VariableNode('x'),
        NumberNode(IntegerValue(2)),
      );
      final derivative = engine.differentiate(expr, 'x');
      expect(derivative, isA<BinaryOperationNode>());
    });

    test('differentiates sin(x)', () {
      final expr = FunctionNode('sin', VariableNode('x'));
      final derivative = engine.differentiate(expr, 'x');
      expect(derivative, isA<FunctionNode>());
    });

    test('differentiates cos(x)', () {
      final expr = FunctionNode('cos', VariableNode('x'));
      final derivative = engine.differentiate(expr, 'x');
      expect(derivative, isA<UnaryOperationNode>());
    });

    test('differentiates log base constant', () {
      final expr = FunctionNode(
        'log',
        VariableNode('x'),
        [NumberNode(IntegerValue(2))],
      );

      final derivative = engine.differentiate(expr, 'x', simplify: false);

      expect(derivative, isA<BinaryOperationNode>());
      final product = derivative as BinaryOperationNode;
      expect(product.operator, '*');

      expect(product.left, isA<BinaryOperationNode>());
      final fraction = product.left as BinaryOperationNode;
      expect(fraction.operator, '/');
      expect(fraction.left, isA<NumberNode>());
      expect((fraction.left as NumberNode).value.value, equals(1));
      expect(fraction.right, isA<BinaryOperationNode>());

      final denominator = fraction.right as BinaryOperationNode;
      expect(denominator.operator, '*');
      expect(denominator.left, isA<VariableNode>());
      expect((denominator.left as VariableNode).name, equals('x'));
      expect(denominator.right, isA<FunctionNode>());

      final lnBase = denominator.right as FunctionNode;
      expect(lnBase.name, equals('ln'));
      expect(lnBase.argument, isA<NumberNode>());
      expect(
        ((lnBase.argument as NumberNode).value as IntegerValue).value,
        equals(2),
      );

      expect(product.right, isA<NumberNode>());
      expect(((product.right as NumberNode).value as IntegerValue).value, 1);
    });

    test('throws when differentiating log with variable base', () {
      final expr = FunctionNode(
        'log',
        VariableNode('x'),
        [VariableNode('x')],
      );

      expect(
        () => engine.differentiate(expr, 'x', simplify: false),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('computes nth derivative', () {
      final expr = BinaryOperationNode(
        '^',
        VariableNode('x'),
        NumberNode(IntegerValue(3)),
      );
      final derivative = engine.nthDerivative(expr, 'x', 2);
      expect(derivative, isA<AstNode>());
    });

    test('computes partial derivative', () {
      final expr = BinaryOperationNode(
        '*',
        VariableNode('x'),
        VariableNode('y'),
      );
      final derivative = engine.partialDerivative(expr, 'x');
      expect(derivative, isA<AstNode>());
    });

    test('computes gradient', () {
      final expr = BinaryOperationNode(
        '+',
        BinaryOperationNode(
          '^',
          VariableNode('x'),
          NumberNode(IntegerValue(2)),
        ),
        BinaryOperationNode(
          '^',
          VariableNode('y'),
          NumberNode(IntegerValue(2)),
        ),
      );
      final gradient = engine.gradient(expr, ['x', 'y']);
      expect(gradient, hasLength(2));
      expect(gradient, contains('x'));
      expect(gradient, contains('y'));
    });

    test('differentiates complex-scaled variable', () {
      final expression = BinaryOperationNode(
        '*',
        NumberNode(ComplexValue(const Complex(0, 1))),
        VariableNode('x'),
      );

      final derivative = engine.differentiate(expression, 'x');

      expect(derivative, isA<NumberNode>());
      final value = (derivative as NumberNode).value as ComplexValue;
      expect(value.value.real, equals(0));
      expect(value.value.imaginary, equals(1));
    });
  });
}
