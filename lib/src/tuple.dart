/// A generic container class that holds exactly two values of potentially different types.
///
/// This is a simple implementation of a 2-tuple (ordered pair) that can store
/// two values of any type. It's commonly used to return multiple values from
/// a function or to group related data together.
///
/// Type Parameters:
/// - [T1]: The type of the first item
/// - [T2]: The type of the second item
///
/// Example:
/// ```dart
/// final coordinates = Tuple2<double, double>(3.14, 2.71);
/// final nameAge = Tuple2<String, int>('Alice', 30);
/// print('X: ${coordinates.item1}, Y: ${coordinates.item2}');
/// ```
class Tuple2<T1, T2> {
  /// Creates a new tuple containing the given [item1] and [item2].
  ///
  /// Example:
  /// ```dart
  /// final tuple = Tuple2('Hello', 42);
  /// ```
  Tuple2(this.item1, this.item2);

  /// The first item in the tuple of type [T1].
  final T1 item1;

  /// The second item in the tuple of type [T2].
  final T2 item2;
}
