import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  final functions = {'sin', 'cos', 'sqrt', 'ln', 'exp'};
  final constants = {'pi', 'e', 'i'};

  group('Lexer - Numbers', () {
    test('tokenizes integer', () {
      final lexer = Lexer('42', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(1));
      expect(tokens[0], isA<NumberToken>());
      final numToken = tokens[0] as NumberToken;
      expect(numToken.number, isA<IntegerValue>());
      expect(numToken.number.value, equals(42));
    });

    test('tokenizes decimal number', () {
      final lexer = Lexer('3.14', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(1));
      expect(tokens[0], isA<NumberToken>());
      final numToken = tokens[0] as NumberToken;
      expect(numToken.number, isA<DoubleValue>());
      expect(numToken.number.value, equals(3.14));
    });

    test('tokenizes number starting with decimal point', () {
      final lexer = Lexer('.5', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(1));
      expect(tokens[0], isA<NumberToken>());
      final numToken = tokens[0] as NumberToken;
      expect(numToken.number.value, equals(0.5));
    });

    test('tokenizes multiple numbers', () {
      final lexer = Lexer('1 2 3', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(3));
      expect(tokens.every((t) => t is NumberToken), isTrue);
    });
  });

  group('Lexer - Operators', () {
    test('tokenizes addition operator', () {
      final lexer = Lexer('+', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(1));
      expect(tokens[0], isA<OperatorToken>());
      expect(tokens[0].value, equals('+'));
    });

    test('tokenizes all binary operators', () {
      final lexer = Lexer('+ - * / ^ %', functions, constants);
      final tokens = lexer.tokenize();
      final operators = ['+', 'u-', '*', '/', '^', '%'];
      expect(tokens.length, equals(6));
      for (var i = 0; i < tokens.length; i++) {
        expect(tokens[i], isA<OperatorToken>());
        expect(tokens[i].value, equals(operators[i]));
      }
    });

    test('tokenizes unary minus at start', () {
      final lexer = Lexer('-5', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(2));
      expect(tokens[0], isA<UnaryMinusToken>());
      expect(tokens[1], isA<NumberToken>());
    });

    test('tokenizes unary minus after operator', () {
      final lexer = Lexer('5 + -3', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(4));
      expect(tokens[0], isA<NumberToken>());
      expect(tokens[1], isA<OperatorToken>());
      expect((tokens[1] as OperatorToken).value, equals('+'));
      expect(tokens[2], isA<UnaryMinusToken>());
      expect(tokens[3], isA<NumberToken>());
    });

    test('tokenizes unary minus after left paren', () {
      final lexer = Lexer('(-5)', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(4));
      expect(tokens[0], isA<LeftParenToken>());
      expect(tokens[1], isA<UnaryMinusToken>());
      expect(tokens[2], isA<NumberToken>());
      expect(tokens[3], isA<RightParenToken>());
    });

    test('tokenizes binary minus vs unary minus', () {
      final lexer = Lexer('5 - -3', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(4));
      expect(tokens[1], isA<OperatorToken>());
      expect((tokens[1] as OperatorToken).value, equals('-'));
      expect(tokens[2], isA<UnaryMinusToken>());
    });
  });

  group('Lexer - Parentheses and Comma', () {
    test('tokenizes parentheses', () {
      final lexer = Lexer('()', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(2));
      expect(tokens[0], isA<LeftParenToken>());
      expect(tokens[1], isA<RightParenToken>());
    });

    test('tokenizes comma', () {
      final lexer = Lexer(',', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(1));
      expect(tokens[0], isA<CommaToken>());
    });

    test('tokenizes expression with parentheses', () {
      final lexer = Lexer('(1 + 2)', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(5));
      expect(tokens[0], isA<LeftParenToken>());
      expect(tokens[4], isA<RightParenToken>());
    });
  });

  group('Lexer - Functions', () {
    test('tokenizes function name', () {
      final lexer = Lexer('sin', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(1));
      expect(tokens[0], isA<FunctionToken>());
      expect(tokens[0].value, equals('sin'));
    });

    test('tokenizes function call', () {
      final lexer = Lexer('sin(x)', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(4));
      expect(tokens[0], isA<FunctionToken>());
      expect(tokens[1], isA<LeftParenToken>());
      expect(tokens[2], isA<VariableToken>());
      expect(tokens[3], isA<RightParenToken>());
    });

    test('tokenizes multiple functions', () {
      final lexer = Lexer('sin cos sqrt', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(3));
      expect(tokens.every((t) => t is FunctionToken), isTrue);
    });
  });

  group('Lexer - Variables', () {
    test('tokenizes variable', () {
      final lexer = Lexer('x', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(1));
      expect(tokens[0], isA<VariableToken>());
      expect(tokens[0].value, equals('x'));
    });

    test('tokenizes multi-character variable', () {
      final lexer = Lexer('alpha', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(1));
      expect(tokens[0], isA<VariableToken>());
      expect(tokens[0].value, equals('alpha'));
    });

    test('tokenizes variable with numbers', () {
      final lexer = Lexer('x1', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(1));
      expect(tokens[0], isA<VariableToken>());
      expect(tokens[0].value, equals('x1'));
    });

    test('tokenizes multiple variables', () {
      final lexer = Lexer('x y z', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(5));
      expect(tokens.whereType<VariableToken>().length, equals(3));
      expect(tokens.whereType<OperatorToken>().length, equals(2));
    });
  });

  group('Lexer - Constants', () {
    test('tokenizes constant', () {
      final lexer = Lexer('pi', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(1));
      expect(tokens[0], isA<ConstantToken>());
      expect(tokens[0].value, equals('pi'));
    });

    test('tokenizes all predefined constants', () {
      final lexer = Lexer('pi e i', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(5));
      expect(tokens.whereType<ConstantToken>().length, equals(3));
      expect(tokens.whereType<OperatorToken>().length, equals(2));
      expect(tokens[0].value, equals('pi'));
      expect(tokens[1].value, equals('*'));
      expect(tokens[2].value, equals('e'));
      expect(tokens[3].value, equals('*'));
      expect(tokens[4].value, equals('i'));
    });
  });

  group('Lexer - Implicit Multiplication', () {
    test('inserts multiplication between number and variable', () {
      final lexer = Lexer('2x', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(3));
      expect(tokens[0], isA<NumberToken>());
      expect(tokens[1], isA<OperatorToken>());
      expect(tokens[1].value, equals('*'));
      expect(tokens[2], isA<VariableToken>());
    });

    test('inserts multiplication between number and function', () {
      final lexer = Lexer('2sin', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(3));
      expect(tokens[0], isA<NumberToken>());
      expect(tokens[1], isA<OperatorToken>());
      expect(tokens[1].value, equals('*'));
      expect(tokens[2], isA<FunctionToken>());
    });

    test('inserts multiplication between number and left paren', () {
      final lexer = Lexer('2(x)', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(5));
      expect(tokens[0], isA<NumberToken>());
      expect(tokens[1], isA<OperatorToken>());
      expect(tokens[1].value, equals('*'));
      expect(tokens[2], isA<LeftParenToken>());
    });

    test('inserts multiplication between right paren and variable', () {
      final lexer = Lexer('(x)y', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(5));
      expect(tokens[2], isA<RightParenToken>());
      expect(tokens[3], isA<OperatorToken>());
      expect(tokens[3].value, equals('*'));
      expect(tokens[4], isA<VariableToken>());
    });

    test('inserts multiplication between variable and left paren', () {
      final lexer = Lexer('x(y)', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(5));
      expect(tokens[0], isA<VariableToken>());
      expect(tokens[1], isA<OperatorToken>());
      expect(tokens[1].value, equals('*'));
      expect(tokens[2], isA<LeftParenToken>());
    });

    test('inserts multiplication between constant and variable', () {
      final lexer = Lexer('pi x', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(3));
      expect(tokens[0], isA<ConstantToken>());
      expect(tokens[1], isA<OperatorToken>());
      expect(tokens[1].value, equals('*'));
      expect(tokens[2], isA<VariableToken>());
    });
  });

  group('Lexer - Whitespace', () {
    test('skips whitespace', () {
      final lexer = Lexer('  1  +  2  ', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(3));
    });

    test('handles tabs and newlines', () {
      final lexer = Lexer('1\t+\n2', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(3));
    });
  });

  group('Lexer - Complex Expressions', () {
    test('tokenizes simple arithmetic expression', () {
      final lexer = Lexer('2 + 3 * 4', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(5));
      expect(tokens[0], isA<NumberToken>());
      expect(tokens[1], isA<OperatorToken>());
      expect(tokens[2], isA<NumberToken>());
      expect(tokens[3], isA<OperatorToken>());
      expect(tokens[4], isA<NumberToken>());
    });

    test('tokenizes expression with function', () {
      final lexer = Lexer('sin(pi/2)', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(6));
      expect(tokens[0], isA<FunctionToken>());
      expect(tokens[1], isA<LeftParenToken>());
      expect(tokens[2], isA<ConstantToken>());
      expect(tokens[3], isA<OperatorToken>());
      expect(tokens[4], isA<NumberToken>());
      expect(tokens[5], isA<RightParenToken>());
    });

    test('tokenizes nested function calls', () {
      final lexer = Lexer('sin(cos(x))', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(7));
      expect(tokens[0], isA<FunctionToken>());
      expect(tokens[1], isA<LeftParenToken>());
      expect(tokens[2], isA<FunctionToken>());
      expect(tokens[3], isA<LeftParenToken>());
      expect(tokens[4], isA<VariableToken>());
      expect(tokens[5], isA<RightParenToken>());
      expect(tokens[6], isA<RightParenToken>());
    });

    test('tokenizes complex expression with implicit multiplication', () {
      final lexer = Lexer('2pi sin(x)', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(8));
      expect(tokens[1], isA<OperatorToken>());
      expect(tokens[1].value, equals('*'));
      expect(tokens[3], isA<OperatorToken>());
      expect(tokens[3].value, equals('*'));
    });
  });

  group('Lexer - Error Handling', () {
    test('throws on invalid character', () {
      final lexer = Lexer('2 @ 3', functions, constants);
      expect(lexer.tokenize, throwsFormatException);
    });

    test('throws on invalid character in expression', () {
      final lexer = Lexer('sin(x) # cos(y)', functions, constants);
      expect(lexer.tokenize, throwsFormatException);
    });
  });

  group('Lexer - Edge Cases', () {
    test('tokenizes empty expression', () {
      final lexer = Lexer('', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(0));
    });

    test('tokenizes expression with only whitespace', () {
      final lexer = Lexer('   ', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(0));
    });

    test('tokenizes single character variable', () {
      final lexer = Lexer('a', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(1));
      expect(tokens[0], isA<VariableToken>());
    });

    test('distinguishes between function and variable', () {
      final lexer = Lexer('sin x', functions, constants);
      final tokens = lexer.tokenize();
      expect(tokens.length, equals(2));
      expect(tokens[0], isA<FunctionToken>());
      expect(tokens[1], isA<VariableToken>());
    });

    test('unary minus after comma', () {
      final lexer = Lexer('f(1, -2)', {'f'}, constants);
      final tokens = lexer.tokenize();
      expect(tokens[3], isA<CommaToken>());
      expect(tokens[4], isA<UnaryMinusToken>());
    });
  });
}
