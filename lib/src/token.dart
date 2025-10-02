import 'package:fn_express/src/number_value.dart';

/// Supported operators:
/// - `+` (addition): precedence 2, left-associative
/// - `-` (subtraction): precedence 2, left-associative
/// - `*` (multiplication): precedence 3, left-associative
/// - `/` (division): precedence 3, left-associative
/// - `%` (modulo): precedence 3, left-associative
/// - `^` (exponentiation): precedence 4, right-associativestract base class representing a lexical token in mathematical expressions.
///
/// Tokens are the basic building blocks created during the lexical analysis
/// phase of expression parsing. Each token represents a meaningful unit
/// such as numbers, operators, functions, or variables.
///
/// All concrete token types extend this class and provide specific behavior
/// for their token category.
abstract class Token {
  /// Creates a new token with the specified [value].
  ///
  /// The [value] represents how this token appears in the original expression.
  Token(this.value);

  /// The string representation of this token as it appears in the source expression.
  final String value;

  @override
  String toString() => value;
}

/// A token representing a numeric literal in a mathematical expression.
///
/// This token type encapsulates both the string representation of a number
/// as it appears in the expression and its parsed numeric value.
///
/// Example:
/// ```dart
/// final token = NumberToken('3.14', DoubleValue(3.14));
/// ```
class NumberToken extends Token {
  /// Creates a number token with the given string [value] and parsed [number].
  ///
  /// The [value] is the original string representation, while [number]
  /// contains the parsed numeric value.
  NumberToken(this.number, super.value);

  /// The parsed numeric value of this token.
  ///
  /// This contains the actual numeric value (IntegerValue, DoubleValue, etc.)
  /// that this token represents.
  final NumberValue number;
}

/// A token representing a mathematical operator in an expression.
///
/// This token handles binary operators such as +, -, *, /, and ^ (exponentiation).
/// Each operator has an associated precedence level and associativity rule
/// that determines the order of operations during expression evaluation.
///
/// Supported operators:
/// - `+` (addition): precedence 2, left-associative
/// - `-` (subtraction): precedence 2, left-associative
/// - `*` (multiplication): precedence 3, left-associative
/// - `/` (division): precedence 3, left-associative
/// - `^` (exponentiation): precedence 4, right-associative
class OperatorToken extends Token {
  /// Creates an operator token with the specified operator [value].
  OperatorToken(super.value);

  /// Returns the precedence level of this operator.
  ///
  /// Higher precedence operators are evaluated before lower precedence ones.
  /// Precedence levels:
  /// - 4: `^` (exponentiation)
  /// - 3: `*`, `/`, `%` (multiplication, division, modulo)
  /// - 2: `+`, `-` (addition, subtraction)
  /// - 0: unknown operators (default)
  int get precedence => switch (value) {
        '^' => 4,
        '*' || '/' || '%' => 3,
        '+' || '-' => 2,
        _ => 0,
      };

  /// Returns whether this operator is left-associative.
  ///
  /// Left-associative operators are evaluated from left to right when
  /// they have the same precedence. The exponentiation operator (^) is
  /// right-associative, while all others are left-associative.
  ///
  /// Example:
  /// - `2 + 3 + 4` → `(2 + 3) + 4` (left-associative)
  /// - `2 ^ 3 ^ 2` → `2 ^ (3 ^ 2)` (right-associative)
  bool get isLeftAssociative => value != '^';
}

/// A specialized token representing the unary minus operator.
///
/// This token is used to distinguish between the binary subtraction operator
/// and the unary minus operator (negation). The unary minus has higher
/// precedence than binary operators to ensure correct evaluation order.
///
/// Example:
/// ```dart
/// // In the expression "-5 + 3", the first "-" is a unary minus
/// final token = UnaryMinusToken();
/// ```
class UnaryMinusToken extends OperatorToken {
  /// Creates a unary minus token.
  ///
  /// The token value is set to 'u-' internally to distinguish it from
  /// the binary subtraction operator.
  UnaryMinusToken() : super('u-');

  /// Returns the precedence level for the unary minus operator.
  ///
  /// Unary minus has the highest precedence (5) among all operators
  /// to ensure it's evaluated before any binary operations.
  @override
  int get precedence => 5;
}

/// A token representing a function name in a mathematical expression.
///
/// Function tokens are identified by name and are followed by parentheses
/// containing their arguments. Examples include 'sin', 'cos', 'sqrt', etc.
///
/// Example:
/// ```dart
/// final token = FunctionToken('sqrt');
/// ```
class FunctionToken extends Token {
  /// Creates a function token with the specified function [value] name.
  FunctionToken(super.value);
}

/// A token representing a variable name in a mathematical expression.
///
/// Variables are user-defined identifiers that can store and retrieve
/// numeric values during expression evaluation.
///
/// Example:
/// ```dart
/// final token = VariableToken('x');
/// ```
class VariableToken extends Token {
  /// Creates a variable token with the specified variable [value] name.
  VariableToken(super.value);
}

/// A token representing a mathematical constant in an expression.
///
/// Constants are predefined values such as 'pi', 'e', or 'i' (imaginary unit)
/// that have fixed mathematical meanings.
///
/// Example:
/// ```dart
/// final token = ConstantToken('pi');
/// ```
class ConstantToken extends Token {
  /// Creates a constant token with the specified constant [value] name.
  ConstantToken(super.value);
}

/// A token representing a left parenthesis '(' in a mathematical expression.
///
/// Left parentheses are used to group sub-expressions and denote function
/// argument lists. They must be matched with corresponding right parentheses.
class LeftParenToken extends Token {
  /// Creates a left parenthesis token.
  LeftParenToken() : super('(');
}

/// A token representing a right parenthesis ')' in a mathematical expression.
///
/// Right parentheses close groups opened by left parentheses and end
/// function argument lists.
class RightParenToken extends Token {
  /// Creates a right parenthesis token.
  RightParenToken() : super(')');
}

/// A token representing a comma ',' used to separate function arguments.
///
/// Commas are used within function calls to separate multiple arguments,
/// such as in 'complex(2, 3)'.
class CommaToken extends Token {
  /// Creates a comma token.
  CommaToken() : super(',');
}
