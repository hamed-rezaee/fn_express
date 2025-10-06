import 'dart:collection';
import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('AstBuilder', () {
    test('builds NumberNode from NumberToken', () {
      final builder = AstBuilder();
      final queue = Queue<Token>()..add(NumberToken(IntegerValue(42), '42'));
      final ast = builder.buildFromRpn(queue);
      expect(ast, isA<NumberNode>());
      expect((ast as NumberNode).value.value, equals(42));
    });

    test('builds VariableNode from VariableToken', () {
      final builder = AstBuilder();
      final queue = Queue<Token>()..add(VariableToken('x'));
      final ast = builder.buildFromRpn(queue);
      expect(ast, isA<VariableNode>());
      expect((ast as VariableNode).name, equals('x'));
    });

    test('builds BinaryOperationNode from operator and operands', () {
      final builder = AstBuilder();
      final queue = Queue<Token>()
        ..add(NumberToken(IntegerValue(2), '2'))
        ..add(NumberToken(IntegerValue(3), '3'))
        ..add(OperatorToken('+'));
      final ast = builder.buildFromRpn(queue);
      expect(ast, isA<BinaryOperationNode>());
      final binOp = ast as BinaryOperationNode;
      expect(binOp.operator, equals('+'));
    });

    test('builds UnaryOperationNode from UnaryMinusToken', () {
      final builder = AstBuilder();
      final queue = Queue<Token>()
        ..add(NumberToken(IntegerValue(5), '5'))
        ..add(UnaryMinusToken());
      final ast = builder.buildFromRpn(queue);
      expect(ast, isA<UnaryOperationNode>());
      final unaryOp = ast as UnaryOperationNode;
      expect(unaryOp.operator, equals('-'));
    });

    test('builds FunctionNode from FunctionToken', () {
      final builder = AstBuilder();
      final queue = Queue<Token>()
        ..add(VariableToken('x'))
        ..add(FunctionToken('sin'));
      final ast = builder.buildFromRpn(queue);
      expect(ast, isA<FunctionNode>());
      final funcNode = ast as FunctionNode;
      expect(funcNode.name, equals('sin'));
    });

    test('handles nested operations', () {
      final builder = AstBuilder();
      final queue = Queue<Token>()
        ..add(NumberToken(IntegerValue(2), '2'))
        ..add(NumberToken(IntegerValue(3), '3'))
        ..add(OperatorToken('+'))
        ..add(NumberToken(IntegerValue(4), '4'))
        ..add(OperatorToken('*'));
      final ast = builder.buildFromRpn(queue);
      expect(ast, isA<BinaryOperationNode>());
    });

    test('throws on invalid expression', () {
      final builder = AstBuilder();
      final queue = Queue<Token>()..add(OperatorToken('+'));
      expect(() => builder.buildFromRpn(queue), throwsStateError);
    });
  });
}
