import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('Interpreter', () {
    late Interpreter interpreter;

    setUp(() {
      interpreter = Interpreter();
    });

    test('evaluates simple arithmetic', () {
      final result = interpreter.eval('2 + 3');
      expect(result.value, equals(5));
    });

    test('evaluates multiplication and addition', () {
      final result = interpreter.eval('2 + 3 * 4');
      expect(result.value, equals(14));
    });

    test('evaluates with parentheses', () {
      final result = interpreter.eval('(2 + 3) * 4');
      expect(result.value, equals(20));
    });

    test('evaluates exponentiation', () {
      final result = interpreter.eval('2 ^ 3');
      expect(result.value, equals(8));
    });

    test('evaluates division', () {
      final result = interpreter.eval('10 / 2');
      expect(result.value, equals(5));
    });

    test('evaluates modulo', () {
      final result = interpreter.eval('10 % 3');
      expect(result.value, equals(1));
    });

    test('assigns and uses variables', () {
      interpreter.eval('x = 5');
      final result = interpreter.eval('x * 2');
      expect(result.value, equals(10));
    });

    test('evaluates constants', () {
      final result = interpreter.eval('pi');
      expect(result.value, closeTo(3.14159, 0.0001));
    });

    test('evaluates functions', () {
      final result = interpreter.eval('sqrt(16)');
      expect(result.value, equals(4.0));
    });

    test('evaluates sin', () {
      final result = interpreter.eval('sin(0)');
      expect(result.value, equals(0.0));
    });

    test('evaluates complex numbers', () {
      final result = interpreter.eval('complex(3, 4)');
      expect(result, isA<ComplexValue>());
      final complex = result as ComplexValue;
      expect(complex.value.real, equals(3.0));
      expect(complex.value.imaginary, equals(4.0));
    });

    test('evaluates log with base', () {
      final result = interpreter.eval('log(100, 10)');
      expect(result.value, closeTo(2.0, 0.0001));
    });

    test('evaluates max function', () {
      final result = interpreter.eval('max(5, 10)');
      expect(result.value, equals(10));
    });

    test('evaluates min function', () {
      final result = interpreter.eval('min(5, 10)');
      expect(result.value, equals(5));
    });

    test('evaluates pow function', () {
      final result = interpreter.eval('pow(2, 3)');
      expect(result.value, equals(8.0));
    });

    test('evaluates floor', () {
      final result = interpreter.eval('floor(3.7)');
      expect(result.value, equals(3));
    });

    test('evaluates ceil', () {
      final result = interpreter.eval('ceil(3.2)');
      expect(result.value, equals(4));
    });

    test('evaluates abs', () {
      final result = interpreter.eval('abs(-5)');
      expect(result.value, equals(5.0));
    });

    test('evaluates nested expressions', () {
      final result = interpreter.eval('2 * (3 + 4) * 5');
      expect(result.value, equals(70));
    });

    test('handles implicit multiplication', () {
      final result = interpreter.eval('2pi');
      expect(result.value, closeTo(6.28318, 0.0001));
    });
  });
}
