import 'dart:collection';

import 'package:fn_express/src/token.dart';

/// A parser that converts infix mathematical expressions to postfix notation.
///
/// This parser implements the Shunting Yard algorithm to convert a list of
/// tokens from infix notation (where operators appear between operands)
/// to postfix notation (Reverse Polish Notation), which is easier to evaluate.
///
/// The parser handles operator precedence, associativity, parentheses,
/// functions, and function arguments correctly.
///
/// Example:
/// ```dart
/// final tokens = [/* tokenized expression */];
/// final parser = Parser(tokens);
/// final rpnQueue = parser.toPostfix();
/// ```
class Parser {
  /// Creates a new parser for the given list of [tokens].
  ///
  /// The tokens should be in infix order as produced by the lexer.
  Parser(this.tokens);

  /// The list of tokens to parse in infix order.
  final List<Token> tokens;

  /// Converts the infix token list to postfix notation using the Shunting Yard algorithm.
  ///
  /// This method processes the tokens and returns them in Reverse Polish Notation
  /// (postfix), where operators appear after their operands. This format is
  /// much easier to evaluate than infix notation.
  ///
  /// The algorithm handles:
  /// - Operator precedence (^, *, /, +, -)
  /// - Operator associativity (left for most, right for ^)
  /// - Parentheses for grouping
  /// - Function calls with arguments
  /// - Comma-separated argument lists
  ///
  /// Returns a [Queue<Token>] containing tokens in postfix order.
  ///
  /// Throws [FormatException] if there are mismatched parentheses or commas.
  ///
  /// Example:
  /// ```dart
  /// // Input: "2 + 3 * 4" → Output: [2, 3, 4, *, +]
  /// final rpnQueue = parser.toPostfix();
  /// ```
  Queue<Token> toPostfix() {
    final outputQueue = Queue<Token>();
    final operatorStack = <Token>[];

    for (final token in tokens) {
      if (token is NumberToken ||
          token is VariableToken ||
          token is ConstantToken) {
        outputQueue.add(token);
      } else if (token is FunctionToken) {
        operatorStack.add(token);
      } else if (token is CommaToken) {
        while (
            operatorStack.isNotEmpty && operatorStack.last is! LeftParenToken) {
          outputQueue.add(operatorStack.removeLast());
        }

        if (operatorStack.isEmpty) {
          throw const FormatException('Mismatched comma or parentheses.');
        }
      } else if (token is OperatorToken) {
        while (
            operatorStack.isNotEmpty && operatorStack.last is OperatorToken) {
          final topOp = operatorStack.last as OperatorToken;

          if ((topOp.precedence > token.precedence) ||
              (topOp.precedence == token.precedence &&
                  token.isLeftAssociative)) {
            outputQueue.add(operatorStack.removeLast());
          } else {
            break;
          }
        }
        operatorStack.add(token);
      } else if (token is LeftParenToken) {
        operatorStack.add(token);
      } else if (token is RightParenToken) {
        while (
            operatorStack.isNotEmpty && operatorStack.last is! LeftParenToken) {
          outputQueue.add(operatorStack.removeLast());
        }

        if (operatorStack.isEmpty) {
          throw const FormatException('Mismatched parentheses.');
        }

        operatorStack.removeLast();

        if (operatorStack.isNotEmpty && operatorStack.last is FunctionToken) {
          outputQueue.add(operatorStack.removeLast());
        }
      }
    }

    while (operatorStack.isNotEmpty) {
      final token = operatorStack.removeLast();

      if (token is LeftParenToken) {
        throw const FormatException('Mismatched parentheses.');
      }

      outputQueue.add(token);
    }

    return outputQueue;
  }
}
