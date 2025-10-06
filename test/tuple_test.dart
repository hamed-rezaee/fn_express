import 'package:fn_express/fn_express.dart';
import 'package:test/test.dart';

void main() {
  group('Tuple2', () {
    test('creates tuple with two items', () {
      final tuple = Tuple2<int, String>(42, 'hello');
      expect(tuple.item1, equals(42));
      expect(tuple.item2, equals('hello'));
    });

    test('creates tuple with same type items', () {
      final tuple = Tuple2<int, int>(10, 20);
      expect(tuple.item1, equals(10));
      expect(tuple.item2, equals(20));
    });

    test('creates tuple with different numeric types', () {
      final tuple = Tuple2<int, double>(5, 3.14);
      expect(tuple.item1, equals(5));
      expect(tuple.item2, equals(3.14));
    });

    test('creates tuple with complex types', () {
      final tuple = Tuple2<List<int>, Map<String, String>>(
        [1, 2, 3],
        {'key': 'value'},
      );
      expect(tuple.item1, equals([1, 2, 3]));
      expect(tuple.item2, equals({'key': 'value'}));
    });

    test('creates tuple with function types', () {
      final tuple = Tuple2<int Function(int), String Function()>(
        (x) => x * 2,
        () => 'result',
      );
      expect(tuple.item1(5), equals(10));
      expect(tuple.item2(), equals('result'));
    });

    test('creates tuple with NumberValue types', () {
      final tuple = Tuple2<IntegerValue, DoubleValue>(
        IntegerValue(5),
        DoubleValue(3.14),
      );
      expect(tuple.item1.value, equals(5));
      expect(tuple.item2.value, equals(3.14));
    });

    test('stores null values', () {
      final tuple = Tuple2<int?, String?>(null, null);
      expect(tuple.item1, isNull);
      expect(tuple.item2, isNull);
    });

    test('stores mixed null and non-null values', () {
      final tuple = Tuple2<int?, String>(null, 'test');
      expect(tuple.item1, isNull);
      expect(tuple.item2, equals('test'));
    });
  });
}
