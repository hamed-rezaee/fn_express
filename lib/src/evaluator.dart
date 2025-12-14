import 'dart:collection';

import 'package:fn_express/fn_express.dart';

/// Evaluates mathematical expressions in Reverse Polish Notation (RPN).
///
/// This class takes a queue of tokens in postfix notation and evaluates them
/// to produce a final numeric result. It uses a stack-based algorithm where
/// operands are pushed onto a stack and operators pop their operands,
/// perform the calculation, and push the result back.
///
/// The evaluator handles:
/// - Basic arithmetic operations (+, -, *, /, ^)
/// - Unary operations (negation)
/// - Function calls (single and multiple arguments)
/// - Variable and constant resolution
/// - Complex number arithmetic
///
/// Example:
/// ```dart
/// final evaluator = Evaluator(rpnQueue, interpreter);
/// final result = evaluator.evaluate();
/// ```
class Evaluator {
  /// Creates a new evaluator with the given RPN [rpnQueue] and [_interpreter].
  ///
  /// The [rpnQueue] should contain tokens in postfix order, and the
  /// [interpreter] provides access to variables, constants, and functions.
  /// The optional [functionArgCounts] map provides argument counts for functions.
  Evaluator(
    Queue<Token> rpnQueue,
    Interpreter interpreter, [
    Map<String, int>? functionArgCounts,
  ])  : _rpnQueue = rpnQueue,
        _interpreter = interpreter,
        _functionArgCounts = functionArgCounts ?? {};

  /// The queue of tokens in Reverse Polish Notation to evaluate.
  final Queue<Token> _rpnQueue;

  /// The interpreter instance containing variables, constants, and functions.
  final Interpreter _interpreter;

  /// Map of function names to their argument counts from the original expression.
  final Map<String, int> _functionArgCounts;

  /// Evaluates the RPN expression and returns the final result.
  ///
  /// This method processes each token in the RPN queue using a stack-based
  /// algorithm. Numbers, variables, and constants are pushed onto the stack,
  /// while operators and functions pop their operands, compute results,
  /// and push the results back onto the stack.
  ///
  /// Returns the final [NumberValue] result of the expression.
  ///
  /// Throws:
  /// - [ArgumentError] for undefined variables or functions
  /// - [StateError] for malformed expressions or insufficient operands
  /// - [ArgumentError] for division by zero
  ///
  /// Example:
  /// ```dart
  /// final result = evaluator.evaluate();
  /// ```
  NumberValue evaluate() {
    final stack = <NumberValue>[];

    for (final token in _rpnQueue) {
      if (token is NumberToken) {
        stack.add(token.number);
      } else if (token is ConstantToken) {
        stack.add(_interpreter.constants[token.value]!);
      } else if (token is VariableToken) {
        if (!_interpreter.variables.containsKey(token.value)) {
          throw ArgumentError('Undefined variable: ${token.value}');
        }

        stack.add(_interpreter.variables[token.value]!);
      } else if (token is OperatorToken) {
        if (token is UnaryMinusToken) {
          if (stack.isEmpty) {
            throw StateError('Invalid expression for unary minus.');
          }

          stack.add(stack.removeLast().negate());

          continue;
        }
        if (stack.length < 2) {
          throw StateError('Invalid expression for operator ${token.value}.');
        }

        final right = stack.removeLast();
        final left = stack.removeLast();

        stack.add(
          switch (token.value) {
            '+' => left + right,
            '-' => left - right,
            '*' => left * right,
            '/' => left / right,
            '%' => left.modulo(right),
            '^' => left.power(right),
            _ => throw ArgumentError('Unknown operator: ${token.value}'),
          },
        );
      } else if (token is FunctionToken) {
        final funcName = token.value;

        if (_interpreter.multiArgFunctions.containsKey(funcName)) {
          final expectedArgCount =
              _interpreter.multiArgFunctions[funcName]!.item2;
          final actualArgCount =
              _functionArgCounts[funcName] ?? expectedArgCount;
          final argCount =
              expectedArgCount == -1 ? actualArgCount : expectedArgCount;

          if (stack.length < argCount) {
            throw StateError('Not enough arguments for function $funcName');
          }

          final args = <NumberValue>[];

          for (var i = 0; i < argCount; i++) {
            args.insert(0, stack.removeLast());
          }

          stack.add(_interpreter.multiArgFunctions[funcName]!.item1(args));
        } else if (_interpreter.functions.containsKey(funcName)) {
          if (stack.isEmpty) {
            throw StateError('Not enough arguments for function $funcName');
          }

          stack.add(_interpreter.functions[funcName]!(stack.removeLast()));
        } else {
          throw ArgumentError('Unknown function: $funcName');
        }
      }
    }

    if (stack.length != 1) {
      throw StateError('The expression is malformed.');
    }

    return stack.single;
  }
}
