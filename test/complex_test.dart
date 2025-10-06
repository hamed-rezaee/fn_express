import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('Complex', () {
    test('creates complex number with real and imaginary parts', () {
      const complex = Complex(3, 4);
      expect(complex.real, equals(3.0));
      expect(complex.imaginary, equals(4.0));
    });

    test('creates complex number with zero imaginary part', () {
      const complex = Complex(5, 0);
      expect(complex.real, equals(5.0));
      expect(complex.imaginary, equals(0.0));
    });

    test('creates complex number with zero real part', () {
      const complex = Complex(0, 7);
      expect(complex.real, equals(0.0));
      expect(complex.imaginary, equals(7.0));
    });

    test('creates complex number with negative parts', () {
      const complex = Complex(-2.5, -3.5);
      expect(complex.real, equals(-2.5));
      expect(complex.imaginary, equals(-3.5));
    });

    test('toString for real number only', () {
      const complex = Complex(5, 0);
      expect(complex.toString(), equals('5.0'));
    });

    test('toString for imaginary number only', () {
      const complex = Complex(0, 3);
      expect(complex.toString(), equals('3.0i'));
    });

    test('toString for positive imaginary part', () {
      const complex = Complex(2, 3);
      expect(complex.toString(), equals('2.0 + 3.0i'));
    });

    test('toString for negative imaginary part', () {
      const complex = Complex(2, -3);
      expect(complex.toString(), equals('2.0 - 3.0i'));
    });

    test('toString for zero complex number', () {
      const complex = Complex(0, 0);
      expect(complex.toString(), equals('0.0'));
    });

    test('const constructor works', () {
      const complex = Complex(1, 2);
      expect(complex.real, equals(1.0));
      expect(complex.imaginary, equals(2.0));
    });

    test('complex numbers with same values are equal', () {
      const complex1 = Complex(3, 4);
      const complex2 = Complex(3, 4);
      expect(complex1.real, equals(complex2.real));
      expect(complex1.imaginary, equals(complex2.imaginary));
    });
  });
}
