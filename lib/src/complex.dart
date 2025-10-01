/// A mathematical representation of a complex number with real and imaginary parts.
///
/// This class represents a complex number in the form `a + bi`, where `a` is the
/// real part and `b` is the imaginary part. Complex numbers are useful for
/// mathematical calculations that involve the square root of negative numbers.
class Complex {
  /// Creates a new complex number with the given [real] and [imaginary] parts.
  ///
  /// Both parameters represent the coefficients of the real and imaginary
  /// components respectively.
  ///
  /// Example:
  /// ```dart
  /// final complex = Complex(2.5, -1.0); // Represents 2.5 - 1.0i
  /// ```
  const Complex(this.real, this.imaginary);

  /// The real part of the complex number.
  ///
  /// This represents the coefficient of the real component in the
  /// complex number representation `a + bi`.
  final double real;

  /// The imaginary part of the complex number.
  ///
  /// This represents the coefficient of the imaginary component in the
  /// complex number representation `a + bi`.
  final double imaginary;

  @override
  String toString() {
    if (imaginary == 0) return real.toString();
    if (real == 0) return '${imaginary}i';
    if (imaginary < 0) return '$real - ${-imaginary}i';

    return '$real + ${imaginary}i';
  }
}
