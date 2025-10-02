# Fn Express

A powerful Dart package for parsing and evaluating mathematical expressions with support for variables, functions, constants, and complex numbers.

## Features

- **Complete Arithmetic Support**: Basic operations (+, -, \*, /, %, ^) with proper operator precedence
- **Variable Management**: Define and use variables with assignment operations
- **Rich Function Library**: Extensive collection of mathematical functions including sign and clamp
- **Mathematical Constants**: Built-in constants (π, e, i, φ, τ)
- **Multiple Number Types**: Integers, doubles, and complex numbers with automatic type promotion
- **Expression Parsing**: Robust lexer and parser with error handling
- **Implicit Multiplication**: Natural syntax like `2x`, `3(x+1)`, `(a+b)(c+d)`
- **Interactive REPL**: Full-featured Read-Eval-Print Loop with help system, variable management, and command history

## Mathematical Functions

### Basic Functions

- `sqrt(x)` - Square root (returns complex for negative inputs)
- `abs(x)` - Absolute value (magnitude for complex numbers)
- `ln(x)` - Natural logarithm
- `exp(x)` - Exponential function (e^x)

### Trigonometric Functions

- `sin(x)`, `cos(x)`, `tan(x)` - Standard trigonometric functions
- `asin(x)`, `acos(x)`, `atan(x)` - Inverse trigonometric functions

### Hyperbolic Functions

- `sinh(x)` - Hyperbolic sine
- `cosh(x)` - Hyperbolic cosine
- `tanh(x)` - Hyperbolic tangent
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

## What's New in v1.2.0

🎉 **Major Function Expansion!** We've added 15+ new mathematical functions:

### New Functions Added:

- **Hyperbolic Functions**: `sinh()`, `cosh()`, `tanh()`, `asinh()`, `acosh()`, `atanh()`
- **Exponential**: `exp()` (e^x)
- **Special Math**: `gamma()`, `factorial2()` (double factorial)
- **Number Theory**: `gcd()`, `lcm()`
- **Statistics**: `average()`, `median()`, `mode()`, `stdev()`, `variance()`
- **Random**: `random()` for random number generation

### Quick Examples:

```dart
final interpreter = Interpreter();

// Hyperbolic functions
print(interpreter.eval('sinh(1)').value);     // 1.175...
print(interpreter.eval('tanh(0.5)').value);   // 0.462...

// Special functions
print(interpreter.eval('gamma(5)').value);    // 24 (same as 4!)
print(interpreter.eval('factorial2(6)').value); // 48 (6*4*2)

// Statistics
print(interpreter.eval('average(1, 2, 3, 4, 5)').value); // 3.0
print(interpreter.eval('median(3, 7)').value);        // 5.0
print(interpreter.eval('median(1, 2, 3, 4, 5)').value); // 3.0
print(interpreter.eval('stdev(2, 8)').value);         // 4.24...
print(interpreter.eval('stdev(1, 2, 3, 4, 5)').value); // 1.58...

// Number theory
print(interpreter.eval('gcd(48, 18)').value);    // 6
```

## Getting Started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  fn_express: ^1.2.0
```

Then import the package:

```dart
import 'package:fn_express/fn_express.dart';
```

## Usage

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

### Combined Examples

```dart
final interpreter = Interpreter();

// Complex mathematical expressions
interpreter.eval('a = 3');
interpreter.eval('b = 4');
print(interpreter.eval('sqrt(a^2 + b^2)'));  // 5.0 (Pythagorean theorem)

// Trigonometry with variables
interpreter.eval('angle = pi/4');
print(interpreter.eval('sin(angle)^2 + cos(angle)^2')); // 1.0

// Mixed operations with rounding
print(interpreter.eval('floor(sqrt(50)) + ceil(pi)')); // 11 (7 + 4)
```

### Interactive REPL

The package includes a powerful REPL (Read-Eval-Print Loop) for interactive mathematical expression evaluation. The REPL provides:

- **Comprehensive Help System**: Built-in documentation for all operators, functions, and constants
- **Variable Management**: Persistent variables across expressions with viewing and clearing capabilities
- **Error Handling**: Clear error messages for invalid expressions or operations
- **Command History**: Easy access to previously entered expressions
- **Categorized Documentation**: Separate help sections for operators, functions, constants, and examples
- **Clean Interface**: User-friendly command-line interface with clear prompts and formatting

#### Usage

To start the REPL:

```bash
dart run example/fn_express_example.dart
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
>> help
═══════════════════ HELP ═══════════════════

COMMANDS:
  help              Show this help message
  help operators    Show available operators
  help functions    Show available functions
  help constants    Show available constants
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

>> exit

Thanks for using Fn Express REPL! Goodbye!
```

#### REPL Commands

The REPL supports the following special commands:

- `help` or `?` - Show general help information
- `help operators` - Display all available operators with examples
- `help functions` - Show all mathematical functions and their usage
- `help constants` - List all built-in constants
- `help examples` - Show comprehensive usage examples
- `variables` or `vars` - Display all currently defined variables
- `clear` - Clear all defined variables
- `version` - Show REPL version information
- `exit` - Exit the REPL

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

The package consists of several key components:

- **Lexer**: Tokenizes mathematical expressions
- **Parser**: Converts infix notation to postfix (RPN) using the Shunting Yard algorithm
- **Evaluator**: Evaluates postfix expressions using a stack-based approach
- **Interpreter**: Coordinates the process and manages variables/functions
- **NumberValue**: Type system supporting integers, doubles, and complex numbers

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](/LICENSE) file for details.

## Additional Information

- **Package Homepage**: [GitHub Repository](https://github.com/hamed-rezaee/fn_express)
- **Issue Tracker**: [GitHub Issues](https://github.com/hamed-rezaee/fn_express/issues)
- **Documentation**: API documentation is available on [pub.dev](https://pub.dev/packages/fn_express)

For questions or suggestions, please feel free to open an issue on GitHub.
