import 'dart:math' as math;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

part 'stats.g.dart';

final _random = math.Random();

extension ListNumStats on List<num> {
  double? get median {
    if (isEmpty) return null;

    final index = length ~/ 2;

    if (length % 2 == 0) {
      return (this[index] + this[index - 1]) / 2;
    }

    return this[index].toDouble();
  }

  double? percentile(double percentile) {
    if (isEmpty) return null;
    final pos = percentile * (length - 1);
    final lower = pos.floor();
    final upper = pos.ceil();

    if (lower == upper) return this[lower].toDouble();

    final t = pos - lower;
    return this[lower] * (1 - t) + this[upper] * t;
  }
}

extension ListStats<T> on List<T> {
  Iterable<T> get resampled =>
      Iterable.generate(length, (_) => elementAt(_random.nextInt(length)));

  Iterable<Iterable<T>> bootstrap(int iterations) =>
      Iterable.generate(iterations, (_) => resampled);
}

extension IterableStats<N extends num> on Iterable<N> {
  N get max => reduce((a, b) => a > b ? a : b);
  N get sum => reduce((a, b) => a + b as N);

  List<N> get sorted => toList()..sort((a, b) => a.compareTo(b));

  Iterable<DistanceSample> get samples sync* {
    final List<N> items = [];

    for (final (index, item) in indexed) {
      for (final (index2, item2) in items.indexed) {
        final distance = index - index2;
        yield DistanceSample((item - item2) / distance, distance);
      }

      items.add(item);
    }
  }
}

class Confidence {
  final Sample lower;
  final Sample upper;

  const Confidence._({required this.lower, required this.upper});

  factory Confidence.from(List<Sample> samples) {
    if (samples.isEmpty) {
      throw ArgumentError('`samples` must not be empty', 'samples');
    }

    final data = samples
        .bootstrap(10_000)
        .map((d) => d.map((s) => s.count).sorted.median!)
        .sorted;

    return Confidence._(
      lower: Sample(data.percentile(0.025)!),
      upper: Sample(data.percentile(0.975)!),
    );
  }

  double get ciWidth => (upper.count - lower.count).toDouble();
}

abstract class Result implements Built<Result, ResultBuilder> {
  Result._();

  factory Result._build(void Function(ResultBuilder builder) build) = _$Result;

  DateTime get start;

  BuiltList<int> get taps;
  BuiltList<Sample> get samples;

  Sample get median;

  BuiltList<double> get residuals;
  double get maxAbsError;
  double get maxAbsErrorPercent;

  double get rootMeanSquareError;
  double get rmsePercent;

  Confidence get confidence => Confidence.from(samples.toList());

  factory Result.from(Iterable<DateTime> taps) => Result._build((builder) {
    final offsets = taps.map((tap) {
      builder.start ??= tap;
      final offset =
          tap.millisecondsSinceEpoch - builder.start!.millisecondsSinceEpoch;

      return offset;
    });

    builder.taps.addAll(offsets);

    if (builder.taps.length < 2) {
      throw ArgumentError(
        'At least 2 data points are required (${builder.taps.length} provided)',
        'taps',
      );
    }

    builder.samples.addAll(builder.taps.build().samples);

    final durations = builder.samples.build().map((s) => s.count).sorted;
    builder.median = Sample(durations.median!);

    final error = offsets.indexed
        .map((i) => (i.$2 - i.$1 * builder.median!.count).toDouble())
        .toList();

    builder.residuals.addAll(error);
    builder.maxAbsError = error.map((e) => e.abs()).max;
    builder.maxAbsErrorPercent = builder.maxAbsError! / builder.median!.count;

    // the first tap is always zero and will always have a residual of zero
    // for that reason, calculate RMSE using n - 1 elements to ignore the first
    builder.rootMeanSquareError = math.sqrt(
      error.map((e) => math.pow(e, 2)).sum / (error.length - 1),
    );
    builder.rmsePercent = builder.rootMeanSquareError! / builder.median!.count;
  });
}

class Sample {
  final num count;

  const Sample(this.count);

  Sample operator -(Sample other) {
    return Sample(count - other.count);
  }

  double get asBpm => 60_000 / count;

  @override
  String toString() {
    return '${count.toStringAsFixed(0)}ms (${asBpm.toStringAsFixed(1)} bpm)';
  }
}

class DistanceSample extends Sample {
  final int distance;

  const DistanceSample(super.count, this.distance);

  @override
  String toString() {
    return '${super.toString()} dist=$distance';
  }
}
