import 'dart:math' as math;

import 'package:fn_express/src/complex.dart';

/// Abstract base class for all numeric values in mathematical expressions.
///
/// This class defines the interface for different types of numbers (integers,
/// doubles, complex numbers, etc.) and provides the basic arithmetic operations
/// that all numeric types must implement.
///
/// The class supports automatic type promotion where operations between
/// different numeric types produce results of the most general type needed.
/// For example, operations between integers and doubles produce doubles,
/// and operations involving complex numbers produce complex results.
///
/// Type hierarchy:
/// - [IntegerValue]: Whole numbers
/// - [DoubleValue]: Floating-point numbers
/// - [ComplexValue]: Complex numbers with real and imaginary parts
abstract class NumberValue {
  /// The underlying numeric value of this number.
  ///
  /// This could be an [int], [double], or [Complex] depending on the
  /// concrete implementation.
  Object get value;

  /// Adds this number to [other] and returns the result.
  ///
  /// The result type is determined by type promotion rules.
  NumberValue operator +(NumberValue other);

  /// Subtracts [other] from this number and returns the result.
  ///
  /// The result type is determined by type promotion rules.
  NumberValue operator -(NumberValue other);

  /// Multiplies this number by [other] and returns the result.
  ///
  /// The result type is determined by type promotion rules.
  NumberValue operator *(NumberValue other);

  /// Divides this number by [other] and returns the result.
  ///
  /// Throws [ArgumentError] if [other] is zero.
  /// The result type is determined by type promotion rules.
  NumberValue operator /(NumberValue other);

  /// Calculates the modulo (remainder) of this number divided by [other].
  ///
  /// Throws [ArgumentError] if [other] is zero.
  /// The result type is determined by type promotion rules.
  NumberValue modulo(NumberValue other);

  /// Raises this number to the power of [exponent] and returns the result.
  ///
  /// The result type is determined by type promotion rules.
  NumberValue power(NumberValue exponent);

  /// Returns the negation of this number.
  ///
  /// This is equivalent to multiplying by -1.
  NumberValue negate();

  @override
  String toString() => value.toString();
}

/// Concrete implementation for integer numeric values.
///
/// Represents whole numbers and implements arithmetic operations with
/// automatic type promotion. When combined with floating-point numbers
/// or complex numbers, operations will promote to the more general type.
///
/// Integer division that results in a non-whole number will automatically
/// promote to [DoubleValue].
///
/// Example:
/// ```dart
/// final num1 = IntegerValue(5);
/// final num2 = IntegerValue(3);
/// final sum = num1 + num2; // Returns IntegerValue(8)
/// final quotient = num1 / num2; // Returns DoubleValue(1.6666...)
/// ```
class IntegerValue extends NumberValue {
  /// Creates a new integer value wrapping the given [value].
  IntegerValue(this.value);

  /// The integer value wrapped by this instance.
  @override
  final int value;

  @override
  NumberValue operator +(NumberValue other) {
    if (other is IntegerValue) return IntegerValue(value + other.value);
    if (other is DoubleValue) return DoubleValue(value + other.value);

    return other + this; // Defer to the other type's implementation
  }

  @override
  NumberValue operator -(NumberValue other) => this + other.negate();

  @override
  NumberValue operator *(NumberValue other) {
    if (other is IntegerValue) return IntegerValue(value * other.value);
    if (other is DoubleValue) return DoubleValue(value * other.value);

    return other * this;
  }

  @override
  NumberValue operator /(NumberValue other) {
    final otherVal = other.value as num;

    if (otherVal == 0) throw ArgumentError('Division by zero.');

    final result = value / otherVal;

    return result % 1 == 0 ? IntegerValue(result.toInt()) : DoubleValue(result);
  }

  @override
  NumberValue modulo(NumberValue other) {
    final otherVal = other.value as num;

    if (otherVal == 0) throw ArgumentError('Modulo by zero.');
    if (other is IntegerValue) return IntegerValue(value % other.value);

    return DoubleValue((value % otherVal).toDouble());
  }

  @override
  NumberValue power(NumberValue exponent) {
    final result = math.pow(value, exponent.value as num);

    return result % 1 == 0
        ? IntegerValue(result.toInt())
        : DoubleValue(result.toDouble());
  }

  @override
  NumberValue negate() => IntegerValue(-value);
}

/// Concrete implementation for floating-point numeric values.
///
/// Represents decimal numbers and implements arithmetic operations with
/// automatic type promotion. When combined with integers, the result
/// will be a double. When combined with complex numbers, the result
/// will be complex.
///
/// Example:
/// ```dart
/// final num1 = DoubleValue(3.14);
/// final num2 = IntegerValue(2);
/// final product = num1 * num2; // Returns DoubleValue(6.28)
/// ```
class DoubleValue extends NumberValue {
  /// Creates a new double value wrapping the given [value].
  DoubleValue(this.value);

  /// The floating-point value wrapped by this instance.
  @override
  final double value;

