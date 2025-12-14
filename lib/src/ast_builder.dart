import 'dart:collection';

import 'package:fn_express/src/ast_node.dart';
import 'package:fn_express/src/token.dart';

/// Converts a parsed expression (in RPN form) into an Abstract Syntax Tree.
///
/// This class takes tokens in Reverse Polish Notation and constructs
/// an AST that can be used for operations like simplification and differentiation.
class AstBuilder {
  /// Creates an AST builder.
  AstBuilder();

  /// Builds an AST from a queue of tokens in Reverse Polish Notation.
  ///
  /// Takes the RPN token queue and reconstructs the expression tree structure.
  /// This enables more sophisticated operations like algebraic simplification and symbolic differentiation.
  ///
  /// Returns the root [AstNode] of the constructed tree.
  ///
  /// Throws [StateError] if the token queue represents a malformed expression.
  AstNode buildFromRpn(Queue<Token> rpnQueue) {
    final stack = <AstNode>[];

    for (final token in rpnQueue) {
      if (token is NumberToken) {
        stack.add(NumberNode(token.number));
      } else if (token is VariableToken) {
        stack.add(VariableNode(token.value));
      } else if (token is ConstantToken) {
        stack.add(VariableNode(token.value));
      } else if (token is OperatorToken) {
        if (token is UnaryMinusToken) {
          if (stack.isEmpty) {
            throw StateError('Invalid expression for unary minus.');
          }

          final operand = stack.removeLast();

          stack.add(UnaryOperationNode('-', operand));
        } else {
          if (stack.length < 2) {
            throw StateError('Invalid expression for operator ${token.value}.');
          }

          final right = stack.removeLast();
          final left = stack.removeLast();

          stack.add(BinaryOperationNode(token.value, left, right));
        }
      } else if (token is FunctionToken) {
        if (stack.isEmpty) {
          throw StateError('Not enough arguments for function ${token.value}');
        }

        final argument = stack.removeLast();

        stack.add(FunctionNode(token.value, argument));
      }
    }

    if (stack.length != 1) {
      throw StateError('The expression is malformed.');
    }

    return stack.single;
  }

  /// Builds an AST from a queue of tokens in Reverse Polish Notation with function argument counts.
  ///
  /// This version handles multi-argument functions by using the provided
  /// function argument counts to determine how many arguments to pop from the stack.
  AstNode buildFromRpnWithArgCounts(
    Queue<Token> rpnQueue,
    Map<String, int> functionArgCounts,
  ) {
    final stack = <AstNode>[];

    for (final token in rpnQueue) {
      if (token is NumberToken) {
        stack.add(NumberNode(token.number));
      } else if (token is VariableToken) {
        stack.add(VariableNode(token.value));
      } else if (token is ConstantToken) {
        stack.add(VariableNode(token.value));
      } else if (token is OperatorToken) {
        if (token is UnaryMinusToken) {
          if (stack.isEmpty) {
            throw StateError('Invalid expression for unary minus.');
          }

          final operand = stack.removeLast();

          stack.add(UnaryOperationNode('-', operand));
        } else {
          if (stack.length < 2) {
            throw StateError('Invalid expression for operator ${token.value}.');
          }

          final right = stack.removeLast();
          final left = stack.removeLast();

          stack.add(BinaryOperationNode(token.value, left, right));
        }
      } else if (token is FunctionToken) {
        final funcName = token.value;
        final argCount = functionArgCounts[funcName] ?? 1;

        if (stack.length < argCount) {
          throw StateError('Not enough arguments for function $funcName');
        }

        if (argCount == 1) {
          final argument = stack.removeLast();

          stack.add(FunctionNode(funcName, argument));
        } else {
          final arguments = <AstNode>[];

          for (var i = 0; i < argCount; i++) {
            arguments.insert(0, stack.removeLast());
          }

          final mainArg = arguments.removeAt(0);

          stack.add(FunctionNode(funcName, mainArg, arguments));
        }
      }
    }

    if (stack.length != 1) {
      throw StateError('The expression is malformed.');
    }

    return stack.single;
  }
}
