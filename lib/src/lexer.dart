import 'package:fn_express/fn_express.dart';

/// A lexical analyzer that tokenizes mathematical expressions into individual tokens.
///
/// The lexer scans through a string expression character by character and
/// converts it into a sequence of tokens that can be parsed and evaluated.
/// It handles numbers, operators, functions, variables, constants, and parentheses.
///
/// The lexer also implements implicit multiplication, automatically inserting
/// multiplication operators where they are implied (e.g., "2x" becomes "2*x").
///
/// Example:
/// ```dart
/// final functions = {'sin', 'cos', 'sqrt'};
/// final constants = {'pi', 'e', 'i'};
/// final lexer = Lexer('2*sin(pi)', functions, constants);
/// final tokens = lexer.tokenize();
/// ```
class Lexer {
  /// Creates a new lexer for the given [expression].
  ///
  /// The [knownFunctions] and [knownConstants] sets are used to distinguish
  /// between functions, constants, and variables when processing identifiers.
  ///
  /// Parameters:
  /// - [expression]: The mathematical expression to tokenize
  /// - [knownFunctions]: Set of recognized function names
  /// - [knownConstants]: Set of recognized constant names
  Lexer(
    String expression,
    Set<String> knownFunctions,
    Set<String> knownConstants,
  )   : _expression = expression,
        _knownFunctions = knownFunctions,
        _knownConstants = knownConstants;

  /// The mathematical expression string to tokenize.
  final String _expression;

  /// Current position in the expression being processed.
  int _currentIndex = 0;

  /// Set of known function names for token classification.
  final Set<String> _knownFunctions;

  /// Set of known constant names for token classification.
  final Set<String> _knownConstants;

  /// Tokenizes the expression into a list of tokens.
  ///
  /// This method scans through the entire expression and converts it into
  /// a sequence of tokens. It handles:
  /// - Numeric literals (integers and decimals)
  /// - Operators (+, -, *, /, ^)
  /// - Unary minus detection
  /// - Functions, variables, and constants
  /// - Parentheses and commas
  /// - Implicit multiplication insertion
  /// - Whitespace skipping
  ///
  /// Returns a [List<Token>] representing the tokenized expression.
  ///
  /// Throws [FormatException] if an invalid character is encountered.
  ///
  /// Example:
  /// ```dart
  /// final tokens = lexer.tokenize();
  /// ```
  List<Token> tokenize() {
    final tokens = <Token>[];
    Token? lastToken;

    while (_currentIndex < _expression.length) {
      final char = _expression[_currentIndex];

      if (_isWhitespace(char)) {
        _currentIndex++;

        continue;
      }

      if (_isDigit(char) || (char == '.' && _isDigit(_peek()))) {
        lastToken = _readNumber();
      } else if (_isLetter(char)) {
        lastToken = _readIdentifier();
      } else if (char == '(') {
        lastToken = LeftParenToken();
        _currentIndex++;
      } else if (char == ')') {
        lastToken = RightParenToken();
        _currentIndex++;
      } else if (char == ',') {
        lastToken = CommaToken();
        _currentIndex++;
      } else if (_isOperator(char)) {
        final isUnaryMinus = char == '-' &&
            (lastToken == null ||
                lastToken is OperatorToken ||
                lastToken is LeftParenToken ||
                lastToken is CommaToken);

        if (isUnaryMinus) {
          lastToken = UnaryMinusToken();
        } else {
          lastToken = OperatorToken(char);
        }

        _currentIndex++;
      } else {
        throw FormatException(
          'Invalid character: $char at position $_currentIndex',
        );
      }

      if (lastToken != null && tokens.isNotEmpty) {
        final prevToken = tokens.last;

        if ((prevToken is NumberToken ||
                prevToken is VariableToken ||
                prevToken is ConstantToken ||
                prevToken is RightParenToken) &&
            (lastToken is VariableToken ||
                lastToken is ConstantToken ||
                lastToken is FunctionToken ||
                lastToken is LeftParenToken)) {
          tokens.add(OperatorToken('*'));
        }
      }

      if (lastToken != null) tokens.add(lastToken);
    }
    return tokens;
  }

  Token _readNumber() {
    final buffer = StringBuffer();
    var hasDecimal = false;

    while (_currentIndex < _expression.length) {
      final char = _expression[_currentIndex];

      if (_isDigit(char)) {
        buffer.write(char);
      } else if (char == '.') {
        if (hasDecimal) break;

        hasDecimal = true;
        buffer.write(char);
      } else {
        break;
      }

      _currentIndex++;
    }

    final valueStr = buffer.toString();

    return hasDecimal
        ? NumberToken(DoubleValue(double.parse(valueStr)), valueStr)
        : NumberToken(IntegerValue(int.parse(valueStr)), valueStr);
  }

  Token _readIdentifier() {
    final buffer = StringBuffer()..write(_expression[_currentIndex++]);

    while (_currentIndex < _expression.length) {
      final char = _expression[_currentIndex];

      if (_isLetter(char) || _isDigit(char)) {
        buffer.write(char);
        _currentIndex++;
      } else {
        break;
      }
    }

    final identifier = buffer.toString();

    if (_knownFunctions.contains(identifier)) {
      return FunctionToken(identifier);
    }
    if (_knownConstants.contains(identifier)) {
      return ConstantToken(identifier);
    }

    return VariableToken(identifier);
  }

  String _peek() => _currentIndex + 1 < _expression.length
      ? _expression[_currentIndex + 1]
      : '';

  bool _isDigit(String s) => s.isNotEmpty && '0123456789'.contains(s);

  bool _isLetter(String s) =>
      s.isNotEmpty && s.toLowerCase() != s.toUpperCase();

  bool _isOperator(String s) => s.isNotEmpty && '+-*/^%'.contains(s);

  bool _isWhitespace(String s) => s.trim().isEmpty;
}
