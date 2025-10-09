import 'dart:math' as math;

import 'package:fn_express/src/complex.dart';

const double _numberValueEpsilon = 1e-12;

bool _isEffectivelyInteger(double value) =>
    (value - value.round()).abs() <= _numberValueEpsilon;

double _sanitizeComponent(double value) =>
    value.abs() <= _numberValueEpsilon ? 0.0 : value;

NumberValue _sanitizeComplexResult(NumberValue value) {
  if (value is! ComplexValue) {
    return value;
  }

  final real = _sanitizeComponent(value.value.real);
  final imag = _sanitizeComponent(value.value.imaginary);

  if (imag == 0.0) {
    if (_isEffectivelyInteger(real)) {
      return IntegerValue(real.round());
    }

    return DoubleValue(real);
  }

  return ComplexValue(Complex(real, imag));
}

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
/// final sum = num1 + num2;
/// final quotient = num1 / num2;
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

    return other + this;
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
    if (exponent is ComplexValue) {
      return _sanitizeComplexResult(
        ComplexValue.from(this).power(exponent),
      );
    }

    final exponentValue = (exponent.value as num).toDouble();
    final result = math.pow(value, exponentValue);

    if (result is int) {
      return IntegerValue(result);
    }

    if (result is double) {
      if (result.isNaN) {
        return _sanitizeComplexResult(
          ComplexValue.from(this).power(DoubleValue(exponentValue)),
        );
      }

      if (_isEffectivelyInteger(result)) {
        return IntegerValue(result.round());
      }

      return DoubleValue(result);
    }

    final doubleResult = result.toDouble();

    if (doubleResult.isNaN) {
      return _sanitizeComplexResult(
        ComplexValue.from(this).power(DoubleValue(exponentValue)),
      );
    }

    if (_isEffectivelyInteger(doubleResult)) {
      return IntegerValue(doubleResult.round());
    }

    return DoubleValue(doubleResult);
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
/// final product = num1 * num2;
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
  NumberValue power(NumberValue exponent) {
    if (exponent is ComplexValue) {
      return _sanitizeComplexResult(
        ComplexValue.from(this).power(exponent),
      );
    }

    final exponentValue = (exponent.value as num).toDouble();
    final result = math.pow(value, exponentValue);

    if (result is double) {
      if (result.isNaN) {
        return _sanitizeComplexResult(
          ComplexValue.from(this).power(DoubleValue(exponentValue)),
        );
      }

      return DoubleValue(result);
    }

    if (result is int) {
      return DoubleValue(result.toDouble());
    }

    final doubleResult = result.toDouble();

    if (doubleResult.isNaN) {
      return _sanitizeComplexResult(
        ComplexValue.from(this).power(DoubleValue(exponentValue)),
      );
    }

    return DoubleValue(doubleResult);
  }

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
  /// final complex = ComplexValue.from(real);
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
  NumberValue power(NumberValue exponent) {
    // Convert complex number to polar form: z = r * e^(i*theta)
    // z^w = r^w * e^(i*w*theta) for complex w
    final r =
        math.sqrt(value.real * value.real + value.imaginary * value.imaginary);
    final theta = math.atan2(value.imaginary, value.real);

    if (exponent is IntegerValue || exponent is DoubleValue) {
      final exp = (exponent.value as num).toDouble();
      final newR = math.pow(r, exp);
      final newTheta = exp * theta;

      return ComplexValue(
        Complex(
          newR * math.cos(newTheta),
          newR * math.sin(newTheta),
        ),
      );
    } else if (exponent is ComplexValue) {
      // For complex exponent w = a + bi: z^w = e^(w * ln(z))
      // ln(z) = ln(r) + i*theta
      final lnR = math.log(r);
      final a = exponent.value.real;
      final b = exponent.value.imaginary;

      // w * ln(z) = (a + bi) * (ln(r) + i*theta)
      //           = a*ln(r) - b*theta + i*(b*ln(r) + a*theta)
      final realPart = a * lnR - b * theta;
      final imagPart = b * lnR + a * theta;

      // e^(realPart + i*imagPart) = e^realPart * (cos(imagPart) + i*sin(imagPart))
      final expReal = math.exp(realPart);

      return ComplexValue(
        Complex(
          expReal * math.cos(imagPart),
          expReal * math.sin(imagPart),
        ),
      );
    }

    throw ArgumentError('Unsupported exponent type for complex power');
  }

  @override
  NumberValue negate() => ComplexValue(Complex(-value.real, -value.imaginary));
}

/// Represents a matrix of numeric values.
class MatrixValue extends NumberValue {
  MatrixValue._(this.value)
      : rowCount = value.length,
        columnCount = value.isEmpty ? 0 : value.first.length;

