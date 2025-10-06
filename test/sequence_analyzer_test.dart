import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void expectEquivalentExpression(
  String actual,
  String expected,
  String variable, {
  Iterable<num>? samples,
}) {
  final points = samples ?? const [-2, -1, 0, 1, 2, 3, 5];
  final symbolic = SymbolicInterpreter();
  final difference = '($actual) - ($expected)';

  for (final sample in points) {
    symbolic.setVariable(variable, DoubleValue(sample.toDouble()));
    final diffValue = symbolic.eval(difference).value as num;
    expect(
      diffValue,
      closeTo(0, 1e-9),
      reason: 'Expressions differ at $variable = $sample',
    );
  }
}

void main() {
  group('SequenceAnalyzer', () {
    test('discovers linear sequences', () {
      final analyzer = SequenceAnalyzer();
      final result = analyzer.generatePolynomial([2, 5, 8, 11]);

      expect(result.degree, 1);
      expectEquivalentExpression(result.expression, '3 * n + 2', 'n');
      expect(result.termAt(0), closeTo(2.0, 1e-9));
      expect(result.termAt(10), closeTo(32.0, 1e-9));
    });

    test('handles shifted quadratic sequences', () {
      final analyzer = SequenceAnalyzer();
      final result = analyzer.generatePolynomial(
        [1, 4, 9, 16, 25],
        startIndex: 1,
      );

      expect(result.degree, 2);
      expectEquivalentExpression(
        result.expression,
        'n^2',
        'n',
        samples: const [1, 2, 3, 5, 11],
      );
      expect(result.termAt(1), closeTo(1.0, 1e-9));
      expect(result.termAt(7), closeTo(49.0, 1e-9));
    });

    test('SymbolicInterpreter exposes sequence synthesis', () {
      final symbolic = SymbolicInterpreter();
      final result = symbolic.sequenceFormula(
        [1, 8, 27, 64],
        variable: 'k',
      );

      expectEquivalentExpression(
        result.expression,
        '(k + 1)^3',
        'k',
        samples: const [0, 1, 2, 5],
      );
      expect(result.termAt(5), closeTo(216.0, 1e-9));
    });
  });
}
