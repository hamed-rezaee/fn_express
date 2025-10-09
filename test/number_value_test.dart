import 'dart:math' as math;

import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('IntegerValue', () {
    test('creates with integer value', () {
      final num = IntegerValue(42);
      expect(num.value, equals(42));
    });

    test('addition with another IntegerValue', () {
      final num1 = IntegerValue(5);
      final num2 = IntegerValue(3);
      final result = num1 + num2;
      expect(result, isA<IntegerValue>());
      expect(result.value, equals(8));
    });

    test('addition with DoubleValue', () {
      final num1 = IntegerValue(5);
      final num2 = DoubleValue(3.5);
      final result = num1 + num2;
      expect(result, isA<DoubleValue>());
      expect(result.value, equals(8.5));
    });

    test('subtraction with another IntegerValue', () {
      final num1 = IntegerValue(10);
      final num2 = IntegerValue(3);
      final result = num1 - num2;
      expect(result, isA<IntegerValue>());
      expect(result.value, equals(7));
    });

    test('multiplication with another IntegerValue', () {
      final num1 = IntegerValue(4);
      final num2 = IntegerValue(5);
      final result = num1 * num2;
      expect(result, isA<IntegerValue>());
      expect(result.value, equals(20));
    });

    test('multiplication with DoubleValue', () {
      final num1 = IntegerValue(3);
      final num2 = DoubleValue(2.5);
      final result = num1 * num2;
      expect(result, isA<DoubleValue>());
      expect(result.value, equals(7.5));
    });

    test('division resulting in integer', () {
      final num1 = IntegerValue(10);
      final num2 = IntegerValue(2);
      final result = num1 / num2;
      expect(result, isA<IntegerValue>());
      expect(result.value, equals(5));
    });

    test('division resulting in double', () {
      final num1 = IntegerValue(5);
      final num2 = IntegerValue(2);
      final result = num1 / num2;
      expect(result, isA<DoubleValue>());
      expect(result.value, equals(2.5));
    });

    test('division by zero throws error', () {
      final num1 = IntegerValue(5);
      final num2 = IntegerValue(0);
      expect(() => num1 / num2, throwsArgumentError);
    });

    test('modulo operation with integer', () {
      final num1 = IntegerValue(10);
      final num2 = IntegerValue(3);
      final result = num1.modulo(num2);
      expect(result, isA<IntegerValue>());
      expect(result.value, equals(1));
    });

    test('modulo operation with double', () {
      final num1 = IntegerValue(10);
      final num2 = DoubleValue(3.5);
      final result = num1.modulo(num2);
      expect(result, isA<DoubleValue>());
      expect(result.value, closeTo(3.0, 0.0001));
    });

    test('modulo by zero throws error', () {
      final num1 = IntegerValue(5);
      final num2 = IntegerValue(0);
      expect(() => num1.modulo(num2), throwsArgumentError);
    });

    test('power with integer exponent', () {
      final num1 = IntegerValue(2);
      final num2 = IntegerValue(3);
      final result = num1.power(num2);
      expect(result, isA<IntegerValue>());
      expect(result.value, equals(8));
    });

    test('power with non-integer result', () {
      final num1 = IntegerValue(2);
      final num2 = DoubleValue(0.5);
      final result = num1.power(num2);
      expect(result, isA<DoubleValue>());
      expect(result.value, closeTo(math.sqrt(2), 0.0001));
    });

    test('power with fractional exponent on negative base returns complex', () {
      final num1 = IntegerValue(-4);
      final num2 = DoubleValue(0.5);
      final result = num1.power(num2);

      expect(result, isA<ComplexValue>());
      final complex = result as ComplexValue;
      expect(complex.value.real.abs(), lessThan(1e-10));
      expect(complex.value.imaginary, closeTo(2, 1e-10));
    });

    test('negation', () {
      final num = IntegerValue(5);
      final result = num.negate();
      expect(result, isA<IntegerValue>());
      expect(result.value, equals(-5));
    });

    test('toString returns string representation', () {
      final num = IntegerValue(42);
      expect(num.toString(), equals('42'));
    });

    test('negative integer operations', () {
      final num1 = IntegerValue(-5);
      final num2 = IntegerValue(3);
      final result = num1 + num2;
      expect(result.value, equals(-2));
    });

    test('zero value operations', () {
      final num1 = IntegerValue(0);
      final num2 = IntegerValue(5);
      expect((num1 + num2).value, equals(5));
      expect((num1 * num2).value, equals(0));
    });
  });

  group('DoubleValue', () {
    test('creates with double value', () {
      final num = DoubleValue(3.14);
      expect(num.value, equals(3.14));
    });

    test('addition with another DoubleValue', () {
      final num1 = DoubleValue(2.5);
      final num2 = DoubleValue(1.5);
      final result = num1 + num2;
      expect(result, isA<DoubleValue>());
      expect(result.value, equals(4.0));
    });

    test('addition with IntegerValue', () {
      final num1 = DoubleValue(2.5);
      final num2 = IntegerValue(3);
      final result = num1 + num2;
      expect(result, isA<DoubleValue>());
      expect(result.value, equals(5.5));
    });

    test('subtraction', () {
      final num1 = DoubleValue(5.5);
      final num2 = DoubleValue(2.3);
      final result = num1 - num2;
      expect(result, isA<DoubleValue>());
      expect(result.value, closeTo(3.2, 0.0001));
    });

    test('multiplication', () {
      final num1 = DoubleValue(2.5);
      final num2 = DoubleValue(4);
      final result = num1 * num2;
      expect(result, isA<DoubleValue>());
      expect(result.value, equals(10.0));
    });

    test('division', () {
      final num1 = DoubleValue(10);
      final num2 = DoubleValue(4);
      final result = num1 / num2;
      expect(result, isA<DoubleValue>());
      expect(result.value, equals(2.5));
    });

    test('division by zero throws error', () {
      final num1 = DoubleValue(5);
      final num2 = DoubleValue(0);
      expect(() => num1 / num2, throwsArgumentError);
    });

    test('modulo operation', () {
      final num1 = DoubleValue(10.5);
      final num2 = DoubleValue(3);
      final result = num1.modulo(num2);
      expect(result, isA<DoubleValue>());
      expect(result.value, closeTo(1.5, 0.0001));
    });

    test('modulo by zero throws error', () {
      final num1 = DoubleValue(5);
      final num2 = DoubleValue(0);
      expect(() => num1.modulo(num2), throwsArgumentError);
    });

    test('power operation', () {
      final num1 = DoubleValue(2);
      final num2 = DoubleValue(3);
      final result = num1.power(num2);
      expect(result, isA<DoubleValue>());
      expect(result.value, equals(8.0));
    });

    test('power with fractional exponent on negative base returns complex', () {
      final num1 = DoubleValue(-9);
      final num2 = DoubleValue(0.5);
      final result = num1.power(num2);

      expect(result, isA<ComplexValue>());
      final complex = result as ComplexValue;
      expect(complex.value.real.abs(), lessThan(1e-10));
      expect(complex.value.imaginary, closeTo(3, 1e-10));
    });

    test('negation', () {
      final num = DoubleValue(3.14);
      final result = num.negate();
      expect(result, isA<DoubleValue>());
      expect(result.value, equals(-3.14));
    });

    test('toString returns string representation', () {
      final num = DoubleValue(3.14);
      expect(num.toString(), equals('3.14'));
    });

    test('operations with ComplexValue', () {
      final num1 = DoubleValue(2);
      final num2 = ComplexValue(const Complex(3, 4));
      final result = num1 + num2;
      expect(result, isA<ComplexValue>());
      final complexResult = result as ComplexValue;
      expect(complexResult.value.real, equals(5.0));
      expect(complexResult.value.imaginary, equals(4.0));
    });
  });

  group('ComplexValue', () {
    test('creates with complex value', () {
      final complex = ComplexValue(const Complex(3, 4));
      expect(complex.value.real, equals(3.0));
      expect(complex.value.imaginary, equals(4.0));
    });

    test('factory constructor from ComplexValue', () {
      final original = ComplexValue(const Complex(2, 3));
      final result = ComplexValue.from(original);
      expect(result, equals(original));
    });

    test('factory constructor from DoubleValue', () {
      final double = DoubleValue(5);
      final result = ComplexValue.from(double);
      expect(result.value.real, equals(5.0));
      expect(result.value.imaginary, equals(0.0));
    });

    test('factory constructor from IntegerValue', () {
      final integer = IntegerValue(7);
      final result = ComplexValue.from(integer);
      expect(result.value.real, equals(7.0));
      expect(result.value.imaginary, equals(0.0));
    });

    test('addition with another ComplexValue', () {
      final num1 = ComplexValue(const Complex(2, 3));
      final num2 = ComplexValue(const Complex(1, 4));
      final result = num1 + num2;
      expect(result, isA<ComplexValue>());
      final complexResult = result as ComplexValue;
      expect(complexResult.value.real, equals(3.0));
      expect(complexResult.value.imaginary, equals(7.0));
    });

    test('addition with DoubleValue', () {
      final num1 = ComplexValue(const Complex(2, 3));
      final num2 = DoubleValue(5);
      final result = num1 + num2;
      expect(result, isA<ComplexValue>());
      final complexResult = result as ComplexValue;
      expect(complexResult.value.real, equals(7.0));
      expect(complexResult.value.imaginary, equals(3.0));
    });

    test('subtraction', () {
      final num1 = ComplexValue(const Complex(5, 7));
      final num2 = ComplexValue(const Complex(2, 3));
      final result = num1 - num2;
      expect(result, isA<ComplexValue>());
      final complexResult = result as ComplexValue;
      expect(complexResult.value.real, equals(3.0));
      expect(complexResult.value.imaginary, equals(4.0));
    });

    test('multiplication', () {
      final num1 = ComplexValue(const Complex(2, 3));
      final num2 = ComplexValue(const Complex(1, 4));
      final result = num1 * num2;
      expect(result, isA<ComplexValue>());
      final complexResult = result as ComplexValue;
      expect(complexResult.value.real, equals(-10.0));
      expect(complexResult.value.imaginary, equals(11.0));
    });

    test('division', () {
      final num1 = ComplexValue(const Complex(2, 4));
      final num2 = ComplexValue(const Complex(1, 1));
      final result = num1 / num2;
      expect(result, isA<ComplexValue>());
      final complexResult = result as ComplexValue;
      expect(complexResult.value.real, equals(3.0));
      expect(complexResult.value.imaginary, equals(1.0));
    });

    test('division by zero throws error', () {
      final num1 = ComplexValue(const Complex(2, 3));
      final num2 = ComplexValue(const Complex(0, 0));
      expect(() => num1 / num2, throwsArgumentError);
    });

    test('modulo throws error', () {
      final num1 = ComplexValue(const Complex(2, 3));
      final num2 = ComplexValue(const Complex(1, 1));
      expect(() => num1.modulo(num2), throwsArgumentError);
    });

    test('power with real exponent', () {
      final num1 = ComplexValue(const Complex(2, 0));
      final num2 = IntegerValue(3);
      final result = num1.power(num2);
      expect(result, isA<ComplexValue>());
      final complexResult = result as ComplexValue;
      expect(complexResult.value.real, closeTo(8.0, 0.0001));
      expect(complexResult.value.imaginary, closeTo(0.0, 0.0001));
    });

    test('power with complex exponent', () {
      final num1 = ComplexValue(const Complex(2, 0));
      final num2 = ComplexValue(const Complex(1, 0));
      final result = num1.power(num2);
      expect(result, isA<ComplexValue>());
      final complexResult = result as ComplexValue;
      expect(complexResult.value.real, closeTo(2.0, 0.0001));
      expect(complexResult.value.imaginary, closeTo(0.0, 0.0001));
    });

    test('negation', () {
      final num = ComplexValue(const Complex(3, 4));
      final result = num.negate();
      expect(result, isA<ComplexValue>());
      final complexResult = result as ComplexValue;
      expect(complexResult.value.real, equals(-3.0));
      expect(complexResult.value.imaginary, equals(-4.0));
    });

    test('toString returns complex representation', () {
      final num = ComplexValue(const Complex(3, 4));
      expect(num.toString(), equals('3.0 + 4.0i'));
    });

    test('polar form power calculation', () {
      final num = ComplexValue(const Complex(1, 1));
      final exp = DoubleValue(2);
      final result = num.power(exp);
      expect(result, isA<ComplexValue>());
      final complexResult = result as ComplexValue;
      expect(complexResult.value.real, closeTo(0.0, 0.0001));
      expect(complexResult.value.imaginary, closeTo(2.0, 0.0001));
    });
  });

  group('NumberValue type promotion', () {
    test('IntegerValue + DoubleValue = DoubleValue', () {
      final result = IntegerValue(5) + DoubleValue(2.5);
      expect(result, isA<DoubleValue>());
    });

    test('DoubleValue + ComplexValue = ComplexValue', () {
      final result = DoubleValue(5) + ComplexValue(const Complex(2, 1));
      expect(result, isA<ComplexValue>());
    });

    test('IntegerValue * ComplexValue = ComplexValue', () {
      final result = IntegerValue(3) * ComplexValue(const Complex(2, 1));
      expect(result, isA<ComplexValue>());
    });
  });

  group('MatrixValue', () {
    test('creates from rows with correct dimensions', () {
      final matrix = MatrixValue.fromRows([
        [IntegerValue(1), IntegerValue(2)],
        [DoubleValue(3.5), IntegerValue(4)],
      ]);

      expect(matrix.rowCount, equals(2));
      expect(matrix.columnCount, equals(2));
      expect(matrix.value[0][0], isA<IntegerValue>());
      expect(matrix.value[1][0], isA<DoubleValue>());
      expect(
          () => matrix.value[0][0] = IntegerValue(0), throwsUnsupportedError);
    });

    test('addition with another matrix and with scalar', () {
      final matrixA = MatrixValue.fromRows([
        [IntegerValue(1), IntegerValue(2)],
        [IntegerValue(3), IntegerValue(4)],
      ]);
      final matrixB = MatrixValue.fromRows([
        [IntegerValue(5), IntegerValue(6)],
        [IntegerValue(7), IntegerValue(8)],
      ]);

      final sumMatrix = matrixA + matrixB;
      expect(sumMatrix, isA<MatrixValue>());
      final sumValue = (sumMatrix as MatrixValue).value;
      expect((sumValue[0][0] as IntegerValue).value, equals(6));
      expect((sumValue[1][1] as IntegerValue).value, equals(12));

      final scalarSum = matrixA + IntegerValue(1);
      expect(scalarSum, isA<MatrixValue>());
      final scalarValue = (scalarSum as MatrixValue).value;
      expect((scalarValue[0][0] as IntegerValue).value, equals(2));
      expect((scalarValue[1][1] as IntegerValue).value, equals(5));
    });

    test('multiplication with another matrix and with scalar', () {
      final matrixA = MatrixValue.fromRows([
        [IntegerValue(1), IntegerValue(2)],
        [IntegerValue(3), IntegerValue(4)],
      ]);
      final matrixB = MatrixValue.fromRows([
        [IntegerValue(2), IntegerValue(0)],
        [IntegerValue(1), IntegerValue(2)],
      ]);

      final productMatrix = matrixA * matrixB;
      expect(productMatrix, isA<MatrixValue>());
      final productValue = (productMatrix as MatrixValue).value;
      expect((productValue[0][0] as IntegerValue).value, equals(4));
      expect((productValue[0][1] as IntegerValue).value, equals(4));
      expect((productValue[1][0] as IntegerValue).value, equals(10));
      expect((productValue[1][1] as IntegerValue).value, equals(8));

      final scalarProduct = matrixA * DoubleValue(0.5);
      expect(scalarProduct, isA<MatrixValue>());
      final scalarProductValue = (scalarProduct as MatrixValue).value;
      expect((scalarProductValue[0][0] as DoubleValue).value, equals(0.5));
      expect((scalarProductValue[1][1] as DoubleValue).value, equals(2.0));
    });

    test('identity factory and power operation', () {
      final identity = MatrixValue.identity(3);
      final powered = identity.power(IntegerValue(4));

      expect(powered, isA<MatrixValue>());
      final poweredValue = (powered as MatrixValue).value;
      for (var i = 0; i < 3; i++) {
        for (var j = 0; j < 3; j++) {
          final entry = poweredValue[i][j] as IntegerValue;
          expect(entry.value, equals(i == j ? 1 : 0));
        }
      }

      final base = MatrixValue.fromRows([
        [IntegerValue(2), IntegerValue(0)],
        [IntegerValue(0), IntegerValue(2)],
      ]);
      final squared = base.power(IntegerValue(2)) as MatrixValue;
      expect((squared.value[0][0] as IntegerValue).value, equals(4));
      expect((squared.value[1][1] as IntegerValue).value, equals(4));

      expect(
        () => MatrixValue.identity(0),
        throwsArgumentError,
      );
      expect(
        () => base.power(IntegerValue(-1)),
        throwsArgumentError,
      );
    });

    test('transpose, trace, and determinant', () {
      final matrix = MatrixValue.fromRows([
        [IntegerValue(1), IntegerValue(2)],
        [IntegerValue(3), IntegerValue(4)],
      ]);

      final transpose = matrix.transpose();
      expect(transpose, isA<MatrixValue>());
      final transposeValue = transpose.value;
      expect((transposeValue[0][1] as IntegerValue).value, equals(3));
      expect((transposeValue[1][0] as IntegerValue).value, equals(2));

      final trace = matrix.trace();
      expect(trace, isA<IntegerValue>());
      expect((trace as IntegerValue).value, equals(5));

      final determinant = matrix.determinant();
      expect(determinant, isA<NumberValue>());
      final detValue = determinant.value as num;
      expect(detValue.toDouble(), closeTo(-2, 1e-9));
    });

    test('eigenvalues for symmetric matrix', () {
      final matrix = MatrixValue.fromRows([
        [IntegerValue(2), IntegerValue(1)],
        [IntegerValue(1), IntegerValue(2)],
      ]);

      final eigenvalues = matrix.eigenvalues();
      expect(eigenvalues, isA<MatrixValue>());
      final entries = eigenvalues.value.first;
      final eigenNums = entries
          .map((value) => (value.value as num).toDouble())
          .toList()
        ..sort();
      expect(eigenNums, equals([1.0, 3.0]));
    });

    test('throws errors for invalid operations', () {
      final matrixA = MatrixValue.fromRows([
        [IntegerValue(1), IntegerValue(2)],
      ]);
      final matrixB = MatrixValue.fromRows([
        [IntegerValue(1)],
        [IntegerValue(2)],
        [IntegerValue(3)],
      ]);

      expect(() => matrixA + matrixB, throwsArgumentError);
      expect(() => matrixA * matrixB, throwsArgumentError);
      expect(() => matrixA / matrixB, throwsArgumentError);
      expect(
        () => MatrixValue.fromRows([
          [IntegerValue(1)],
          [IntegerValue(2), IntegerValue(3)],
        ]),
        throwsArgumentError,
      );
    });
  });
}
