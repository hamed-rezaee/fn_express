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
/// - Built-in mathematical constants (pi, e, i)
/// - Basic arithmetic operators (+, -, *, /, %, ^)
/// - Built-in functions (sqrt, ln, sin, cos, tan, abs, asin, acos, atan)
/// - Rounding functions (floor, ceil, round, trunc)
/// - Special functions (fact - factorial)
/// - Multi-argument functions (complex, log, pow, min, max, fraction)
/// - Support for complex number arithmetic
/// - Expression parsing and evaluation
///
/// Example:
/// ```dart
/// final interpreter = Interpreter();
/// interpreter.eval('x = 5');
/// final result = interpreter.eval('2 * x + sqrt(16) + ln(e) + log(100, 10)');
/// print(result); // Output depends on calculation
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
          if (args.any((arg) => arg is ComplexValue)) {
            throw ArgumentError(
              'Min function not supported for complex numbers.',
            );
          }

          final val1 = args[0].value as num;
          final val2 = args[1].value as num;
          final result = math.min(val1, val2);

          if (args[0] is IntegerValue && args[1] is IntegerValue) {
            return IntegerValue(result.toInt());
          }

          return DoubleValue(result.toDouble());
        },
        2,
      ),
      'max': Tuple2(
        (args) {
          if (args.any((arg) => arg is ComplexValue)) {
            throw ArgumentError(
              'Max function not supported for complex numbers.',
            );
          }

          final val1 = args[0].value as num;
          final val2 = args[1].value as num;
          final result = math.max(val1, val2);

          if (args[0] is IntegerValue && args[1] is IntegerValue) {
            return IntegerValue(result.toInt());
          }

          return DoubleValue(result.toDouble());
        },
        2,
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
  final Map<String, NumberValue> constants = {
    'pi': DoubleValue(math.pi),
    'e': DoubleValue(math.e),
    'i': ComplexValue(const Complex(0, 1)),
  };

  /// Map of single-argument mathematical functions.
  ///
  /// Includes:
  /// - `sqrt`: Square root (returns complex for negative inputs)
  /// - `ln`: Natural logarithm (base e)
  /// - `sin`, `cos`, `tan`: Trigonometric functions
  /// - `asin`, `acos`, `atan`: Inverse trigonometric functions
  /// - `abs`: Absolute value (magnitude for complex numbers)
  /// - `floor`, `ceil`, `round`, `trunc`: Rounding functions
  /// - `fact`: Factorial function
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
  };

  /// Map of multi-argument functions with their implementations and argument counts.
  ///
  /// Each entry contains a tuple with the function implementation and the
  /// required number of arguments.
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
  /// final result1 = interpreter.eval('2 + 3'); // Returns IntegerValue(5)
  /// final result2 = interpreter.eval('x = 10'); // Assigns and returns IntegerValue(10)
  /// final result3 = interpreter.eval('sqrt(x)'); // Returns DoubleValue(3.162...)
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

    final allFunctionNames = functions.keys.toSet()
      ..addAll(multiArgFunctions.keys);
    final lexer = Lexer(expression, allFunctionNames, constants.keys.toSet());
    final tokens = lexer.tokenize();

    final parser = Parser(tokens);
    final rpnQueue = parser.toPostfix();

    final evaluator = Evaluator(rpnQueue, this);

    return evaluator.evaluate();
  }
}
