import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('ExpressionNormalizer.normalize', () {
    test('returns input when no brackets are present', () {
      const expression = 'sin(x) + cos(x)';
      expect(ExpressionNormalizer.normalize(expression), equals(expression));
    });

    test('converts simple vector literal', () {
      const expression = '[1, 2, 3]';
      expect(
        ExpressionNormalizer.normalize(expression),
        equals('vector(1, 2, 3)'),
      );
    });

    test('converts nested matrix literal with inner vectors', () {
      const expression = '[[1, 2], [3, 4]]';
      expect(
        ExpressionNormalizer.normalize(expression),
        equals('matrix(vector(1, 2), vector(3, 4))'),
      );
    });

    test('converts matrix literal with semicolon rows', () {
      const expression = '[1, 2; 3, 4]';
      expect(
        ExpressionNormalizer.normalize(expression),
        equals('matrix(vector(1, 2), vector(3, 4))'),
      );
    });

    test('handles nested structures within arithmetic expressions', () {
      const expression = '2 * [1, [2, 3], 4] + x';
      expect(
        ExpressionNormalizer.normalize(expression),
        equals('2 * vector(1, vector(2, 3), 4) + x'),
      );
    });

    test('throws when brackets are mismatched', () {
      expect(
        () => ExpressionNormalizer.normalize('[1, 2, 3'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when literal is empty', () {
      expect(
        () => ExpressionNormalizer.normalize('[]'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when matrix row is empty', () {
      expect(
        () => ExpressionNormalizer.normalize('[1, 2; ; 3, 4]'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
