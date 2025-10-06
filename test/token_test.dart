import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('Token', () {
    test('toString returns value', () {
      final token = NumberToken(IntegerValue(5), '5');
      expect(token.toString(), equals('5'));
    });
  });

  group('NumberToken', () {
    test('creates with integer value', () {
      final token = NumberToken(IntegerValue(42), '42');
      expect(token.value, equals('42'));
      expect(token.number, isA<IntegerValue>());
      expect(token.number.value, equals(42));
    });

    test('creates with double value', () {
      final token = NumberToken(DoubleValue(3.14), '3.14');
      expect(token.value, equals('3.14'));
      expect(token.number, isA<DoubleValue>());
      expect(token.number.value, equals(3.14));
    });

    test('creates with complex value', () {
      final token = NumberToken(ComplexValue(const Complex(2, 3)), '2 + 3i');
      expect(token.value, equals('2 + 3i'));
      expect(token.number, isA<ComplexValue>());
    });
  });

  group('OperatorToken', () {
    test('addition operator has correct precedence', () {
      final token = OperatorToken('+');
      expect(token.precedence, equals(2));
      expect(token.isLeftAssociative, isTrue);
    });

    test('subtraction operator has correct precedence', () {
      final token = OperatorToken('-');
      expect(token.precedence, equals(2));
      expect(token.isLeftAssociative, isTrue);
    });

    test('multiplication operator has correct precedence', () {
      final token = OperatorToken('*');
      expect(token.precedence, equals(3));
      expect(token.isLeftAssociative, isTrue);
    });

    test('division operator has correct precedence', () {
      final token = OperatorToken('/');
      expect(token.precedence, equals(3));
      expect(token.isLeftAssociative, isTrue);
    });

    test('modulo operator has correct precedence', () {
      final token = OperatorToken('%');
      expect(token.precedence, equals(3));
      expect(token.isLeftAssociative, isTrue);
    });

    test('exponentiation operator has correct precedence', () {
      final token = OperatorToken('^');
      expect(token.precedence, equals(4));
      expect(token.isLeftAssociative, isFalse);
    });

    test('unknown operator has zero precedence', () {
      final token = OperatorToken('&');
      expect(token.precedence, equals(0));
      expect(token.isLeftAssociative, isTrue);
    });
  });

  group('UnaryMinusToken', () {
    test('creates with correct value', () {
      final token = UnaryMinusToken();
      expect(token.value, equals('u-'));
    });

    test('has highest precedence', () {
      final token = UnaryMinusToken();
      expect(token.precedence, equals(5));
    });

    test('precedence is higher than binary operators', () {
      final unaryMinus = UnaryMinusToken();
      final exponent = OperatorToken('^');
      final multiply = OperatorToken('*');
      final add = OperatorToken('+');

      expect(unaryMinus.precedence, greaterThan(exponent.precedence));
      expect(unaryMinus.precedence, greaterThan(multiply.precedence));
      expect(unaryMinus.precedence, greaterThan(add.precedence));
    });
  });

  group('FunctionToken', () {
    test('creates with function name', () {
      final token = FunctionToken('sin');
      expect(token.value, equals('sin'));
    });

    test('creates with different function names', () {
      final tokens =
          ['sqrt', 'cos', 'tan', 'ln', 'exp'].map(FunctionToken.new).toList();

      expect(tokens[0].value, equals('sqrt'));
      expect(tokens[1].value, equals('cos'));
      expect(tokens[2].value, equals('tan'));
      expect(tokens[3].value, equals('ln'));
      expect(tokens[4].value, equals('exp'));
    });
  });

  group('VariableToken', () {
    test('creates with variable name', () {
      final token = VariableToken('x');
      expect(token.value, equals('x'));
    });

    test('creates with different variable names', () {
      final tokens =
          ['x', 'y', 'z', 'alpha', 'beta'].map(VariableToken.new).toList();

      expect(tokens[0].value, equals('x'));
      expect(tokens[1].value, equals('y'));
      expect(tokens[2].value, equals('z'));
      expect(tokens[3].value, equals('alpha'));
      expect(tokens[4].value, equals('beta'));
    });
  });

  group('ConstantToken', () {
    test('creates with constant name', () {
      final token = ConstantToken('pi');
      expect(token.value, equals('pi'));
    });

    test('creates with different constant names', () {
      final tokens =
          ['pi', 'e', 'i', 'phi', 'tau'].map(ConstantToken.new).toList();

      expect(tokens[0].value, equals('pi'));
      expect(tokens[1].value, equals('e'));
      expect(tokens[2].value, equals('i'));
      expect(tokens[3].value, equals('phi'));
      expect(tokens[4].value, equals('tau'));
    });
  });

  group('LeftParenToken', () {
    test('creates with correct value', () {
      final token = LeftParenToken();
      expect(token.value, equals('('));
    });
  });

  group('RightParenToken', () {
    test('creates with correct value', () {
      final token = RightParenToken();
      expect(token.value, equals(')'));
    });
  });

  group('CommaToken', () {
    test('creates with correct value', () {
      final token = CommaToken();
      expect(token.value, equals(','));
    });
  });
}
