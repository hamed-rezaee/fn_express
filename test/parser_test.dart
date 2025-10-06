import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('Parser', () {
    test('converts simple addition to postfix', () {
      final tokens = [
        NumberToken(IntegerValue(2), '2'),
        OperatorToken('+'),
        NumberToken(IntegerValue(3), '3'),
      ];
      final parser = Parser(tokens);
      final rpn = parser.toPostfix().toList();
      expect(rpn.length, equals(3));
      expect(rpn[2].value, equals('+'));
    });

    test('respects operator precedence', () {
      final tokens = [
        NumberToken(IntegerValue(2), '2'),
        OperatorToken('+'),
        NumberToken(IntegerValue(3), '3'),
        OperatorToken('*'),
        NumberToken(IntegerValue(4), '4'),
      ];
      final parser = Parser(tokens);
      final rpn = parser.toPostfix().toList();
      expect(rpn[3].value, equals('*'));
      expect(rpn[4].value, equals('+'));
    });

    test('handles parentheses', () {
      final tokens = [
        LeftParenToken(),
        NumberToken(IntegerValue(2), '2'),
        RightParenToken(),
      ];
      final parser = Parser(tokens);
      final rpn = parser.toPostfix().toList();
      expect(rpn.length, equals(1));
    });

    test('parses functions', () {
      final tokens = [
        FunctionToken('sin'),
        LeftParenToken(),
        VariableToken('x'),
        RightParenToken(),
      ];
      final parser = Parser(tokens);
      final rpn = parser.toPostfix().toList();
      expect(rpn.length, equals(2));
      expect(rpn[1].value, equals('sin'));
    });
  });
}
