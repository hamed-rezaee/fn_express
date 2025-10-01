import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  late Interpreter interpreter;

  void expectValue<T>(NumberValue result, dynamic expectedValue) {
    expect(result, isA<T>());
    expect(result.value.toString(), expectedValue.toString());
  }

  setUp(() {
    interpreter = Interpreter();
  });

  group('Interpreter Core', () {
    test('handles basic addition and subtraction', () {
      final result = interpreter.eval('10 + 5 - 3');

      expectValue<IntegerValue>(result, 12);
    });

    test('handles multiplication and division precedence', () {
      final result = interpreter.eval('10 + 5 * 2');

      expectValue<IntegerValue>(result, 20);
    });

    test('handles parentheses to override precedence', () {
      final result = interpreter.eval('(10 + 5) * 2');

      expectValue<IntegerValue>(result, 30);
    });

    test('handles right-associative exponentiation', () {
      final result = interpreter.eval('2^3^2');

      expectValue<IntegerValue>(result, 512);
    });

    test('handles unary minus operator', () {
      expectValue<IntegerValue>(interpreter.eval('-5'), -5);
      expectValue<IntegerValue>(interpreter.eval('10 + -5'), 5);
      expectValue<IntegerValue>(interpreter.eval('-(10 + 5)'), -15);
    });
  });

  group('Data Type Handling', () {
    test('maintains Integer type when possible', () {
      final result = interpreter.eval('100 - 20 * 3');

      expect(result, isA<IntegerValue>());
      expect(result.value, 40);
    });

    test('promotes to Double for division', () {
      final result = interpreter.eval('10 / 4');

      expect(result, isA<DoubleValue>());
      expect(result.value, 2.5);
    });

    test('promotes to Double for mixed operations', () {
      final result = interpreter.eval('5 + 2.5');

      expect(result, isA<DoubleValue>());
      expect(result.value, 7.5);
    });
  });

  group('Complex Number Arithmetic', () {
    test('creates and evaluates complex numbers', () {
      final result = interpreter.eval('complex(5, -3)');

      expectValue<ComplexValue>(result, '5.0 - 3.0i');
    });

    test('uses the imaginary constant i', () {
      expectValue<ComplexValue>(interpreter.eval('i * i'), '-1.0');
    });

    test('adds two complex numbers', () {
      final result = interpreter.eval('complex(2, 3) + complex(4, 5)');

      expectValue<ComplexValue>(result, '6.0 + 8.0i');
    });

    test('multiplies two complex numbers', () {
      final result = interpreter.eval('(2 + 3i) * (4 - i)');

      expectValue<ComplexValue>(result, '11.0 + 10.0i');
    });

    test('divides two complex numbers', () {
      final result = interpreter.eval('complex(3, 2) / i');

      expectValue<ComplexValue>(result, '2.0 - 3.0i');
    });

    test('promotes real numbers in complex operations', () {
      final result = interpreter.eval('5 + complex(2, 3)');

      expectValue<ComplexValue>(result, '7.0 + 3.0i');
    });
  });

  group('Variables and Assignments', () {
    test('assigns and retrieves a simple variable', () {
      interpreter.eval('x = 10');
      final result = interpreter.eval('x * 3');

      expectValue<IntegerValue>(result, 30);
    });

    test('assigns the result of an expression', () {
      interpreter.eval('c = (1 + i) * (1 + i)');
      final result = interpreter.getVariable('c');

      expectValue<ComplexValue>(result!, '2.0i');
    });

    test('reassigns variables correctly', () {
      interpreter
        ..eval('y = 10')
        ..eval('y = y + 5');
      final result = interpreter.eval('y');

      expectValue<IntegerValue>(result, 15);
    });
  });

  group('Built-in Functions and Constants', () {
    test('uses constants pi and e', () {
      expect(interpreter.eval('pi').value, closeTo(3.14159, 0.00001));
      expect(interpreter.eval('2 * e').value, closeTo(5.43656, 0.00001));
    });

    test('sqrt returns a complex number for negative input', () {
      final result = interpreter.eval('sqrt(-16)');

      expectValue<ComplexValue>(result, '4.0i');
    });

    test('abs calculates magnitude for complex numbers', () {
      final result = interpreter.eval('abs(complex(3, 4))');

      expectValue<DoubleValue>(result, 5.0);
    });

    test('ln calculates natural logarithm', () {
      expect(interpreter.eval('ln(e)').value, closeTo(1.0, 0.00001));
      expect(interpreter.eval('ln(1)').value, closeTo(0.0, 0.00001));
      expect(interpreter.eval('ln(2.71828)').value, closeTo(1.0, 0.0001));
    });

    test('ln throws error for non-positive numbers', () {
      expect(() => interpreter.eval('ln(0)'), throwsA(isA<ArgumentError>()));
      expect(() => interpreter.eval('ln(-1)'), throwsA(isA<ArgumentError>()));
    });

    test('log calculates logarithm with specified base', () {
      expect(interpreter.eval('log(100, 10)').value, closeTo(2.0, 0.00001));
      expect(interpreter.eval('log(8, 2)').value, closeTo(3.0, 0.00001));
      expect(interpreter.eval('log(27, 3)').value, closeTo(3.0, 0.00001));
      expect(interpreter.eval('log(1, 10)').value, closeTo(0.0, 0.00001));
    });

    test('log throws error for invalid inputs', () {
      expect(
        () => interpreter.eval('log(0, 10)'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => interpreter.eval('log(-1, 10)'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => interpreter.eval('log(10, 0)'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => interpreter.eval('log(10, 1)'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => interpreter.eval('log(10, -2)'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('pow calculates power functions', () {
      expect(interpreter.eval('pow(2, 3)').value, closeTo(8.0, 0.00001));
      expect(interpreter.eval('pow(5, 2)').value, closeTo(25.0, 0.00001));
      expect(interpreter.eval('pow(4, 0.5)').value, closeTo(2.0, 0.00001));
      expect(interpreter.eval('pow(10, -1)').value, closeTo(0.1, 0.00001));
      expect(interpreter.eval('pow(-2, 3)').value, closeTo(-8.0, 0.00001));
    });
  });

  group('Implicit Multiplication', () {
    test('handles number before parenthesis', () {
      expectValue<IntegerValue>(interpreter.eval('3(4+1)'), 15);
    });

    test('handles number before variable', () {
      interpreter.eval('x=5');
      expectValue<IntegerValue>(interpreter.eval('4x'), 20);
    });

    test('handles parenthesis before variable', () {
      interpreter.eval('x=5');
      expectValue<IntegerValue>(interpreter.eval('(2+2)x'), 20);
    });

    test('handles parenthesis before parenthesis', () {
      expectValue<IntegerValue>(interpreter.eval('(2+2)(3+3)'), 24);
    });

    test('handles variable before parenthesis', () {
      interpreter.eval('x=3');
      expectValue<IntegerValue>(interpreter.eval('x(4+1)'), 15);
    });
  });

  group('New Mathematical Functions', () {
    test('modulo operator works with integers', () {
      expect(interpreter.eval('10 % 3').value, 1);
      expect(interpreter.eval('17 % 5').value, 2);
      expect(interpreter.eval('8 % 4').value, 0);
    });

    test('modulo operator works with mixed number types', () {
      expect(interpreter.eval('10.5 % 3').value, closeTo(1.5, 0.00001));
      expect(interpreter.eval('7 % 2.5').value, closeTo(2.0, 0.00001));
    });

    test('modulo throws error on division by zero', () {
      expect(() => interpreter.eval('10 % 0'), throwsA(isA<ArgumentError>()));
    });

    test('modulo throws error with complex numbers', () {
      expect(
        () => interpreter.eval('complex(1, 2) % 3'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('floor function works correctly', () {
      expect(interpreter.eval('floor(3.7)').value, 3);
      expect(interpreter.eval('floor(-2.3)').value, -3);
      expect(interpreter.eval('floor(5)').value, 5);
    });

    test('ceil function works correctly', () {
      expect(interpreter.eval('ceil(3.2)').value, 4);
      expect(interpreter.eval('ceil(-2.7)').value, -2);
      expect(interpreter.eval('ceil(5)').value, 5);
    });

    test('round function works correctly', () {
      expect(interpreter.eval('round(3.7)').value, 4);
      expect(interpreter.eval('round(3.2)').value, 3);
      expect(interpreter.eval('round(-2.7)').value, -3);
      expect(interpreter.eval('round(-2.2)').value, -2);
    });

    test('trunc function works correctly', () {
      expect(interpreter.eval('trunc(3.7)').value, 3);
      expect(interpreter.eval('trunc(-2.7)').value, -2);
      expect(interpreter.eval('trunc(5)').value, 5);
    });

    test('rounding functions throw error with complex numbers', () {
      expect(
        () => interpreter.eval('floor(complex(1, 2))'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => interpreter.eval('ceil(complex(1, 2))'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => interpreter.eval('round(complex(1, 2))'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => interpreter.eval('trunc(complex(1, 2))'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('asin function works correctly', () {
      expect(interpreter.eval('asin(0)').value, closeTo(0.0, 0.00001));
      expect(interpreter.eval('asin(1)').value, closeTo(1.5708, 0.0001));
      expect(interpreter.eval('asin(-1)').value, closeTo(-1.5708, 0.0001));
    });

    test('acos function works correctly', () {
      expect(interpreter.eval('acos(1)').value, closeTo(0.0, 0.00001));
      expect(interpreter.eval('acos(0)').value, closeTo(1.5708, 0.0001));
      expect(interpreter.eval('acos(-1)').value, closeTo(3.1416, 0.0001));
    });

    test('atan function works correctly', () {
      expect(interpreter.eval('atan(0)').value, closeTo(0.0, 0.00001));
      expect(interpreter.eval('atan(1)').value, closeTo(0.7854, 0.0001));
      expect(interpreter.eval('atan(-1)').value, closeTo(-0.7854, 0.0001));
    });

    test('inverse trig functions throw error for invalid domain', () {
      expect(() => interpreter.eval('asin(2)'), throwsA(isA<ArgumentError>()));
      expect(() => interpreter.eval('asin(-2)'), throwsA(isA<ArgumentError>()));
      expect(
        () => interpreter.eval('acos(1.5)'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => interpreter.eval('acos(-1.5)'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('factorial function works correctly', () {
      expect(interpreter.eval('fact(0)').value, 1);
      expect(interpreter.eval('fact(1)').value, 1);
      expect(interpreter.eval('fact(5)').value, 120);
      expect(interpreter.eval('fact(10)').value, 3628800);
    });

    test('factorial throws error for negative numbers', () {
      expect(() => interpreter.eval('fact(-1)'), throwsA(isA<ArgumentError>()));
      expect(() => interpreter.eval('fact(-5)'), throwsA(isA<ArgumentError>()));
    });

    test('factorial throws error for non-integers', () {
      expect(
        () => interpreter.eval('fact(3.5)'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => interpreter.eval('fact(2.1)'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('factorial throws error for complex numbers', () {
      expect(
        () => interpreter.eval('fact(complex(1, 2))'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('factorial throws error for large numbers', () {
      expect(
        () => interpreter.eval('fact(200)'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('min function works with two integers', () {
      expect(interpreter.eval('min(5, 3)').value, 3);
      expect(interpreter.eval('min(10, 20)').value, 10);
      expect(interpreter.eval('min(-5, -3)').value, -5);
    });

    test('min function works with mixed number types', () {
      expect(interpreter.eval('min(5.7, 3)').value, closeTo(3.0, 0.00001));
      expect(interpreter.eval('min(2, 3.5)').value, closeTo(2.0, 0.00001));
      expect(interpreter.eval('min(2.1, 3.9)').value, closeTo(2.1, 0.00001));
    });

    test('max function works with two integers', () {
      expect(interpreter.eval('max(5, 3)').value, 5);
      expect(interpreter.eval('max(10, 20)').value, 20);
      expect(interpreter.eval('max(-5, -3)').value, -3);
    });

    test('max function works with mixed number types', () {
      expect(interpreter.eval('max(5.7, 3)').value, closeTo(5.7, 0.00001));
      expect(interpreter.eval('max(2, 3.5)').value, closeTo(3.5, 0.00001));
      expect(interpreter.eval('max(2.1, 3.9)').value, closeTo(3.9, 0.00001));
    });

    test('min/max functions throw error with complex numbers', () {
      expect(
        () => interpreter.eval('min(complex(1, 2), 3)'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => interpreter.eval('max(1, complex(2, 3))'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Error Handling', () {
    test('throws on undefined variable', () {
      expect(() => interpreter.eval('x + 5'), throwsA(isA<ArgumentError>()));
    });

    test('throws on undefined function', () {
      expect(() => interpreter.eval('foo(5)'), throwsA(isA<ArgumentError>()));
    });

    test('throws on mismatched parentheses', () {
      expect(() => interpreter.eval('(5 + 2'), throwsA(isA<FormatException>()));
    });

    test('throws on division by zero', () {
      expect(() => interpreter.eval('10 / 0'), throwsA(isA<ArgumentError>()));
      expect(
        () => interpreter.eval('fraction(1, 2) / 0'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on malformed expression', () {
      expect(() => interpreter.eval('5 + * 2'), throwsA(isA<StateError>()));
    });

    test('throws on not enough arguments for function', () {
      expect(() => interpreter.eval('fraction(1)'), throwsA(isA<StateError>()));
    });
  });
}
