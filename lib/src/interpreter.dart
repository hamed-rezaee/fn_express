import 'dart:math' as math;

import 'package:fn_express/fn_express.dart';

/// Main interpreter class for evaluating mathematical expressions.
///
/// This class serves as the central coordinator for parsing and evaluating
/// mathematical expressions. It manages variables, constants, and functions,
/// and orchestrates the lexing, parsing, and evaluation process.
///
/// Features:
/// - Variable assignment and retrieval
/// - Built-in mathematical constants (pi, e, i, phi, tau)
/// - Basic arithmetic operators (+, -, *, /, %, ^)
/// - Built-in functions (sqrt, ln, exp, sin, cos, tan, abs, asin, acos, atan, sign)
/// - Hyperbolic functions (sinh, cosh, tanh, asinh, acosh, atanh)
/// - Rounding functions (floor, ceil, round, trunc)
/// - Special functions (fact - factorial, factorial2 - double factorial, gamma)
/// - Multi-argument functions (complex, log, pow, min, max, fraction, clamp, gcd, lcm)
/// - Statistical functions (average, median, mode, stdev, variance)
/// - Random number generation (random)
/// - Support for complex number arithmetic
/// - Expression parsing and evaluation
///
/// Example:
/// ```dart
/// final interpreter = Interpreter();
/// interpreter.eval('x = 5');
/// final result = interpreter.eval('2 * x + sqrt(16) + ln(e) + log(100, 10)');
/// print(result);
/// ```
class Interpreter {
  /// Creates a new interpreter instance with default constants and functions.
  ///
  /// Initializes the multi-argument functions, including:
  /// - `complex(real, imag)`: Creates a complex number from real and imaginary parts
  /// - `log(value, base)`: Calculates logarithm with specified base
  /// - `pow(base, exponent)`: Calculates power function
  /// - `min(val1, val2)`: Returns the minimum of two values
  /// - `max(val1, val2)`: Returns the maximum of two values
  /// - `fraction(numerator, denominator)`: Creates a fraction
  /// - `clamp(value, min, max)`: Clamps a value between minimum and maximum bounds
  Interpreter() {
    multiArgFunctions = {
      'complex': Tuple2(
        (args) {
          final real = args[0].value as num;
          final imag = args[1].value as num;

          return ComplexValue(Complex(real.toDouble(), imag.toDouble()));
        },
        2,
      ),
      'fraction': Tuple2(
        (args) {
          final numerator = args[0].value as num;
          final denominator = args[1].value as num;

          if (denominator == 0) throw ArgumentError('Division by zero.');

          return DoubleValue(numerator / denominator);
        },
        2,
      ),
      'log': Tuple2(
        (args) {
          final value = args[0].value as num;
          final base = args[1].value as num;

          if (value <= 0) {
            throw ArgumentError(
              'Logarithm undefined for non-positive numbers.',
            );
          }

          if (base <= 0 || base == 1) {
            throw ArgumentError('Invalid logarithm base.');
          }

          return DoubleValue(math.log(value) / math.log(base));
        },
        2,
      ),
      'pow': Tuple2(
        (args) {
          final base = args[0].value as num;
          final exponent = args[1].value as num;

          return DoubleValue(math.pow(base, exponent).toDouble());
        },
        2,
      ),
      'min': Tuple2(
        (args) {
          if (args.isEmpty) {
            throw ArgumentError('Min function requires at least one argument.');
          }

          if (args.any((arg) => arg is ComplexValue)) {
            throw ArgumentError(
              'Min function not supported for complex numbers.',
            );
          }

          final values = args.map((arg) => arg.value as num).toList();
          final result = values.reduce(math.min);

          if (args.every((arg) => arg is IntegerValue)) {
            return IntegerValue(result.toInt());
          }

          return DoubleValue(result.toDouble());
        },
        -1,
      ),
      'max': Tuple2(
        (args) {
          if (args.isEmpty) {
            throw ArgumentError('Max function requires at least one argument.');
          }

          if (args.any((arg) => arg is ComplexValue)) {
            throw ArgumentError(
              'Max function not supported for complex numbers.',
            );
          }

          final values = args.map((arg) => arg.value as num).toList();
          final result = values.reduce(math.max);

          if (args.every((arg) => arg is IntegerValue)) {
            return IntegerValue(result.toInt());
          }

          return DoubleValue(result.toDouble());
        },
        -1,
      ),
      'clamp': Tuple2(
        (args) {
          if (args.any((arg) => arg is ComplexValue)) {
            throw ArgumentError(
              'Clamp function not supported for complex numbers.',
            );
          }

          final value = args[0].value as num;
          final min = args[1].value as num;
          final max = args[2].value as num;

          if (min > max) {
            throw ArgumentError(
              'Minimum value cannot be greater than maximum value.',
            );
          }

          final result = value < min ? min : (value > max ? max : value);

          if (args.every((arg) => arg is IntegerValue)) {
            return IntegerValue(result.toInt());
          }

          return DoubleValue(result.toDouble());
        },
        3,
      ),
      'gcd': Tuple2(
        (args) {
          if (args.any((arg) => arg is ComplexValue)) {
            throw ArgumentError(
              'GCD function not supported for complex numbers.',
            );
          }

          final a = (args[0].value as num).abs().toInt();
          final b = (args[1].value as num).abs().toInt();

          return IntegerValue(_gcd(a, b));
        },
        2,
      ),
      'lcm': Tuple2(
        (args) {
          if (args.any((arg) => arg is ComplexValue)) {
            throw ArgumentError(
              'LCM function not supported for complex numbers.',
            );
          }

          final a = (args[0].value as num).abs().toInt();
          final b = (args[1].value as num).abs().toInt();

          if (a == 0 || b == 0) return IntegerValue(0);

          return IntegerValue((a * b) ~/ _gcd(a, b));
        },
        2,
      ),
      'median': Tuple2(
        (args) {
          if (args.isEmpty) {
            throw ArgumentError(
              'Median function requires at least one argument.',
            );
          }

          if (args.any((arg) => arg is ComplexValue)) {
            throw ArgumentError(
                'Median function not supported for complex numbers.');
          }

          final values =
              args.map((arg) => (arg.value as num).toDouble()).toList()..sort();
          final n = values.length;

          return n.isOdd
              ? DoubleValue(values[n ~/ 2])
              : DoubleValue((values[n ~/ 2 - 1] + values[n ~/ 2]) / 2);
        },
        -1,
      ),
      'mode': Tuple2(
        (args) {
          if (args.isEmpty) {
            throw ArgumentError(
              'Mode function requires at least one argument.',
            );
          }

          if (args.any((arg) => arg is ComplexValue)) {
            throw ArgumentError(
                'Mode function not supported for complex numbers.');
          }

          final values = args.map((arg) => arg.value as num).toList();
          final frequency = <num, int>{};

          for (final value in values) {
            frequency[value] = (frequency[value] ?? 0) + 1;
          }

          final maxFreq = frequency.values.reduce(math.max);
          final modes = frequency.entries
              .where((entry) => entry.value == maxFreq)
              .map((entry) => entry.key)
              .toList();
          final mode = modes.first;

          if (mode == mode.toInt()) return IntegerValue(mode.toInt());

          return DoubleValue(mode.toDouble());
        },
        -1,
      ),
      'stdev': Tuple2(
        (args) {
          if (args.length < 2) {
            throw ArgumentError(
              'Standard deviation requires at least 2 arguments.',
            );
          }

          if (args.any((arg) => arg is ComplexValue)) {
            throw ArgumentError(
                'Standard deviation not supported for complex numbers.');
          }

          final values =
              args.map((arg) => (arg.value as num).toDouble()).toList();
          final mean = values.reduce((a, b) => a + b) / values.length;
          final variance = values
                  .map((value) => math.pow(value - mean, 2))
                  .reduce((a, b) => a + b) /
              (values.length - 1);

          return DoubleValue(math.sqrt(variance));
        },
        -1,
      ),
      'variance': Tuple2(
        (args) {
          if (args.length < 2) {
            throw ArgumentError('Variance requires at least 2 arguments.');
          }

          if (args.any((arg) => arg is ComplexValue)) {
            throw ArgumentError(
                'Variance function not supported for complex numbers.');
          }

          final values =
              args.map((arg) => (arg.value as num).toDouble()).toList();
          final mean = values.reduce((a, b) => a + b) / values.length;
          final variance = values
                  .map((value) => math.pow(value - mean, 2))
                  .reduce((a, b) => a + b) /
              (values.length - 1);

          return DoubleValue(variance);
        },
        -1,
      ),
      'random': Tuple2(
        (args) => DoubleValue(math.Random().nextDouble()),
        0,
      ),
      'average': Tuple2(
        (args) {
          if (args.isEmpty) {
            throw ArgumentError(
              'Average function requires at least one argument.',
            );
          }

          if (args.any((arg) => arg is ComplexValue)) {
            throw ArgumentError(
              'Average function not supported for complex numbers.',
            );
          }

          final values =
              args.map((arg) => (arg.value as num).toDouble()).toList();
          final sum = values.reduce((a, b) => a + b);
          final average = sum / values.length;

          return DoubleValue(average);
        },
        -1,
      ),
    };
  }

