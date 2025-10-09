import 'dart:collection';
import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('Evaluator', () {
    late Interpreter interpreter;

    setUp(() {
      interpreter = Interpreter();
    });

    test('evaluates simple addition', () {
      final queue = Queue<Token>()
        ..add(NumberToken(IntegerValue(2), '2'))
        ..add(NumberToken(IntegerValue(3), '3'))
        ..add(OperatorToken('+'));
      final evaluator = Evaluator(queue, interpreter);
      final result = evaluator.evaluate();
      expect(result.value, equals(5));
    });

    test('evaluates subtraction', () {
      final queue = Queue<Token>()
        ..add(NumberToken(IntegerValue(10), '10'))
        ..add(NumberToken(IntegerValue(3), '3'))
        ..add(OperatorToken('-'));
      final evaluator = Evaluator(queue, interpreter);
      final result = evaluator.evaluate();
      expect(result.value, equals(7));
    });

    test('evaluates multiplication', () {
      final queue = Queue<Token>()
        ..add(NumberToken(IntegerValue(4), '4'))
        ..add(NumberToken(IntegerValue(5), '5'))
        ..add(OperatorToken('*'));
      final evaluator = Evaluator(queue, interpreter);
      final result = evaluator.evaluate();
      expect(result.value, equals(20));
    });

    test('evaluates division', () {
      final queue = Queue<Token>()
        ..add(NumberToken(IntegerValue(10), '10'))
        ..add(NumberToken(IntegerValue(2), '2'))
        ..add(OperatorToken('/'));
      final evaluator = Evaluator(queue, interpreter);
      final result = evaluator.evaluate();
      expect(result.value, equals(5));
    });

    test('evaluates exponentiation', () {
      final queue = Queue<Token>()
        ..add(NumberToken(IntegerValue(2), '2'))
        ..add(NumberToken(IntegerValue(3), '3'))
        ..add(OperatorToken('^'));
      final evaluator = Evaluator(queue, interpreter);
      final result = evaluator.evaluate();
      expect(result.value, equals(8));
    });

    test('returns complex value for fractional power of negative base', () {
      final queue = Queue<Token>()
        ..add(NumberToken(IntegerValue(-4), '-4'))
        ..add(NumberToken(DoubleValue(0.5), '0.5'))
        ..add(OperatorToken('^'));
      final evaluator = Evaluator(queue, interpreter);
      final result = evaluator.evaluate();

      expect(result, isA<ComplexValue>());
      final complex = result as ComplexValue;
      expect(complex.value.real.abs(), lessThan(1e-10));
      expect(complex.value.imaginary, closeTo(2, 1e-10));
    });

    test('evaluates unary minus', () {
      final queue = Queue<Token>()
        ..add(NumberToken(IntegerValue(5), '5'))
        ..add(UnaryMinusToken());
      final evaluator = Evaluator(queue, interpreter);
      final result = evaluator.evaluate();
      expect(result.value, equals(-5));
    });

    test('evaluates variables', () {
      interpreter.setVariable('x', IntegerValue(10));
      final queue = Queue<Token>()..add(VariableToken('x'));
      final evaluator = Evaluator(queue, interpreter);
      final result = evaluator.evaluate();
      expect(result.value, equals(10));
    });

    test('evaluates constants', () {
      final queue = Queue<Token>()..add(ConstantToken('pi'));
      final evaluator = Evaluator(queue, interpreter);
      final result = evaluator.evaluate();
      expect(result.value, closeTo(3.14159, 0.0001));
    });

    test('evaluates function call', () {
      final queue = Queue<Token>()
        ..add(NumberToken(IntegerValue(16), '16'))
        ..add(FunctionToken('sqrt'));
      final evaluator = Evaluator(queue, interpreter);
      final result = evaluator.evaluate();
      expect(result.value, equals(4.0));
    });

    test('throws on undefined variable', () {
      final queue = Queue<Token>()..add(VariableToken('undefined'));
      final evaluator = Evaluator(queue, interpreter);
      expect(evaluator.evaluate, throwsArgumentError);
    });
  });
}
