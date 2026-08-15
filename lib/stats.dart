import 'dart:math' as math;

import 'package:rrate/tapper.dart';

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