  /// Map of user-defined variables and their values.
  ///
  /// Variables can be assigned using the assignment operator (=) in expressions
  /// and retrieved in subsequent expressions.
  final Map<String, NumberValue> variables = {};

  /// Map of built-in mathematical constants.
  ///
  /// Includes:
  /// - `pi`: The mathematical constant π (3.14159...)
  /// - `e`: The mathematical constant e (2.71828...)
  /// - `i`: The imaginary unit (0 + 1i)
  /// - `phi`: The golden ratio φ (1.61803...)
  /// - `tau`: The mathematical constant τ = 2π (6.28318...)
  final Map<String, NumberValue> constants = {
    'pi': DoubleValue(math.pi),
    'e': DoubleValue(math.e),
    'i': ComplexValue(const Complex(0, 1)),
    'phi': DoubleValue((1 + math.sqrt(5)) / 2),
    'tau': DoubleValue(2 * math.pi),
  };

  /// Map of single-argument mathematical functions.
  ///
  /// Includes:
  /// - `sqrt`: Square root (returns complex for negative inputs)
  /// - `ln`: Natural logarithm (base e)
  /// - `exp`: Exponential function (e^x)
  /// - `sin`, `cos`, `tan`: Trigonometric functions
  /// - `asin`, `acos`, `atan`: Inverse trigonometric functions
  /// - `sinh`, `cosh`, `tanh`: Hyperbolic functions
  /// - `asinh`, `acosh`, `atanh`: Inverse hyperbolic functions
  /// - `abs`: Absolute value (magnitude for complex numbers)
  /// - `floor`, `ceil`, `round`, `trunc`: Rounding functions
  /// - `fact`: Factorial function
  /// - `factorial2`: Double factorial function
  /// - `gamma`: Gamma function (generalization of factorial)
  /// - `sign`: Sign function (-1, 0, 1)
  /// - `random`: Random number generation (0 to x)
  final Map<String, NumberValue Function(NumberValue)> functions = {
    'sqrt': (x) {
      final numValue = x.value as num;

      if (numValue < 0) return ComplexValue(Complex(0, math.sqrt(-numValue)));

      return DoubleValue(math.sqrt(numValue));
    },
    'ln': (x) {
      final numValue = x.value as num;

      if (numValue <= 0) {
        throw ArgumentError(
          'Natural logarithm undefined for non-positive numbers.',
        );
      }

      return DoubleValue(math.log(numValue));
    },
    'sin': (x) => DoubleValue(math.sin(x.value as num)),
    'cos': (x) => DoubleValue(math.cos(x.value as num)),
    'tan': (x) => DoubleValue(math.tan(x.value as num)),
    'asin': (x) {
      final numValue = x.value as num;

      if (numValue < -1 || numValue > 1) {
        throw ArgumentError(
          'Arcsine domain error: input must be between -1 and 1.',
        );
      }

      return DoubleValue(math.asin(numValue));
    },
    'acos': (x) {
      final numValue = x.value as num;

      if (numValue < -1 || numValue > 1) {
        throw ArgumentError(
          'Arccosine domain error: input must be between -1 and 1.',
        );
      }

      return DoubleValue(math.acos(numValue));
    },
    'atan': (x) => DoubleValue(math.atan(x.value as num)),
    'abs': (x) {
      if (x is ComplexValue) {
        return DoubleValue(
          math.sqrt(
            x.value.real * x.value.real + x.value.imaginary * x.value.imaginary,
          ),
        );
      }

      return DoubleValue((x.value as num).abs().toDouble());
    },
    'floor': (x) {
      if (x is ComplexValue) {
        throw ArgumentError(
          'Floor function not supported for complex numbers.',
        );
      }

      return IntegerValue((x.value as num).floor());
    },
    'ceil': (x) {
      if (x is ComplexValue) {
        throw ArgumentError('Ceil function not supported for complex numbers.');
      }

      return IntegerValue((x.value as num).ceil());
    },
    'round': (x) {
      if (x is ComplexValue) {
        throw ArgumentError(
          'Round function not supported for complex numbers.',
        );
      }

      return IntegerValue((x.value as num).round());
    },
    'trunc': (x) {
      if (x is ComplexValue) {
        throw ArgumentError(
          'Trunc function not supported for complex numbers.',
        );
      }

      return IntegerValue((x.value as num).truncate());
    },
    'fact': (x) {
      if (x is ComplexValue) {
        throw ArgumentError(
          'Factorial function not supported for complex numbers.',
        );
      }

      final numValue = x.value as num;

      if (numValue < 0 || numValue != numValue.round()) {
        throw ArgumentError(
          'Factorial only defined for non-negative integers.',
        );
      }

      final n = numValue.toInt();

      if (n > 170) {
        throw ArgumentError('Factorial input too large (overflow).');
      }

      var result = 1;

      for (var i = 2; i <= n; i++) {
        result *= i;
      }

      return IntegerValue(result);
    },
    'sign': (x) {
      if (x is ComplexValue) {
        throw ArgumentError('Sign function not supported for complex numbers.');
      }

      final numValue = x.value as num;

      if (numValue > 0) return IntegerValue(1);
      if (numValue < 0) return IntegerValue(-1);

      return IntegerValue(0);
    },
    'sinh': (x) => DoubleValue(_sinh(x.value as num)),
    'cosh': (x) => DoubleValue(_cosh(x.value as num)),
    'tanh': (x) => DoubleValue(_tanh(x.value as num)),
    'asinh': (x) => DoubleValue(_asinh(x.value as num)),
    'acosh': (x) {
      final numValue = x.value as num;

      if (numValue < 1) {
        throw ArgumentError(
          'Inverse hyperbolic cosine domain error: input must be >= 1.',
        );
      }

      return DoubleValue(_acosh(numValue));
    },
    'atanh': (x) {
      final numValue = x.value as num;

      if (numValue <= -1 || numValue >= 1) {
        throw ArgumentError(
          'Inverse hyperbolic tangent domain error: input must be in (-1, 1).',
        );
      }

      return DoubleValue(_atanh(numValue));
    },
    'gamma': (x) {
      final numValue = x.value as num;

      if (numValue <= 0) {
        throw ArgumentError(
          'Gamma function undefined for non-positive numbers.',
        );
      }

      return DoubleValue(_gamma(numValue));
    },
    'factorial2': (x) {
      if (x is ComplexValue) {
        throw ArgumentError(
          'Double factorial function not supported for complex numbers.',
        );
      }

      final numValue = x.value as num;

      if (numValue < 0 || numValue != numValue.round()) {
        throw ArgumentError(
          'Double factorial only defined for non-negative integers.',
        );
      }

      return IntegerValue(_factorial2(numValue.toInt()));
    },
    'exp': (x) => DoubleValue(math.exp(x.value as num)),
  };

