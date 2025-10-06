import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('SymbolicInterpreter', () {
    late SymbolicInterpreter interpreter;

    setUp(() {
      interpreter = SymbolicInterpreter();
    });

    test('evaluates expressions', () {
      final result = interpreter.eval('2 + 3');
      expect(result.value, equals(5));
    });

    test('parses expression to AST', () {
      final ast = interpreter.parse('x + 1');
      expect(ast, isA<BinaryOperationNode>());
    });

    test('simplifies constant expressions', () {
      final result = interpreter.simplify('2 + 3');
      expect(result, equals('5'));
    });

    test('simplifies x + 0', () {
      final result = interpreter.simplify('x + 0');
      expect(result, equals('x'));
    });

    test('simplifies x * 0', () {
      final result = interpreter.simplify('x * 0');
      expect(result, equals('0'));
    });

    test('simplifies x * 1', () {
      final result = interpreter.simplify('x * 1');
      expect(result, equals('x'));
    });

    test('computes derivative of x', () {
      final result = interpreter.derivative('x', 'x');
      expect(result, equals('1'));
    });

    test('computes derivative of constant', () {
      final result = interpreter.derivative('5', 'x');
      expect(result, equals('0'));
    });

    test('computes derivative of x^2', () {
      final result = interpreter.derivative('x ^ 2', 'x');
      expect(result, contains('2'));
      expect(result, contains('x'));
    });

    test('computes derivative of sin(x)', () {
      final result = interpreter.derivative('sin(x)', 'x');
      expect(result, contains('cos'));
    });

    test('computes second derivative', () {
      final result = interpreter.nthDerivative('x ^ 3', 'x', 2);
      expect(result, isNotEmpty);
    });

    test('computes gradient', () {
      final result = interpreter.gradient('x * y', ['x', 'y']);
      expect(result, contains('x'));
      expect(result, contains('y'));
    });

    test('sets and retrieves variables', () {
      interpreter.setVariable('x', IntegerValue(5));
      final result = interpreter.eval('x * 2');
      expect(result.value, equals(10));
    });

    test('evaluates AST directly', () {
      final ast = NumberNode(IntegerValue(42));
      final result = interpreter.evaluateAst(ast);
      expect(result.value, equals(42));
    });

    test('interpolates linearly via interpolation engine wrapper', () {
      final result = interpreter.interpolateLinear(
        [
          Tuple2(0, 0),
          Tuple2(10, 20),
        ],
        2.5,
      );

      expect(result.value, equals(5));
    });

    test('extrapolates linearly via interpolation engine wrapper', () {
      final result = interpreter.extrapolateLinear(
        [
          Tuple2(0, 0),
          Tuple2(10, 20),
        ],
        15,
      );

      expect(result.value, equals(30));
    });

    test('symbolic interpolation rejects out-of-range input without flag', () {
      expect(
        () => interpreter.interpolateLinear(
          [
            Tuple2(0, 0),
            Tuple2(10, 20),
          ],
          25,
        ),
        throwsRangeError,
      );
    });
  });
}
