// ignore_for_file: lines_longer_than_80_chars

import 'dart:math' as math;

import 'package:fn_express/src/number_value.dart';
import 'package:fn_express/src/tuple.dart';

/// Provides numerical interpolation and extrapolation utilities.
class InterpolationEngine {
  /// Performs piecewise linear interpolation for [x] using the supplied [points].
  ///
  /// Throws a [RangeError] when [x] lies outside the domain of the points.
  NumberValue interpolateLinear(List<Tuple2<num, num>> points, num x) {
    return _evaluate(points, x, allowExtrapolation: false);
  }

  /// Performs piecewise linear extrapolation for [x] using the supplied [points].
  ///
  /// When [x] lies within the domain this behaves like [interpolateLinear].
  NumberValue extrapolateLinear(List<Tuple2<num, num>> points, num x) {
    return _evaluate(points, x, allowExtrapolation: true);
  }

  NumberValue _evaluate(
    List<Tuple2<num, num>> rawPoints,
    num x, {
    required bool allowExtrapolation,
  }) {
    final points = _normalisePoints(rawPoints);

    if (points.length < 2) {
      throw ArgumentError('At least two data points are required.');
    }

    final xValue = x.toDouble();

    // Direct match on a known point.
    for (final point in points) {
      if ((point.item1 - xValue).abs() <= 1e-12) {
        return _numberValue(point.item2);
      }
    }

    // Interpolate within bounds.
    for (var i = 0; i < points.length - 1; i++) {
      final left = points[i];
      final right = points[i + 1];

      if (xValue >= left.item1 && xValue <= right.item1) {
        return _interpolateSegment(left, right, xValue);
      }
    }

    if (!allowExtrapolation) {
      throw RangeError('Value $x is outside the interpolation domain.');
    }

    if (xValue < points.first.item1) {
      return _interpolateSegment(points.first, points[1], xValue);
    }

    return _interpolateSegment(
      points[points.length - 2],
      points.last,
      xValue,
    );
  }

  List<Tuple2<double, double>> _normalisePoints(List<Tuple2<num, num>> points) {
    final mapped = points
        .map((p) => Tuple2(p.item1.toDouble(), p.item2.toDouble()))
        .toList()
      ..sort((a, b) => a.item1.compareTo(b.item1));

    for (var i = 1; i < mapped.length; i++) {
      if ((mapped[i].item1 - mapped[i - 1].item1).abs() <= 1e-12) {
        throw ArgumentError(
            'Duplicate x-values are not allowed for interpolation.');
      }
    }

    return mapped;
  }

  NumberValue _interpolateSegment(
    Tuple2<double, double> left,
    Tuple2<double, double> right,
    double x,
  ) {
    final slope = (right.item2 - left.item2) / (right.item1 - left.item1);
    final value = left.item2 + slope * (x - left.item1);
    return _numberValue(value);
  }

  NumberValue _numberValue(double value) {
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() <= math.max((value.abs() + 1) * 1e-12, 1e-12) &&
        rounded % 1 == 0) {
      return IntegerValue(rounded.toInt());
    }

    return DoubleValue(value);
  }
}
