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
