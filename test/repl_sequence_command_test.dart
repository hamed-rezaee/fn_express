import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('Repl sequence command', () {
    test('computes polynomial and next term diagnostics', () {
      final output = _runReplCommand('sequence 2,5,8,11');

      final expressionLine = _lineStartingWith(output, 'Sequence expression: ');
      final expression =
          expressionLine.substring('Sequence expression: '.length);
      _expectEquivalentExpression(expression, '3 * n + 2', 'n');
    });

    test('respects variable and start index options', () {
      final output = _runReplCommand('sequence 1,8,27,64 var=k start=1');

      final expressionLine = _lineStartingWith(output, 'Sequence expression: ');
      final expression =
          expressionLine.substring('Sequence expression: '.length);
      _expectEquivalentExpression(
        expression,
        'k^3',
        'k',
        samples: const [1, 2, 3, 5],
      );
    });

    test('supports simplify flag', () {
      final output = _runReplCommand('sequence 2,5,8,11 simplify=false');

      final expressionLine = _lineStartingWith(output, 'Sequence expression: ');
      final expression =
          expressionLine.substring('Sequence expression: '.length);
      // Without simplification the Horner form should still recreate the sequence.
      _expectEquivalentExpression(expression, '3 * n + 2', 'n');
    });
  });
}

List<String> _runReplCommand(String command) {
  final output = <String>[];
  final repl = Repl((value, {newline = true}) {
    output.add(value);
  });

  output.clear();
  repl(command);

  return output;
}

String _lineStartingWith(List<String> lines, String prefix) {
  return lines.firstWhere(
    (line) => line.startsWith(prefix),
    orElse: () =>
        throw StateError('Expected line starting with "$prefix" in $lines'),
  );
}

void _expectEquivalentExpression(
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
    final value = symbolic.eval(difference).value as num;
    expect(
      value,
      closeTo(0, 1e-9),
      reason: 'Expressions differ for $variable at $sample',
    );
  }
}
