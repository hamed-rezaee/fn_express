# Fn Express

A comprehensive Dart package for parsing and evaluating mathematical expressions with extensive support for variables, functions, constants, complex numbers, **expression simplification**, and **symbolic differentiation**. Features a robust expression parser, rich mathematical function library, symbolic manipulation capabilities, and interactive REPL environment.

## Live Demo

- [REPL](https://hamed-rezaee.github.io/flutter_fn_express_demo/)

## Table of Contents

- [Features](#features)
- [Quick Start Example](#quick-start-example)
- [Installation](#installation)
- [Mathematical Functions](#mathematical-functions)
- [Constants](#constants)
- [Symbolic Computation](#symbolic-computation)
- [Equation Solving](#equation-solving)
- [Interpolation & Extrapolation](#interpolation--extrapolation)
- [Usage Examples](#usage-examples)
- [Interactive REPL](#interactive-repl)
- [Error Handling](#error-handling)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Complete Arithmetic Support**: Basic operations (+, -, \*, /, %, ^) with proper operator precedence
- **Variable Management**: Define and use variables with assignment operations
- **Rich Function Library**: Extensive collection of mathematical functions including sign and clamp
- **Mathematical Constants**: Built-in constants (π, e, i, φ, τ)
- **Multiple Number Types**: Integers, doubles, and complex numbers with automatic type promotion
- **Expression Parsing**: Robust lexer and parser with error handling
- **Implicit Multiplication**: Natural syntax like `2x`, `3(x+1)`, `(a+b)(c+d)`
- **Expression Simplification**: Algebraic simplification with advanced rules
- **Symbolic Differentiation**: Compute derivatives symbolically with chain rule, product rule, and quotient rule
- **Symbolic Integration**: Produce antiderivatives and evaluate definite integrals with optional bounds
- **Higher-order Derivatives**: Compute nth derivatives and partial derivatives
- **Gradient Computation**: Calculate gradient vectors for multi-variable functions
- **Expression Analysis**: Analyze expressions for variables, functions, and complexity
- **Equation Solving**: Find numeric roots with Newton, secant, and bisection methods and inspect convergence diagnostics
- **Interpolation & Extrapolation**: Estimate intermediate or out-of-range values with piecewise-linear interpolation and extrapolation utilities
- **Sequence Synthesis**: Derive closed-form polynomials that reproduce user-provided numeric series
- **Interactive REPL**: Full-featured Read-Eval-Print Loop with symbolic computation, help system, variable management, and command history
- **Topic-Based Help**: Navigate REPL docs with searchable topics and per-command detail pages

## Mathematical Functions

### Basic Functions

- `sqrt(x)` - Square root (returns complex for negative inputs)
- `abs(x)` - Absolute value (magnitude for complex numbers)
- `ln(x)` - Natural logarithm
- `exp(x)` - Exponential function (e^x)

### Trigonometric Functions

- `sin(x)`, `cos(x)`, `tan(x)` - Standard trigonometric functions
- `sec(x)`, `csc(x)`, `cot(x)` - Secant, cosecant, and cotangent functions
- `asin(x)`, `acos(x)`, `atan(x)` - Inverse trigonometric functions

### Hyperbolic Functions

- `sinh(x)` - Hyperbolic sine
- `cosh(x)` - Hyperbolic cosine
- `tanh(x)` - Hyperbolic tangent
- `sech(x)` - Hyperbolic secant
- `csch(x)` - Hyperbolic cosecant
- `coth(x)` - Hyperbolic cotangent
- `asinh(x)` - Inverse hyperbolic sine
- `acosh(x)` - Inverse hyperbolic cosine (domain: x ≥ 1)
- `atanh(x)` - Inverse hyperbolic tangent (domain: -1 < x < 1)

### Rounding Functions

- `floor(x)` - Largest integer ≤ x
- `ceil(x)` - Smallest integer ≥ x
- `round(x)` - Nearest integer
- `trunc(x)` - Integer part (truncation towards zero)

### Special Functions

- `fact(x)` - Factorial (for non-negative integers)
- `factorial2(x)` - Double factorial (x!! = x*(x-2)*(x-4)...1 or 2)
- `gamma(x)` - Gamma function (generalization of factorial for real numbers > 0)
- `sign(x)` - Sign function (returns -1, 0, or 1)

### Multi-Argument Functions

- `complex(real, imag)` - Create complex numbers
- `log(value, base)` - Logarithm with custom base
- `pow(base, exponent)` - Power function
- `min(a, b, c, ...)` - Minimum of multiple values
- `max(a, b, c, ...)` - Maximum of multiple values
- `fraction(numerator, denominator)` - Create fractions
- `clamp(value, min, max)` - Clamp value between minimum and maximum bounds

### Number Theory Functions

- `gcd(a, b)` - Greatest common divisor
- `lcm(a, b)` - Least common multiple

### Statistical Functions

- `average(a, b, c, ...)` - Average (arithmetic mean) of multiple values
- `median(a, b, c, ...)` - Median of multiple values
- `mode(a, b, c, ...)` - Mode of multiple values (most frequent)
- `stdev(a, b, c, ...)` - Sample standard deviation of multiple values (minimum 2 required)
- `variance(a, b, c, ...)` - Sample variance of multiple values (minimum 2 required)

### Random Number Generation

- `random()` - Generate random number between 0 and 1

## Constants

- `pi` - Mathematical constant π (3.14159...)
- `e` - Mathematical constant e (2.71828...)
- `i` - Imaginary unit (√-1)
- `phi` - Golden ratio φ (1.61803...)
- `tau` - Mathematical constant τ = 2π (6.28318...)

## Symbolic Computation

### Expression Simplification

Automatically simplify mathematical expressions using algebraic rules:

```dart
import 'package:fn_express/fn_express.dart';

final interpreter = SymbolicInterpreter();

print(interpreter.simplify('x + 0'));          // x
print(interpreter.simplify('1 * x'));          // x
print(interpreter.simplify('x^1'));            // x
print(interpreter.simplify('x^0'));            // 1
print(interpreter.simplify('0 * x'));          // 0
print(interpreter.simplify('x - x'));          // 0
print(interpreter.simplify('2 + 3'));          // 5
print(interpreter.simplify('--x'));            // x
```

### Symbolic Differentiation

Compute derivatives symbolically with full support for chain rule, product rule, and quotient rule:

```dart
import 'dart:math' as math;

final interpreter = SymbolicInterpreter();

// Basic derivatives
print(interpreter.derivative('x^2', 'x'));              // 2 * x
print(interpreter.derivative('2*x^3 + 3*x + 1', 'x')); // 6 * x ^ 2 + 3

// Function derivatives
print(interpreter.derivative('sin(x)', 'x'));           // cos(x)
print(interpreter.derivative('ln(x)', 'x'));            // 1 / x
print(interpreter.derivative('exp(x)', 'x'));           // exp(x)

// Chain rule
print(interpreter.derivative('sin(x^2)', 'x'));         // cos(x ^ 2) * 2 * x

// Product rule
print(interpreter.derivative('x * sin(x)', 'x'));       // 1 * sin(x) + x * cos(x)

// Quotient rule
print(interpreter.derivative('x / (x + 1)', 'x'));      // (1 * (x + 1) - x * 1) / (x + 1) ^ 2

// Derivatives of reciprocal trig functions
print(interpreter.derivative('sec(x)', 'x'));           // sec(x) * tan(x)
print(interpreter.derivative('csc(x)', 'x'));           // -csc(x) * cot(x)
print(interpreter.derivative('cot(x)', 'x'));           // -csc(x) ^ 2

// Derivatives of hyperbolic functions
print(interpreter.derivative('sinh(x)', 'x'));          // cosh(x)
print(interpreter.derivative('cosh(x)', 'x'));          // sinh(x)
print(interpreter.derivative('tanh(x)', 'x'));          // 1 - tanh(x) ^ 2
print(interpreter.derivative('sech(x)', 'x'));          // -sech(x) * tanh(x)
print(interpreter.derivative('csch(x)', 'x'));          // -csch(x) * coth(x)
print(interpreter.derivative('coth(x)', 'x'));          // -csch(x) ^ 2
```

### Higher-order Derivatives

Compute nth derivatives easily:

```dart
final interpreter = SymbolicInterpreter();

print(interpreter.nthDerivative('x^4', 'x', 1));   // 4 * x ^ 3
print(interpreter.nthDerivative('x^4', 'x', 2));   // 12 * x ^ 2
print(interpreter.nthDerivative('x^4', 'x', 3));   // 24 * x
print(interpreter.nthDerivative('x^4', 'x', 4));   // 24
print(interpreter.nthDerivative('x^4', 'x', 5));   // 0
```

### Symbolic Integration

Compute antiderivatives and definite integrals:

```dart
final interpreter = SymbolicInterpreter();

// Indefinite integral (antiderivative)
final indefinite = interpreter.integral('sin(x)', 'x');
print(indefinite.expression);          // -cos(x)
print(indefinite.hasDefiniteValue);    // false

// Definite integral with numeric bounds
final definite = interpreter.integral(
  'sin(x)',
  'x',
  lowerBound: 0,
  upperBound: math.pi,
);

print(definite.expression);            // -cos(x)
print(definite.definiteValue?.value);  // 2
```

### Equation Solving

Solve single-variable equations numerically with Newton-Raphson, secant, and
bisection methods. Equations can be written implicitly (`f(x) = 0`) or with an
explicit equality (`lhs = rhs`). Each solution reports the root, residual,
iteration count, and the method that converged.

```dart
final solver = EquationSolver();

// Implicit equation f(x) = 0 with bracketing
final sqrt2 = solver.solve('x^2 - 2', 'x', lowerBound: 0, upperBound: 2);
print(sqrt2.root.value);    // 1.4142135623730951
print(sqrt2.method);        // bisection
print(sqrt2.residual);      // ~1.33e-15

// Equality form with an initial Newton guess
final trig = solver.solve('sin(x) = 0', 'x', initialGuess: 3.0);
print(trig.root.value);     // 3.141592653589793

// Solve directly through the symbolic interpreter
final symbolic = SymbolicInterpreter();
final cubic = symbolic.solveEquation('x^3 - 1 = 0', 'x', initialGuess: 0.5);
print(cubic.root.value);    // 1.0
print(cubic.iterations);    // iterations used by the solver
```

### Interpolation & Extrapolation

Estimate values between or beyond known data points with the
`InterpolationEngine`. Piecewise-linear interpolation is used for values inside
the domain, while the same model extends naturally to extrapolation when
requested.

```dart
final interpolator = InterpolationEngine();
final points = [
  Tuple2(0, 0),
  Tuple2(10, 20),
  Tuple2(20, 40),
];

// Interpolate inside the domain
final mid = interpolator.interpolateLinear(points, 7.5);
print(mid.value);            // 15.0

// Extrapolate beyond the largest x-value
final high = interpolator.extrapolateLinear(points, 30);
print(high.value);           // 60.0

// SymbolicInterpreter wrappers accept the same tuple format
final symbolic = SymbolicInterpreter();
final quick = symbolic.interpolateLinear(points, 12);
print(quick.value);          // 24.0

final outside = symbolic.extrapolateLinear(points, -5);
print(outside.value);        // -10.0
```

In the REPL you can evaluate the same calculations interactively:

```
>> interpolate 0:0,10:20,20:40 15
Interpolated value: 30
>> interpolate 0:0,10:20 25 extrapolate
Interpolated value: 50
>> sequence 2,5,8,11
Sequence expression: 3 * n + 2
```

### Sequence Formula Generation

Discover a simplified polynomial that reproduces a user-provided numeric
series. The generated expression is available both as a string and as an
evaluator for new terms.

```dart
final analyzer = SequenceAnalyzer();
final progression = analyzer.generatePolynomial([2, 5, 8, 11]);

print(progression.expression);   // 3 * n + 2
print(progression.termAt(20));   // 62.0

final symbolic = SymbolicInterpreter();
final squares = symbolic.sequenceFormula(
  [1, 4, 9, 16, 25],
  startIndex: 1,
);

print(squares.expression);       // n^2
print(squares.termAt(10));       // 100.0
```

### Partial Derivatives and Gradients

Handle multi-variable functions:

```dart
final interpreter = SymbolicInterpreter();

// Partial derivatives
print(interpreter.partialDerivative('x^2*y + y^3', 'x')); // 2 * x * y
print(interpreter.partialDerivative('x^2*y + y^3', 'y')); // x ^ 2 + 3 * y ^ 2

// Gradient vector
final gradient = interpreter.gradient('x^2 + y^2 + z', ['x', 'y', 'z']);
print('∇f = [${gradient['x']}, ${gradient['y']}, ${gradient['z']}]'); // ∇f = [2 * x, 2 * y, 1]
```

### Expression Analysis

Analyze expression structure and complexity:

```dart
final interpreter = SymbolicInterpreter();

final info = interpreter.analyzeExpression('sin(x^2) + cos(y) + z');
print('Variables: ${info.variables}');     // [x, y, z]
print('Functions: ${info.functions}');     // [sin, cos]
print('Node count: ${info.nodeCount}');    // 9
print('Max depth: ${info.maxDepth}');      // 3
print('Complexity: ${info.complexity}');   // 15
```

### Mixed Symbolic and Numeric Operations

Combine symbolic manipulation with numeric evaluation:

```dart
final interpreter = SymbolicInterpreter();

// Set up variables
interpreter.setVariable('a', DoubleValue(2.0));
interpreter.setVariable('x', DoubleValue(3.0));

// Parse symbolically
final ast = interpreter.parse('a*x^2 + 3*x + 1');
print('Expression: ${ast.toExpression()}');

// Simplify symbolically
final simplified = interpreter.simplifyAst(ast);
print('Simplified: ${simplified.toExpression()}');

// Differentiate symbolically
final derivative = interpreter.derivativeAst(simplified, 'x');
print('Derivative: ${derivative.toExpression()}');

// Evaluate numerically
final value = interpreter.evaluateAst(ast);
final derivValue = interpreter.evaluateAst(derivative);
print('f(3) = ${value.value}');      // 28.0
print('f\'(3) = ${derivValue.value}'); // 15.0
```

## Quick Start Example

```dart
import 'package:fn_express/fn_express.dart';

// Original numeric evaluation
final interpreter = Interpreter();
interpreter.eval('x = 10');
print(interpreter.eval('2 * x + sqrt(16)'));  // 24.0
print(interpreter.eval('sin(pi/2) + cos(0)'));  // 2.0

// Advanced trig and hyperbolic functions
print(interpreter.eval('sec(0) + csc(pi/2)'));  // 2.0
print(interpreter.eval('sinh(0) + cosh(0)'));   // 1.0

// Complex number exponentiation
print(interpreter.eval('i^2'));                 // -1.0 + 0.0i
print(interpreter.eval('complex(1,1)^2'));      // 0.0 + 2.0i

// New symbolic computation
final symbolic = SymbolicInterpreter();

// Expression simplification
print(symbolic.simplify('x + 0 + 1*y'));     // x + y
print(symbolic.simplify('2 + 3'));           // 5

// Symbolic differentiation
print(symbolic.derivative('x^2 + 2*x + 1', 'x'));  // 2 * x + 2
print(symbolic.derivative('sin(x^2)', 'x'));        // cos(x ^ 2) * 2 * x

// Higher-order derivatives
print(symbolic.nthDerivative('x^4', 'x', 2));      // 12 * x ^ 2

// Gradient computation
final grad = symbolic.gradient('x^2 + y^2', ['x', 'y']);
print('[${grad['x']}, ${grad['y']}]');              // [2 * x, 2 * y]

// Equation solving
final solver = EquationSolver();
final sqrt2Solution = solver.solve('x^2 - 2', 'x', lowerBound: 0, upperBound: 2);
print(sqrt2Solution.root.value);                   // 1.4142135623730951
print(sqrt2Solution.method);                       // bisection

final piSolution = symbolic.solveEquation('sin(x) = 0', 'x', initialGuess: 3.0);
print(piSolution.root.value);                      // 3.141592653589793
print(piSolution.iterations);                      // iterations used

// Interactive REPL with symbolic computation
// Run: dart run example/fn_express_example.dart
// Then try: simplify x+x+2*x → 4*x
// Or: derivative x^2+2*x+1 x → 2*x + 2
```

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  fn_express: <latest version>
```

Then import the package:

```dart
import 'package:fn_express/fn_express.dart';
```

## Usage Examples

### Basic Arithmetic

```dart
final interpreter = Interpreter();

// Simple calculations
print(interpreter.eval('2 + 3 * 4'));        // 14
print(interpreter.eval('(10 + 5) * 2'));     // 30
print(interpreter.eval('2^3^2'));            // 512 (right-associative)

// Modulo operation
print(interpreter.eval('17 % 5'));           // 2
print(interpreter.eval('10.5 % 3'));         // 1.5
```

### Variables

```dart
final interpreter = Interpreter();

// Variable assignment
interpreter.eval('x = 10');
interpreter.eval('y = 2 * x + 5');

print(interpreter.eval('x + y'));            // 35

// Reassignment
interpreter.eval('x = x + 1');

print(interpreter.eval('x'));                // 11
```

### Mathematical Functions

```dart
final interpreter = Interpreter();

// Basic functions
print(interpreter.eval('sqrt(16)'));         // 4.0
print(interpreter.eval('sqrt(-4)'));         // 2.0i (complex result)
print(interpreter.eval('abs(-5)'));          // 5.0

// Trigonometric functions
print(interpreter.eval('sin(pi/2)'));        // 1.0
print(interpreter.eval('cos(0)'));           // 1.0
print(interpreter.eval('tan(pi/4)'));        // 1.0

// New reciprocal trig functions
print(interpreter.eval('sec(0)'));           // 1.0 (1/cos(0))
print(interpreter.eval('csc(pi/2)'));        // 1.0 (1/sin(pi/2))
print(interpreter.eval('cot(pi/4)'));        // 1.0 (1/tan(pi/4))

// Hyperbolic functions
print(interpreter.eval('sinh(0)'));          // 0.0
print(interpreter.eval('cosh(0)'));          // 1.0
print(interpreter.eval('tanh(0)'));          // 0.0

// New hyperbolic reciprocal functions
print(interpreter.eval('sech(0)'));          // 1.0 (1/cosh(0))
print(interpreter.eval('csch(1)'));          // 0.8509... (1/sinh(1))
print(interpreter.eval('coth(1)'));          // 1.3130... (1/tanh(1))

// Inverse trig functions
print(interpreter.eval('atan(1)'));          // 0.7854 (π/4)

// Rounding functions
print(interpreter.eval('floor(3.7)'));       // 3
print(interpreter.eval('ceil(3.2)'));        // 4
print(interpreter.eval('round(3.7)'));       // 4

// Factorial and sign
print(interpreter.eval('fact(5)'));          // 120
print(interpreter.eval('fact(0)'));          // 1
print(interpreter.eval('sign(-3.5)'));       // -1
print(interpreter.eval('sign(0)'));          // 0

// Constants
print(interpreter.eval('phi'));              // 1.618... (golden ratio)
print(interpreter.eval('tau'));              // 6.283... (2π)
print(interpreter.eval('phi^2 - phi'));      // 1.0 (golden ratio property)
```

### Complex Numbers

```dart
final interpreter = Interpreter();

// Creating complex numbers
print(interpreter.eval('complex(3, 4)'));    // 3.0 + 4.0i
print(interpreter.eval('2 + 3i'));           // 2.0 + 3.0i

// Complex arithmetic
print(interpreter.eval('(2 + 3i) + (1 - 2i)')); // 3.0 + 1.0i
print(interpreter.eval('(2 + 3i) * (1 + i)'));  // -1.0 + 5.0i
print(interpreter.eval('abs(3 + 4i)'));         // 5.0 (magnitude)

// Complex exponentiation (NEW!)
print(interpreter.eval('i^2'));                 // -1.0 + 0.0i
print(interpreter.eval('complex(1, 1)^2'));     // 0.0 + 2.0i
print(interpreter.eval('(2+i)^3'));             // Complex power operations
```

### Advanced Functions

```dart
final interpreter = Interpreter();

// Logarithms
print(interpreter.eval('ln(e)'));             // 1.0
print(interpreter.eval('log(100, 10)'));      // 2.0
print(interpreter.eval('log(8, 2)'));         // 3.0

// Min/Max/Clamp with variable arguments
print(interpreter.eval('min(5, 3)'));              // 3
print(interpreter.eval('min(5, 2, 8, 1, 9)'));      // 1
print(interpreter.eval('max(2.5, 3.7)'));          // 3.7
print(interpreter.eval('max(5, 2, 8, 1, 9)'));      // 9
print(interpreter.eval('clamp(15, 0, 10)'));       // 10
print(interpreter.eval('clamp(-5, 0, 10)'));       // 0

// Power functions
print(interpreter.eval('pow(2, 8)'));         // 256.0
print(interpreter.eval('2^8'));               // 256 (same as above)
```

### Implicit Multiplication

```dart
final interpreter = Interpreter();

interpreter.eval('x = 5');
print(interpreter.eval('2x'));               // 10 (2 * x)
print(interpreter.eval('3(x + 1)'));         // 18 (3 * (x + 1))
print(interpreter.eval('(x + 1)(x - 1)'));   // 24 ((x + 1) * (x - 1))
```

### Multi-Parameter Functions

```dart
final interpreter = Interpreter();

// Statistical functions with multiple arguments
print(interpreter.eval('average(1, 2, 3, 4, 5)'));    // 3.0
print(interpreter.eval('median(1, 2, 3, 4, 5)'));     // 3.0
print(interpreter.eval('median(10, 5, 15, 20)'));     // 12.5
print(interpreter.eval('stdev(1, 2, 3, 4, 5)'));      // 1.58...
print(interpreter.eval('variance(2, 4, 6, 8)'));      // 6.67...

// Min/Max with multiple values
print(interpreter.eval('min(5, 2, 8, 1, 9, 3)'));     // 1
print(interpreter.eval('max(5, 2, 8, 1, 9, 3)'));     // 9

// Mode with multiple occurrences
print(interpreter.eval('mode(1, 2, 2, 3, 2, 4)'));    // 2
```

### Real-World Examples

```dart
final interpreter = Interpreter();

// Physics: Kinetic energy calculation
interpreter.eval('mass = 10');      // kg
interpreter.eval('velocity = 25');  // m/s
print(interpreter.eval('0.5 * mass * velocity^2'));  // 3125 Joules

// Geometry: Circle area and circumference
interpreter.eval('radius = 5');
print(interpreter.eval('pi * radius^2'));      // Area: 78.54
print(interpreter.eval('2 * pi * radius'));    // Circumference: 31.42

// Statistics: Data analysis
interpreter.eval('data = average(23, 45, 56, 78, 12, 67, 89, 34)');
print(interpreter.eval('data'));                        // 50.5
print(interpreter.eval('stdev(23, 45, 56, 78, 12, 67, 89, 34)'));  // Standard deviation

// Finance: Compound interest
interpreter.eval('principal = 1000');
interpreter.eval('rate = 0.05');
interpreter.eval('time = 10');
print(interpreter.eval('principal * (1 + rate)^time'));  // 1628.89

// Engineering: Pythagorean theorem in 3D
interpreter.eval('x = 3; y = 4; z = 12');
print(interpreter.eval('sqrt(x^2 + y^2 + z^2)'));      // 13.0
```

### Advanced Mathematical Operations

```dart
final interpreter = Interpreter();

// Complex number calculations (electrical engineering)
interpreter.eval('z1 = 3 + 4i');
interpreter.eval('z2 = 1 - 2i');
print(interpreter.eval('z1 * z2'));          // 11.0 - 2.0i
print(interpreter.eval('abs(z1)'));          // 5.0 (magnitude)

// Trigonometric identities verification
print(interpreter.eval('sin(pi/3)^2 + cos(pi/3)^2'));   // 1.0
print(interpreter.eval('tan(pi/4)'));                    // 1.0

// Logarithmic and exponential relationships
print(interpreter.eval('ln(exp(5))'));       // 5.0
print(interpreter.eval('log(10^3, 10)'));    // 3.0

// Statistical analysis
final data = 'stdev(12, 15, 18, 22, 25, 28, 31, 34, 37, 40)';
print(interpreter.eval(data));               // Sample standard deviation
```

### Interactive REPL

The package includes a powerful REPL (Read-Eval-Print Loop) for interactive mathematical expression evaluation with **symbolic computation support**. The REPL provides:

- **Comprehensive Help System**: Built-in documentation for all operators, functions, constants, and symbolic commands
- **Topic-Based Navigation**: Use `help topics`, `help <section>`, or `help <command>` to jump directly to what you need
- **Symbolic Computation**: Interactive expression simplification, differentiation, integration, and analysis
- **Mixed Operations**: Seamlessly combine numeric evaluation with symbolic manipulation
- **Variable Management**: Persistent variables across expressions with viewing and clearing capabilities
- **Error Handling**: Clear error messages for invalid expressions or operations
- **Command History**: Easy access to previously entered expressions
- **Categorized Documentation**: Separate help sections for operators, functions, constants, symbolic operations, and examples
- **Clean Interface**: User-friendly command-line interface with clear prompts and formatting

#### Usage

To use the REPL:

```dart
var isRunning = true;

final repl = Repl(
  (output, {newline = true}) =>
      newline ? stdout.writeln(output) : stdout.write(output),
);

while (isRunning) {
  stdout.write('>> ');
  final input = stdin.readLineSync();

  (input == null || input.toLowerCase() == 'exit')
      ? isRunning = false
      : repl(input);
}
```

```
╭─────────────────────────────────────╮
│          Fn Express REPL            │
│   Mathematical Expression Parser    │
╰─────────────────────────────────────╯

Enter mathematical expressions or type "help" for assistance.
Type "exit" to quit.

>> x = 10
10
>> y = 2 * x + sqrt(16)
24
>> sin(pi/2) + cos(0)
2.0
>> fact(5) % 7
1
>> simplify x + x + 2*x
4*x
>> derivative x^2+2*x+1 x
2*x + 2
>> 2*x + 2
22
>> help
═══════════════════ HELP ═══════════════════

COMMANDS:
  help              Show this help message
  help operators    Show available operators
  help functions    Show available functions
  help constants    Show available constants
  help symbolic     Show symbolic computation commands
  help examples     Show usage examples
  variables         Show defined variables
  clear             Clear all variables
  version           Show version info
  exit              Exit the REPL

BASIC USAGE:
  • Enter expressions: 2 + 3 * 4
  • Assign variables: x = 10
  • Use functions: sin(pi/2)
  • Implicit multiplication: 2x, 3(x+1)

PRIMARY TOPICS
  help topics          List every help topic
  help commands        Command reference grouped by category
  help numeric         Numeric solvers, interpolation, sequences
  help symbolic        Simplification, derivatives, integrals, gradients
  help basics          Input syntax, assignments, and tips
  help operators       Operator list and precedence
  help functions       Built-in math functions
  help constants       Built-in constants such as pi and e
  help examples        Sample REPL interactions

COMMAND SNAPSHOT
SESSION
  help | ?            Show the overview or a specific topic
  exit                Leave the REPL
  version             Display version info

STATE
  variables | vars    List variables you have defined
  clear               Remove all stored variables

Tip: Try `help solve`, `help sequence`, or any other command name for detailed usage.

>> help solve
════════ COMMAND DETAIL ═══════════════════

Command: solve <expression> <variable> [initial] | [lower upper]
Aliases: (none)
Category: Numeric

Find numeric roots of an equation.

Usage:
  solve <expression> <variable> [initial guess]
  solve <expression> <variable> [lower upper]

Examples:
  >> solve x^2 - 2 x 0 2
  Solution: x = 1.4142135623730951
  Method: Bisection

>> exit

Thanks for using Fn Express REPL! Goodbye!
```

#### REPL Commands

The REPL supports the following special commands:

##### General Commands

- `help` or `?` - Show general help information
- `help operators` - Display all available operators with examples
- `help functions` - Show all mathematical functions and their usage
- `help constants` - List all built-in constants
- `help symbolic` - Show symbolic computation commands and examples
- `help examples` - Show comprehensive usage examples
- `variables` or `vars` - Display all currently defined variables
- `clear` - Clear all defined variables
- `version` - Show REPL version information
- `exit` - Exit the REPL

##### Symbolic Computation Commands

The REPL now includes powerful symbolic computation capabilities:

- `simplify <expression>` - Algebraically simplify expressions
- `derivative <expression> <variable>` - Compute first derivative
- `nthderivative|nthderiv <expression> <variable> <order>` - Compute higher-order derivatives using the shorthand alias if you prefer
- `integrate <expression> <variable> [lower upper]` - Compute antiderivatives or definite integrals with optional bounds
- `gradient <expression> <var1,var2,...>` - Compute gradient vector
- `analyze <expression>` - Analyze expression structure and properties

**Symbolic Examples in REPL:**

```
>> simplify x + x + 2*x
4*x

>> derivative x^2+2*x+1 x
2*x + 2

>> nthderivative x^4 x 2
12*x^2

>> integrate sin(x) x
-cos(x) + C

>> integrate sin(x) x 0 pi
Antiderivative: -cos(x)
Definite value: 2

>> gradient x^2+y^2 x,y
Gradient:
  ∂/∂x: 2*x
  ∂/∂y: 2*y

>> x = 5
5

>> 2*x + 2
12
```

## Error Handling

The package provides comprehensive error handling:

```dart
final interpreter = Interpreter();

try {
  interpreter.eval('10 / 0');
} catch (e) {
  print(e); // ArgumentError: Division by zero
}

try {
  interpreter.eval('asin(2)');
} catch (e) {
  print(e); // ArgumentError: Arcsine domain error
}

try {
  interpreter.eval('fact(-1)');
} catch (e) {
  print(e); // ArgumentError: Factorial only defined for non-negative integers
}
```

## Architecture

The package consists of several key components working together:

- **Lexer**: Tokenizes mathematical expressions into meaningful symbols
- **Parser**: Converts infix notation to postfix (RPN) using the Shunting Yard algorithm
- **Evaluator**: Evaluates postfix expressions using an efficient stack-based approach
- **Interpreter**: Coordinates the entire process and manages variables/functions
- **AST (Abstract Syntax Tree)**: Structured representation enabling symbolic operations
- **AstBuilder**: Converts parsed expressions into manipulable tree structures
- **ExpressionSimplifier**: Advanced algebraic simplification engine
- **DifferentiationEngine**: Symbolic differentiation with full calculus rule support
- **SymbolicInterpreter**: Enhanced interpreter combining numeric and symbolic capabilities
- **NumberValue**: Flexible type system supporting integers, doubles, and complex numbers
- **REPL**: Interactive environment with symbolic computation commands, comprehensive help, and variable management

### Type System

The package uses automatic type promotion to handle different number types seamlessly:

```
Integer → Double  → Complex
5       → 5.0     → 5.0 + 0.0i
```

This ensures that operations always produce mathematically correct results while maintaining performance.

## Use Cases

Fn Express is ideal for:

- **Educational Software**: Teaching mathematical concepts with interactive calculations
- **Scientific Applications**: Complex mathematical computations in research
- **Engineering Tools**: Formula-based calculations and simulations
- **Financial Software**: Interest calculations, statistical analysis
- **Game Development**: Mathematical systems, physics calculations
- **Data Analysis**: Statistical computations and data processing
- **Calculator Applications**: Building advanced calculator functionality

```dart
final interpreter = Interpreter();

for (final expression in expressions) {
  try {
    final result = interpreter.eval(expression);
    print('$expression = $result');
  } catch (e) {
    print('Error evaluating $expression: $e');
  }
}
```

## Contributing

We welcome contributions! Here's how you can help:

1. **Bug Reports**: Open an issue with detailed reproduction steps
2. **Feature Requests**: Suggest new mathematical functions or features
3. **Code Contributions**: Submit pull requests with tests and documentation
4. **Documentation**: Improve examples, fix typos, or add use cases

### Development Setup

```bash
git clone https://github.com/hamed-rezaee/fn_express.git
cd fn_express
dart pub get
dart test
```

For major changes, please open an issue first to discuss the proposed changes.

## License

This project is licensed under the MIT License - see the [LICENSE](/LICENSE) file for details.

## Resources

- **Package Homepage**: [pub.dev](https://pub.dev/packages/fn_express)
- **Repl Live Demo**: [Repl Demo](https://hamed-rezaee.github.io/flutter_fn_express_demo)
- **Source Code**: [GitHub Repository](https://github.com/hamed-rezaee/fn_express)
- **Issue Tracker**: [GitHub Issues](https://github.com/hamed-rezaee/fn_express/issues)
- **API Documentation**: [pub.dev documentation](https://pub.dev/documentation/fn_express)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)