  /// Creates a matrix from rows.
  factory MatrixValue.fromRows(List<List<NumberValue>> rows) {
    if (rows.isEmpty) {
      throw ArgumentError('Matrix must contain at least one row.');
    }

    final columnCount = rows.first.length;
    if (columnCount == 0) {
      throw ArgumentError('Matrix rows cannot be empty.');
    }

    for (final row in rows) {
      if (row.length != columnCount) {
        throw ArgumentError('All matrix rows must have the same length.');
      }
    }

    final normalised =
        rows.map(List<NumberValue>.unmodifiable).toList(growable: false);

    return MatrixValue._(List<List<NumberValue>>.unmodifiable(normalised));
  }

  /// Creates a row vector.
  factory MatrixValue.rowVector(List<NumberValue> values) =>
      MatrixValue.fromRows([values]);

  /// Creates a column vector.
  factory MatrixValue.columnVector(List<NumberValue> values) =>
      MatrixValue.fromRows(
          values.map((entry) => [entry]).toList(growable: false));

  /// Returns an identity matrix of size [n].
  factory MatrixValue.identity(int n) {
    if (n <= 0) {
      throw ArgumentError('Identity matrix size must be positive.');
    }

    return MatrixValue._fromGenerator(
      n,
      n,
      (r, c) => IntegerValue(r == c ? 1 : 0),
    );
  }

  factory MatrixValue._fromGenerator(
    int rows,
    int cols,
    NumberValue Function(int row, int col) generator,
  ) {
    final data = List<List<NumberValue>>.generate(
      rows,
      (r) => List<NumberValue>.generate(cols, (c) => generator(r, c),
          growable: false),
      growable: false,
    );
    return MatrixValue.fromRows(data);
  }

  /// Underlying matrix data (immutable rows).
  @override
  final List<List<NumberValue>> value;

  /// Number of rows.
  final int rowCount;

  /// Number of columns.
  final int columnCount;

  /// Returns true if the matrix is a vector (either a single row or a single column).
  bool get isVector => rowCount == 1 || columnCount == 1;

  @override
  NumberValue operator +(NumberValue other) {
    if (other is MatrixValue) {
      _ensureSameDimensions(other);
      return MatrixValue._fromGenerator(
          rowCount, columnCount, (r, c) => value[r][c] + other.value[r][c]);
    }

    return MatrixValue._fromGenerator(
      rowCount,
      columnCount,
      (r, c) => value[r][c] + other,
    );
  }

  @override
  NumberValue operator -(NumberValue other) => this + other.negate();

  @override
  NumberValue operator *(NumberValue other) {
    if (other is MatrixValue) {
      if (columnCount != other.rowCount) {
        throw ArgumentError(
            'Matrix dimensions are incompatible for multiplication.');
      }

      return MatrixValue._fromGenerator(rowCount, other.columnCount, (r, c) {
        NumberValue sum = IntegerValue(0);
        for (var k = 0; k < columnCount; k++) {
          sum = sum + value[r][k] * other.value[k][c];
        }
        return sum;
      });
    }

    return MatrixValue._fromGenerator(
      rowCount,
      columnCount,
      (r, c) => value[r][c] * other,
    );
  }

  @override
  NumberValue operator /(NumberValue other) {
    if (other is MatrixValue) {
      throw ArgumentError('Matrix division is only supported by scalars.');
    }

    return MatrixValue._fromGenerator(
      rowCount,
      columnCount,
      (r, c) => value[r][c] / other,
    );
  }

  @override
  NumberValue modulo(NumberValue other) {
    throw ArgumentError('Modulo is not defined for matrices.');
  }

  @override
  NumberValue power(NumberValue exponent) {
    if (exponent is! IntegerValue && exponent is! DoubleValue) {
      throw ArgumentError('Matrix power requires an integer exponent.');
    }

    final exp = (exponent.value as num).toInt();
    if (rowCount != columnCount) {
      throw ArgumentError('Matrix exponentiation requires a square matrix.');
    }
    if (exp < 0) {
      throw ArgumentError('Negative matrix powers are not supported.');
    }

    var result = MatrixValue.identity(rowCount);
    var base = this;
    var powerLeft = exp;

    while (powerLeft > 0) {
      if (powerLeft.isOdd) {
        result = (result * base) as MatrixValue;
      }
      powerLeft ~/= 2;
      if (powerLeft > 0) {
        base = (base * base) as MatrixValue;
      }
    }

    return result;
  }

  @override
  NumberValue negate() => MatrixValue._fromGenerator(
        rowCount,
        columnCount,
        (r, c) => value[r][c].negate(),
      );

  /// Returns the transpose of this matrix.
  MatrixValue transpose() => MatrixValue._fromGenerator(
        columnCount,
        rowCount,
        (r, c) => value[c][r],
      );

