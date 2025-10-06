import 'dart:math' as math;

import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('EquationSolver', () {
    late EquationSolver solver;

    setUp(() {
      solver = EquationSolver();
    });

    double toDouble(NumberValue value) {
      final raw = value.value;
      if (raw is num) {
        return raw.toDouble();
      }
      throw StateError('Expected real number, got ${value.runtimeType}');
    }

    test('solves linear equation with initial guess', () {
      final solution = solver.solve('2*x + 4', 'x', initialGuess: 0);

      expect(solution.converged, isTrue);
      expect(solution.method, isNotEmpty);
      expect(toDouble(solution.root), closeTo(-2, 1e-9));
      expect(solution.residual, closeTo(0, 1e-9));
    });

    test('solves quadratic with bracketing', () {
      final solution =
          solver.solve('x^2 - 2', 'x', lowerBound: 0, upperBound: 2);

      expect(solution.converged, isTrue);
      expect(solution.method, equals('bisection'));
      expect(toDouble(solution.root), closeTo(math.sqrt(2), 1e-9));
      expect(solution.iterations, greaterThan(0));
    });

    test('supports equality syntax', () {
      final solution = solver.solve('x^2 = 9', 'x', initialGuess: 2);

      expect(solution.converged, isTrue);
      expect(toDouble(solution.root), closeTo(3, 1e-9));
    });

    test('throws when interval does not bracket a root', () {
      expect(
        () => solver.solve('x^2 + 1', 'x', lowerBound: -1, upperBound: 1),
        throwsArgumentError,
      );
    });

    test('SymbolicInterpreter delegating solveEquation', () {
      final interpreter = SymbolicInterpreter();
      final solution =
          interpreter.solveEquation('sin(x) = 0', 'x', initialGuess: 3.0);

      expect(solution.converged, isTrue);
      expect(toDouble(solution.root), closeTo(math.pi, 1e-9));
      expect(solution.method, anyOf('newton', 'secant'));
    });
  });
}
