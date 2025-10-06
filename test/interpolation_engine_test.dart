import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('InterpolationEngine', () {
    late InterpolationEngine engine;

    setUp(() {
      engine = InterpolationEngine();
    });

    test('interpolates within the domain', () {
      final result = engine.interpolateLinear(
        [
          Tuple2(0, 0),
          Tuple2(10, 20),
        ],
        5,
      );

      expect(result, isA<IntegerValue>());
      expect(result.value, equals(10));
    });

    test('handles unsorted points', () {
      final result = engine.interpolateLinear(
        [
          Tuple2(10, 20),
          Tuple2(0, 0),
        ],
        2.5,
      );

      expect(result.value, equals(5));
    });

    test('returns double results when needed', () {
      final result = engine.interpolateLinear(
        [
          Tuple2(0, 0),
          Tuple2(8, 10),
        ],
        5,
      );

      expect(result, isA<DoubleValue>());
      expect((result.value as num).toDouble(), closeTo(6.25, 1e-9));
    });

    test('throws when outside domain without extrapolation', () {
      expect(
        () => engine.interpolateLinear(
          [
            Tuple2(0, 0),
            Tuple2(10, 20),
          ],
          20,
        ),
        throwsRangeError,
      );
    });

    test('extrapolates beyond domain when allowed', () {
      final result = engine.extrapolateLinear(
        [
          Tuple2(0, 0),
          Tuple2(10, 20),
        ],
        15,
      );

      expect(result.value, equals(30));
    });

    test('extrapolates below domain when allowed', () {
      final result = engine.extrapolateLinear(
        [
          Tuple2(0, 0),
          Tuple2(10, 20),
        ],
        -5,
      );

      expect(result.value, equals(-10));
    });

    test('requires at least two points', () {
      expect(
        () => engine.interpolateLinear([Tuple2(0, 0)], 0),
        throwsArgumentError,
      );
    });

    test('rejects duplicate x values', () {
      expect(
        () => engine.interpolateLinear(
          [
            Tuple2(0, 0),
            Tuple2(0, 10),
            Tuple2(10, 20),
          ],
          5,
        ),
        throwsArgumentError,
      );
    });
  });
}