  /// Computes the determinant (for square matrices).
  NumberValue determinant() {
    _ensureSquare();
    final matrix = _toDoubleMatrix();
    final n = matrix.length;
    var det = 1.0;
    var sign = 1;

    for (var i = 0; i < n; i++) {
      var pivot = matrix[i][i];
      var pivotRow = i;

      for (var r = i + 1; r < n; r++) {
        if (matrix[r][i].abs() > pivot.abs()) {
          pivot = matrix[r][i];
          pivotRow = r;
        }
      }

      if (pivotRow != i) {
        final temp = matrix[i];
        matrix[i] = matrix[pivotRow];
        matrix[pivotRow] = temp;
        sign = -sign;
      }

      if (matrix[i][i].abs() < 1e-12) {
        return DoubleValue(0);
      }

      for (var r = i + 1; r < n; r++) {
        final factor = matrix[r][i] / matrix[i][i];
        for (var c = i; c < n; c++) {
          matrix[r][c] -= factor * matrix[i][c];
        }
      }
    }

    for (var i = 0; i < n; i++) {
      det *= matrix[i][i];
    }

    det *= sign;
    return _numberFromDouble(det);
  }

  /// Computes the trace of the matrix.
  NumberValue trace() {
    _ensureSquare();
    NumberValue sum = IntegerValue(0);
    for (var i = 0; i < rowCount; i++) {
      sum = sum + value[i][i];
    }
    return sum;
  }

  /// Returns the eigenvalues for symmetric real matrices using the Jacobi method.
  MatrixValue eigenvalues({int maxIterations = 100, double tolerance = 1e-10}) {
    _ensureSquare();
    final matrix = _toDoubleMatrix();
    final n = matrix.length;

    if (!_isSymmetric(matrix, tolerance)) {
      throw ArgumentError(
          'Eigenvalues are currently supported for symmetric real matrices only.');
    }

    for (var iter = 0; iter < maxIterations; iter++) {
      var maxVal = 0.0;
      var p = 0;
      var q = 1;

      for (var i = 0; i < n; i++) {
        for (var j = i + 1; j < n; j++) {
          final absVal = matrix[i][j].abs();
          if (absVal > maxVal) {
            maxVal = absVal;
            p = i;
            q = j;
          }
        }
      }

      if (maxVal < tolerance) {
        break;
      }

      final theta =
          0.5 * math.atan2(2 * matrix[p][q], matrix[q][q] - matrix[p][p]);
      final c = math.cos(theta);
      final s = math.sin(theta);

      final app = matrix[p][p];
      final aqq = matrix[q][q];
      final apq = matrix[p][q];

      matrix[p][p] = c * c * app - 2 * s * c * apq + s * s * aqq;
      matrix[q][q] = s * s * app + 2 * s * c * apq + c * c * aqq;
      matrix[p][q] = 0;
      matrix[q][p] = 0;

      for (var r = 0; r < n; r++) {
        if (r != p && r != q) {
          final arp = matrix[r][p];
          final arq = matrix[r][q];
          matrix[r][p] = c * arp - s * arq;
          matrix[p][r] = matrix[r][p];
          matrix[r][q] = s * arp + c * arq;
          matrix[q][r] = matrix[r][q];
        }
      }
    }

    final eigenvalues = List<NumberValue>.generate(
      n,
      (i) => _numberFromDouble(matrix[i][i]),
      growable: false,
    );

    return MatrixValue.rowVector(eigenvalues);
  }

  static NumberValue _numberFromDouble(double value) {
    if (value.abs() < 1e-12) return IntegerValue(0);
    if ((value - value.round()).abs() < 1e-9) {
      return IntegerValue(value.round());
    }
    return DoubleValue(value);
  }

  List<List<double>> _toDoubleMatrix() {
    return value
        .map(
          (row) => row.map(_toDouble).toList(growable: false),
        )
        .toList(growable: false);
  }

  double _toDouble(NumberValue number) {
    if (number is IntegerValue) return number.value.toDouble();
    if (number is DoubleValue) return number.value;
    throw ArgumentError(
        'Matrix operations currently support real numbers only.');
  }

  void _ensureSquare() {
    if (rowCount != columnCount) {
      throw ArgumentError('Operation requires a square matrix.');
    }
  }

  void _ensureSameDimensions(MatrixValue other) {
    if (rowCount != other.rowCount || columnCount != other.columnCount) {
      throw ArgumentError('Matrix dimensions must match.');
    }
  }

  bool _isSymmetric(List<List<double>> matrix, double tolerance) {
    for (var i = 0; i < matrix.length; i++) {
      for (var j = i + 1; j < matrix.length; j++) {
        if ((matrix[i][j] - matrix[j][i]).abs() > tolerance) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  String toString() {
    final rows = value
        .map((row) => '[${row.map((e) => e.toString()).join(', ')}]')
        .join(', ');
    return '[$rows]';
  }
}
