import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('IntegrationEngine.integrate', () {
    late IntegrationEngine engine;

    setUp(() {
      engine = IntegrationEngine();
    });

    test('integrates constant as constant multiplied by variable', () {
      final expression = NumberNode(IntegerValue(3));
      final result = engine.integrate(expression, 'x', simplify: false);

      expect(result, isA<BinaryOperationNode>());
      final product = result as BinaryOperationNode;
      expect(product.operator, '*');
      expect(product.left, same(expression));
      expect(product.right, isA<VariableNode>());
      expect((product.right as VariableNode).name, equals('x'));
    });

    test('integrates complex constant as constant multiplied by variable', () {
      final expression = NumberNode(ComplexValue(const Complex(0, 2)));
      final result = engine.integrate(expression, 'x', simplify: false);

      expect(result, isA<BinaryOperationNode>());
      final product = result as BinaryOperationNode;
      expect(product.operator, '*');
      expect(product.left, same(expression));
      expect(product.right, isA<VariableNode>());
      expect((product.right as VariableNode).name, equals('x'));
    });

    test('integrates variable to power two over two', () {
      final expression = VariableNode('x');
      final result = engine.integrate(expression, 'x', simplify: false);

      expect(result, isA<BinaryOperationNode>());
      final division = result as BinaryOperationNode;
      expect(division.operator, '/');
      expect(division.left, isA<BinaryOperationNode>());
      final power = division.left as BinaryOperationNode;
      expect(power.operator, '^');
      expect(power.left, isA<VariableNode>());
      expect((power.left as VariableNode).name, equals('x'));
      expect(power.right, isA<NumberNode>());
      expect(((power.right as NumberNode).value as IntegerValue).value, 2);
      expect(division.right, isA<NumberNode>());
      expect(((division.right as NumberNode).value as IntegerValue).value, 2);
    });

    test('integrates x to the power of minus one as natural log of absolute',
        () {
      final expression = BinaryOperationNode(
        '^',
        VariableNode('x'),
        NumberNode(IntegerValue(-1)),
      );
      final result = engine.integrate(expression, 'x', simplify: false);

      expect(result, isA<FunctionNode>());
      final ln = result as FunctionNode;
      expect(ln.name, equals('ln'));
      expect(ln.argument, isA<FunctionNode>());
      final abs = ln.argument as FunctionNode;
      expect(abs.name, equals('abs'));
      expect(abs.argument, isA<VariableNode>());
      expect((abs.argument as VariableNode).name, equals('x'));
    });

    test('integrates sum term by term', () {
      final expression = BinaryOperationNode(
        '+',
        BinaryOperationNode(
          '^',
          VariableNode('x'),
          NumberNode(IntegerValue(2)),
        ),
        NumberNode(IntegerValue(5)),
      );

      final result = engine.integrate(expression, 'x', simplify: false);

      expect(result, isA<BinaryOperationNode>());
      final sum = result as BinaryOperationNode;
      expect(sum.operator, '+');
      expect(sum.left, isA<BinaryOperationNode>());
      expect(sum.right, isA<BinaryOperationNode>());
    });

    test('integrates product with constant factor by pulling constant out', () {
      final constant = NumberNode(IntegerValue(3));
      final expression = BinaryOperationNode(
        '*',
        constant,
        FunctionNode('sin', VariableNode('x')),
      );

      final result = engine.integrate(expression, 'x', simplify: false);

      expect(result, isA<BinaryOperationNode>());
      final product = result as BinaryOperationNode;
      expect(product.operator, '*');
      expect(product.left, same(constant));
      expect(product.right, isA<BinaryOperationNode>());
      final division = product.right as BinaryOperationNode;
      expect(division.operator, '/');
      expect(division.left, isA<UnaryOperationNode>());
      final neg = division.left as UnaryOperationNode;
      expect(neg.operator, '-');
      expect(neg.operand, isA<FunctionNode>());
      expect((neg.operand as FunctionNode).name, equals('cos'));
      expect(division.right, isA<NumberNode>());
      expect(((division.right as NumberNode).value as IntegerValue).value, 1);
    });

    test('integrates sine function to negative cosine without simplification',
        () {
      final expression = FunctionNode('sin', VariableNode('x'));
      final result = engine.integrate(expression, 'x', simplify: false);

      expect(result, isA<BinaryOperationNode>());
      final division = result as BinaryOperationNode;
      expect(division.operator, '/');
      expect(division.left, isA<UnaryOperationNode>());
      final neg = division.left as UnaryOperationNode;
      expect(neg.operator, '-');
      expect(neg.operand, isA<FunctionNode>());
      expect((neg.operand as FunctionNode).name, equals('cos'));
      expect((neg.operand as FunctionNode).argument, isA<VariableNode>());
      expect(division.right, isA<NumberNode>());
      expect(((division.right as NumberNode).value as IntegerValue).value, 1);
    });

    test('integrates sine function with simplification enabled', () {
      final expression = FunctionNode('sin', VariableNode('x'));
      final result = engine.integrate(expression, 'x');

      expect(result, isA<UnaryOperationNode>());
      final neg = result as UnaryOperationNode;
      expect(neg.operator, '-');
      expect(neg.operand, isA<FunctionNode>());
      expect((neg.operand as FunctionNode).name, equals('cos'));
    });

    test('integrates ln of constant argument to product with variable', () {
      final constantArgument = NumberNode(IntegerValue(5));
      final expression = FunctionNode('ln', constantArgument);

      final result = engine.integrate(expression, 'x', simplify: false);

      expect(result, isA<BinaryOperationNode>());
      final product = result as BinaryOperationNode;
      expect(product.operator, '*');
      expect(product.left, same(expression));
      expect(product.right, isA<VariableNode>());
      expect((product.right as VariableNode).name, equals('x'));
    });

    test('integrates power of linear expression with constant derivative', () {
      final base = BinaryOperationNode(
        '+',
        BinaryOperationNode(
          '*',
          NumberNode(IntegerValue(2)),
          VariableNode('x'),
        ),
        NumberNode(IntegerValue(3)),
      );

      final expression = BinaryOperationNode(
        '^',
        base,
        NumberNode(IntegerValue(2)),
      );

      final result = engine.integrate(expression, 'x', simplify: false);

      expect(result, isA<BinaryOperationNode>());
      final division = result as BinaryOperationNode;
      expect(division.operator, '/');
      expect(division.left, isA<BinaryOperationNode>());
      final power = division.left as BinaryOperationNode;
      expect(power.operator, '^');
      expect(power.left, same(base));
      expect(power.right, isA<NumberNode>());
      expect(((power.right as NumberNode).value as IntegerValue).value, 3);

      expect(division.right, isA<BinaryOperationNode>());
      final denominator = division.right as BinaryOperationNode;
      expect(denominator.operator, '*');
      expect(denominator.left, isA<NumberNode>());
      expect(((denominator.left as NumberNode).value as IntegerValue).value, 3);
      expect(denominator.right, isA<NumberNode>());
      expect(
          ((denominator.right as NumberNode).value as IntegerValue).value, 2);
    });

    test('integrates reciprocal of linear expression to logarithm', () {
      final base = BinaryOperationNode(
        '+',
        BinaryOperationNode(
          '*',
          NumberNode(IntegerValue(2)),
          VariableNode('x'),
        ),
        NumberNode(IntegerValue(3)),
      );

      final expression = BinaryOperationNode(
        '^',
        base,
        NumberNode(IntegerValue(-1)),
      );

      final result = engine.integrate(expression, 'x', simplify: false);

      expect(result, isA<BinaryOperationNode>());
      final division = result as BinaryOperationNode;
      expect(division.operator, '/');
      expect(division.left, isA<FunctionNode>());
      final ln = division.left as FunctionNode;
      expect(ln.name, equals('ln'));
      expect(ln.argument, isA<FunctionNode>());
      final abs = ln.argument as FunctionNode;
      expect(abs.name, equals('abs'));
      expect(abs.argument, same(base));

      expect(division.right, isA<NumberNode>());
      expect(((division.right as NumberNode).value as IntegerValue).value, 2);
    });

    test('integrates reciprocal of complex linear expression without abs', () {
      final base = BinaryOperationNode(
        '+',
        VariableNode('x'),
        NumberNode(ComplexValue(const Complex(0, 1))),
      );

      final expression = BinaryOperationNode(
        '^',
        base,
        NumberNode(IntegerValue(-1)),
      );

      final result = engine.integrate(expression, 'x', simplify: false);

      expect(result, isA<BinaryOperationNode>());
      final division = result as BinaryOperationNode;
      expect(division.left, isA<FunctionNode>());
      final ln = division.left as FunctionNode;
      expect(ln.name, equals('ln'));
      expect(ln.argument, same(base));

      expect(division.right, isA<NumberNode>());
      expect(
        ((division.right as NumberNode).value as IntegerValue).value,
        equals(1),
      );
    });

    test('throws when expression rule is not implemented', () {
      final expression = BinaryOperationNode(
        '*',
        VariableNode('x'),
        VariableNode('x'),
      );

      expect(
        () => engine.integrate(expression, 'x', simplify: false),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