  /// Map of multi-argument functions with their implementations and argument counts.
  ///
  /// Each entry contains a tuple with the function implementation and the
  /// required number of arguments. Use -1 for variable argument functions.
  late final Map<String, Tuple2<NumberValue Function(List<NumberValue>), int>>
      multiArgFunctions;

  /// Sets a variable to the specified value.
  ///
  /// Stores the given [value] under the variable [name] for later retrieval
  /// in expressions. If the variable already exists, it will be overwritten.
  ///
  /// Example:
  /// ```dart
  /// interpreter.setVariable('x', IntegerValue(10));
  /// ```
  void setVariable(String name, NumberValue value) => variables[name] = value;

  /// Retrieves the value of a variable by name.
  ///
  /// Returns the [NumberValue] associated with the variable [name],
  /// or `null` if the variable is not defined.
  ///
  /// Example:
  /// ```dart
  /// final x = interpreter.getVariable('x');
  /// if (x != null) {
  ///   print('x = ${x.value}');
  /// }
  /// ```
  NumberValue? getVariable(String name) => variables[name];

  /// Counts the number of arguments in function calls by parsing the expression.
  /// Handles nested function calls correctly by tracking parentheses depth.
  Map<String, int> _countFunctionArguments(String expression) {
    final functionArgCounts = <String, int>{};

    for (var i = 0; i < expression.length; i++) {
      if (RegExp('[a-zA-Z]').hasMatch(expression[i])) {
        final funcStart = i;

        while (i < expression.length &&
            RegExp('[a-zA-Z0-9]').hasMatch(expression[i])) {
          i++;
        }

        final functionName = expression.substring(funcStart, i);

        while (i < expression.length && expression[i] == ' ') {
          i++;
        }

        if (i < expression.length && expression[i] == '(') {
          final argCount = _countArgumentsInParentheses(expression, i);

          functionArgCounts[functionName] = argCount;
        }
      }
    }

    return functionArgCounts;
  }