  @override
  NumberValue operator +(NumberValue other) {
    if (other is DoubleValue || other is IntegerValue) {
      return DoubleValue(value + (other.value as num));
    }

    if (other is ComplexValue) {
      return ComplexValue(
        Complex(value + other.value.real, other.value.imaginary),
      );
    }

    return other + this;
  }

  @override
  NumberValue operator -(NumberValue other) => this + other.negate();

  @override
  NumberValue operator *(NumberValue other) {
    if (other is DoubleValue || other is IntegerValue) {
      return DoubleValue(value * (other.value as num));
    }

    if (other is ComplexValue) {
      return ComplexValue(
        Complex(value * other.value.real, value * other.value.imaginary),
      );
    }

    return other * this;
  }

  @override
  NumberValue operator /(NumberValue other) {
    if (other is DoubleValue || other is IntegerValue) {
      final otherVal = other.value as num;

      if (otherVal == 0) throw ArgumentError('Division by zero.');

      return DoubleValue(value / otherVal);
    }

    return other.power(IntegerValue(-1)) * this;
  }

  @override
  NumberValue modulo(NumberValue other) {
    if (other is DoubleValue || other is IntegerValue) {
      final otherVal = other.value as num;

      if (otherVal == 0) throw ArgumentError('Modulo by zero.');

      return DoubleValue(value % otherVal);
    }

    throw ArgumentError('Modulo operation not supported with complex numbers.');
  }

  @override
  NumberValue power(NumberValue exponent) =>
      DoubleValue(math.pow(value, exponent.value as num).toDouble());

  @override
  NumberValue negate() => DoubleValue(-value);
}

/// Concrete implementation for complex numeric values.
///
/// Represents complex numbers with real and imaginary components.
/// Complex numbers are useful for mathematical operations that involve
/// the square root of negative numbers or advanced mathematical functions.
///
/// This implementation handles arithmetic operations between complex numbers
/// and automatically promotes real numbers to complex when needed.
///
/// Example:
/// ```dart
/// final complex1 = ComplexValue(Complex(3, 4)); // 3 + 4i
/// final complex2 = ComplexValue(Complex(1, -2)); // 1 - 2i
/// final sum = complex1 + complex2; // 4 + 2i
/// ```
class ComplexValue extends NumberValue {
  /// Creates a new complex value wrapping the given [value].
  ComplexValue(this.value);

  /// Factory constructor to create a [ComplexValue] from any [NumberValue].
  ///
  /// This factory method converts other numeric types to complex numbers:
  /// - [ComplexValue]: Returns the input unchanged
  /// - [DoubleValue]: Creates a complex number with the double as the real part
  /// - [IntegerValue]: Creates a complex number with the integer as the real part
  ///
  /// Throws [ArgumentError] if the input type is not supported.
  ///
  /// Example:
  /// ```dart
  /// final real = DoubleValue(5.0);
  /// final complex = ComplexValue.from(real); // Creates Complex(5.0, 0)
  /// ```
  factory ComplexValue.from(NumberValue val) {
    if (val is ComplexValue) {
      return val;
    }

    if (val is DoubleValue) {
      return ComplexValue(Complex(val.value, 0));
    }

    if (val is IntegerValue) {
      return ComplexValue(Complex(val.value.toDouble(), 0));
    }

    throw ArgumentError('Cannot convert ${val.runtimeType} to ComplexValue');
  }

  /// The complex number wrapped by this instance.
  @override
  final Complex value;

  @override
  NumberValue operator +(NumberValue other) {
    final otherComp = ComplexValue.from(other);

    return ComplexValue(
      Complex(
        value.real + otherComp.value.real,
        value.imaginary + otherComp.value.imaginary,
      ),
    );
  }

  @override
  NumberValue operator -(NumberValue other) => this + other.negate();

  @override
  NumberValue operator *(NumberValue other) {
    final otherComp = ComplexValue.from(other);
    final a = value.real;
    final b = value.imaginary;
    final c = otherComp.value.real;
    final d = otherComp.value.imaginary;

    return ComplexValue(Complex(a * c - b * d, a * d + b * c));
  }

  @override
  NumberValue operator /(NumberValue other) {
    final otherComp = ComplexValue.from(other);
    final a = value.real;
    final b = value.imaginary;
    final c = otherComp.value.real;
    final d = otherComp.value.imaginary;
    final denominator = c * c + d * d;

    if (denominator == 0) throw ArgumentError('Division by zero (complex).');

    return ComplexValue(
      Complex((a * c + b * d) / denominator, (b * c - a * d) / denominator),
    );
  }

  @override
  NumberValue modulo(NumberValue other) {
    throw ArgumentError(
        'Modulo operation is not supported for complex numbers.');
  }

  @override
  NumberValue power(NumberValue exponent) =>
      throw UnimplementedError('Complex exponentiation is not supported.');

  @override
  NumberValue negate() => ComplexValue(Complex(-value.real, -value.imaginary));
}
