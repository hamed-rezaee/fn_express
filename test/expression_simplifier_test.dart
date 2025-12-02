// ignore_for_file: lines_longer_than_80_chars

import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('ExpressionSimplifier', () {
    late ExpressionSimplifier simplifier;

    setUp(() {
      simplifier = ExpressionSimplifier();
    });

    test('simplifies constant addition', () {
      final expr = BinaryOperationNode(
        '+',
        NumberNode(IntegerValue(2)),
        NumberNode(IntegerValue(3)),
      );
      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<NumberNode>());
      expect((simplified as NumberNode).value.value, equals(5));
    });

    test('simplifies x + 0 to x', () {
      final expr = BinaryOperationNode(
        '+',
        VariableNode('x'),
        NumberNode(IntegerValue(0)),
      );
      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<VariableNode>());
    });

    test('simplifies 0 + x to x', () {
      final expr = BinaryOperationNode(
        '+',
        NumberNode(IntegerValue(0)),
        VariableNode('x'),
      );
      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<VariableNode>());
    });

    test('simplifies x * 0 to 0', () {
      final expr = BinaryOperationNode(
        '*',
        VariableNode('x'),
        NumberNode(IntegerValue(0)),
      );
      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<NumberNode>());
      expect((simplified as NumberNode).value.value, equals(0));
    });

    test('simplifies x * 1 to x', () {
      final expr = BinaryOperationNode(
        '*',
        VariableNode('x'),
        NumberNode(IntegerValue(1)),
      );
      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<VariableNode>());
    });

    test('simplifies 1 * x to x', () {
      final expr = BinaryOperationNode(
        '*',
        NumberNode(IntegerValue(1)),
        VariableNode('x'),
      );
      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<VariableNode>());
    });

    test('simplifies complex zero coefficient to zero', () {
      final expr = BinaryOperationNode(
        '*',
        NumberNode(ComplexValue(const Complex(0, 0))),
        VariableNode('x'),
      );

      final simplified = simplifier.simplify(expr);

      expect(simplified, isA<NumberNode>());
      final value = (simplified as NumberNode).value;

      if (value is IntegerValue) {
        expect(value.value, equals(0));
      } else if (value is DoubleValue) {
        expect(value.value, equals(0));
      } else if (value is ComplexValue) {
        expect(value.value.real, equals(0));
        expect(value.value.imaginary, equals(0));
      } else {
        fail(
          'Unexpected number type for zero simplification: ${value.runtimeType}',
        );
      }
    });

    test('simplifies complex unity coefficient to variable', () {
      final expr = BinaryOperationNode(
        '*',
        NumberNode(ComplexValue(const Complex(1, 0))),
        VariableNode('x'),
      );

      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<VariableNode>());
    });

    test('simplifies x ^ 0 to 1', () {
      final expr = BinaryOperationNode(
        '^',
        VariableNode('x'),
        NumberNode(IntegerValue(0)),
      );
      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<NumberNode>());
      expect((simplified as NumberNode).value.value, equals(1));
    });

    test('simplifies x ^ 1 to x', () {
      final expr = BinaryOperationNode(
        '^',
        VariableNode('x'),
        NumberNode(IntegerValue(1)),
      );
      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<VariableNode>());
    });

    test('simplifies x / 1 to x', () {
      final expr = BinaryOperationNode(
        '/',
        VariableNode('x'),
        NumberNode(IntegerValue(1)),
      );
      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<VariableNode>());
    });

    test('simplifies x - x to 0', () {
      final expr = BinaryOperationNode(
        '-',
        VariableNode('x'),
        VariableNode('x'),
      );
      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<NumberNode>());
      expect((simplified as NumberNode).value.value, equals(0));
    });

    test('simplifies x / x to 1', () {
      final expr = BinaryOperationNode(
        '/',
        VariableNode('x'),
        VariableNode('x'),
      );
      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<NumberNode>());
      expect((simplified as NumberNode).value.value, equals(1));
    });

    test('simplifies double negation', () {
      final expr = UnaryOperationNode(
        '-',
        UnaryOperationNode('-', VariableNode('x')),
      );
      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<VariableNode>());
    });

    test('handles complex nested expressions', () {
      final expr = BinaryOperationNode(
        '+',
        BinaryOperationNode(
          '*',
          NumberNode(IntegerValue(0)),
          VariableNode('x'),
        ),
        VariableNode('y'),
      );
      final simplified = simplifier.simplify(expr);
      expect(simplified, isA<VariableNode>());
    });
  });
}