  /// Counts arguments within parentheses, handling nested parentheses correctly.
  int _countArgumentsInParentheses(String expression, int startIndex) {
    var parenDepth = 0;
    var argCount = 0;
    var hasContent = false;

    for (var i = startIndex; i < expression.length; i++) {
      final char = expression[i];

      if (char == '(') {
        parenDepth++;
      } else if (char == ')') {
        parenDepth--;

        if (parenDepth == 0) return hasContent ? argCount + 1 : 0;
      } else if (char == ',' && parenDepth == 1) {
        argCount++;
      } else if (char != ' ' && parenDepth == 1) {
        hasContent = true;
      }
    }

    return 0;
  }

  /// Evaluates a mathematical expression and returns the result.
  ///
  /// This is the main method for expression evaluation. It can handle:
  /// - Arithmetic expressions: `2 + 3 * 4`
  /// - Variable assignments: `x = 5`
  /// - Function calls: `sqrt(16)`
  /// - Complex numbers: `complex(3, 4)`
  /// - Mixed expressions: `x = 2 * sin(pi/4)`
  ///
  /// The method first checks for variable assignments (expressions containing `=`),
  /// then tokenizes, parses, and evaluates the expression.
  ///
  /// Parameters:
  /// - [expression]: The mathematical expression string to evaluate
  ///
  /// Returns the [NumberValue] result of the expression evaluation.
  ///
  /// Throws:
  /// - [FormatException] for syntax errors in the expression
  /// - [ArgumentError] for undefined variables or functions
  /// - [StateError] for malformed expressions
  ///
  /// Example:
  /// ```dart
  /// final result1 = interpreter.eval('2 + 3');
  /// final result2 = interpreter.eval('x = 10');
  /// final result3 = interpreter.eval('sqrt(x)');
  /// ```
  NumberValue eval(String expression) {
    final varAssignMatch =
        RegExp(r'^\s*([a-zA-Z][a-zA-Z0-9]*)\s*=\s*(.+)').firstMatch(expression);

    if (varAssignMatch != null) {
      final varName = varAssignMatch.group(1)!;
      final exprToEval = varAssignMatch.group(2)!;
      final result = eval(exprToEval);

      setVariable(varName, result);

      return result;
    }

    final functionArgCounts = _countFunctionArguments(expression);

    final allFunctionNames = functions.keys.toSet()
      ..addAll(multiArgFunctions.keys);
    final lexer = Lexer(expression, allFunctionNames, constants.keys.toSet());
    final tokens = lexer.tokenize();

    final parser = Parser(tokens);
    final rpnQueue = parser.toPostfix();

    final evaluator = Evaluator(rpnQueue, this, functionArgCounts);

    return evaluator.evaluate();
  }
}

