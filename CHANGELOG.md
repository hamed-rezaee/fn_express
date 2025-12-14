## 2.1.4

- enforce line length lint rule and add build assets

## 2.1.3

- add ignore_for_file: lines_longer_than_80_chars to sources

## 2.1.2

- Update dependencies

## 2.1.1

- Update dependencies

## 2.1.0

### Improved

- **REPL Help System**: Redesigned `help` experience with a searchable topic index, command summaries, and detailed command pages (`help <command>`)

## 2.0.0

### Added - Major Symbolic Computation Features

- **Expression Simplification**: Advanced algebraic simplification with sophisticated rules
  - Automatic constant folding and algebraic identity application
  - Distributive, associative, and commutative law handling
  - Trigonometric identity simplification
  - Logarithmic and exponential rule application
  - Smart term combination and optimization
- **Symbolic Differentiation**: Complete symbolic differentiation engine
  - Support for all standard calculus rules (product, quotient, chain rule)
  - Differentiation of trigonometric, exponential, and logarithmic functions
  - Hyperbolic function derivatives
  - Inverse trigonometric function derivatives
  - Power rule with generalized exponents
- **Higher-order Derivatives**: Compute nth derivatives symbolically
  - Automatic application of differentiation rules multiple times
  - Support for any order derivative
- **Partial Derivatives and Gradients**: Multi-variable calculus support
  - Partial derivative computation treating other variables as constants
  - Gradient vector calculation for multi-variable functions
  - Complete support for multi-variable optimization
- **Abstract Syntax Tree (AST)**: Internal expression representation
  - Structured tree representation of mathematical expressions
  - Enables advanced symbolic manipulations
  - Foundation for all symbolic operations
- **Expression Analysis**: Structural analysis and complexity metrics
  - Variable and function detection
  - Expression complexity scoring
  - AST depth and node count analysis
- **SymbolicInterpreter**: Enhanced interpreter with symbolic capabilities
  - Seamless integration of symbolic and numeric operations
  - Backward compatibility with existing Interpreter
  - Mixed symbolic/numeric workflows
- New AST-based expression representation system
- Advanced simplification engine with multiple rule passes
- Robust differentiation engine supporting complex expressions
- Enhanced type system for symbolic computation
- Symbolic integration supporting both indefinite and definite integrals
  - Accepts optional lower/upper bounds that are evaluated using the interpreter
  - Displays both the antiderivative and numeric result when bounds are provided
  - Expanded REPL help and examples to cover the full function library, including matrix utilities and hyperbolic functions
- Equation solver for single-variable equations with Newton, secant, and bisection methods
  - Exposes `EquationSolver` API and `SymbolicInterpreter.solveEquation`
  - Adds `solve` command to the REPL with usage guidance
  - Documents new capabilities in README and quick-start examples
- Piecewise-linear interpolation and extrapolation utilities
  - Provides `InterpolationEngine` plus `SymbolicInterpreter` wrappers
  - Adds `interpolate` command in the REPL with optional `extrapolate` flag
  - Expands README examples to cover interpolation workflows
- **Sequence Analyzer**: discover closed-form polynomials from finite numeric series
  - Provides `SequenceAnalyzer.generatePolynomial` with forward-difference synthesis
  - Returns evaluators and metadata alongside the simplified expression
- **SymbolicInterpreter.sequenceFormula**: high-level entry point for sequence synthesis
- **REPL sequence command**: interactively build polynomial formulas from numeric series (`sequence`)
- Comprehensive documentation and tests covering the new capability

## 1.1.3

- Minor `Repl` refactor

## 1.1.2

- Update `README.md`

## 1.1.1

- Refined REPL support with removal of `dart:io` dependency

## 1.1.0

### Added

- **Multi-Parameter Support**: Statistical and utility functions now support variable arguments
  - `average(a, b, c, ...)` - Calculates average multiple values
  - `median(a, b, c, ...)` - Calculate median of multiple values
  - `mode(a, b, c, ...)` - Find mode of multiple values
  - `stdev(a, b, c, ...)` - Standard deviation of multiple values (minimum 2 required)
  - `variance(a, b, c, ...)` - Variance of multiple values (minimum 2 required)
  - `min(a, b, c, ...)` - Minimum of multiple values
  - `max(a, b, c, ...)` - Maximum of multiple values
- Enhanced argument parsing to handle nested function calls correctly
- Backward compatibility maintained for existing two-parameter usage
- Comprehensive test suite for multi-parameter functionality
- **Hyperbolic Functions**: sinh, cosh, tanh, asinh, acosh, atanh
- **Basic Mathematical Functions**: exp (exponential function e^x)
- **Special Mathematical Functions**:
  - gamma function (generalization of factorial)
  - factorial2 (double factorial)
- **Number Theory Functions**: gcd (greatest common divisor), lcm (least common multiple)
- **Statistical Functions**: median, mode, stdev (standard deviation), variance
- **Random Number Generation**: random() function
- Comprehensive test coverage for all new functions
- Updated documentation and examples

## 1.0.0

- Initial version