// Helper functions for hyperbolic and special mathematical operations

/// Calculates hyperbolic sine
double _sinh(num x) {
  final ex = math.exp(x.toDouble());

  return (ex - 1 / ex) / 2;
}

/// Calculates hyperbolic cosine
double _cosh(num x) {
  final ex = math.exp(x.toDouble());

  return (ex + 1 / ex) / 2;
}

/// Calculates hyperbolic tangent
double _tanh(num x) {
  final ex = math.exp(2 * x.toDouble());

  return (ex - 1) / (ex + 1);
}

/// Calculates inverse hyperbolic sine
double _asinh(num x) {
  final xd = x.toDouble();

  return math.log(xd + math.sqrt(xd * xd + 1));
}

/// Calculates inverse hyperbolic cosine
double _acosh(num x) {
  final xd = x.toDouble();

  return math.log(xd + math.sqrt(xd * xd - 1));
}

/// Calculates inverse hyperbolic tangent
double _atanh(num x) {
  final xd = x.toDouble();

  return 0.5 * math.log((1 + xd) / (1 - xd));
}

/// Calculates gamma function using Lanczos approximation
double _gamma(num x) {
  final xd = x.toDouble();

  const g = 7;
  const coeffs = [
    0.99999999999980993,
    676.5203681218851,
    -1259.1392167224028,
    771.32342877765313,
    -176.61502916214059,
    12.507343278686905,
    -0.13857109526572012,
    9.9843695780195716e-6,
    1.5056327351493116e-7,
  ];

  if (xd < 0.5) return math.pi / (math.sin(math.pi * xd) * _gamma(1 - xd));

  final z = xd - 1;
  var x2 = coeffs[0];

  for (var i = 1; i < coeffs.length; i++) {
    x2 += coeffs[i] / (z + i);
  }

  final t = z + g + 0.5;
  final sqrt2Pi = math.sqrt(2 * math.pi);

  return sqrt2Pi * math.pow(t, z + 0.5) * math.exp(-t) * x2;
}

/// Calculates double factorial
int _factorial2(int n) {
  if (n <= 0) return 1;
  if (n == 1 || n == 2) return n;

  var result = 1;

  for (var i = n; i > 0; i -= 2) {
    result *= i;
  }

  return result;
}

/// Calculates greatest common divisor
int _gcd(int a, int b) {
  var x = a;
  var y = b;

  while (y != 0) {
    final temp = y;

    y = x % y;
    x = temp;
  }

  return x;
}
