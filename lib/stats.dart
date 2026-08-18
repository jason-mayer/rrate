import 'dart:math' as math;

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

  Iterable<double> residuals(Sample estimate) =>
      indexed.map((i) => (i.$2 - i.$1 * estimate.count).toDouble());
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

extension SampleIterable on Iterable<Sample> {
  Iterable<num> get counts => map((s) => s.count);
  List<Sample> get sorted => toList()..sort((a, b) => a.compareTo(b));
}

extension SampleList on List<Sample> {
  Sample? get median {
    if (isEmpty) return null;

    final index = length ~/ 2;

    if (length % 2 == 0) {
      return Sample((this[index].count + this[index - 1].count) / 2);
    }

    return this[index];
  }
}

extension DateTimeIterable on Iterable<DateTime> {
  Iterable<int> get offsets {
    final first = firstOrNull;

    if (first == null) {
      return const Iterable.empty();
    }

    return map((t) => t.millisecondsSinceEpoch - first.millisecondsSinceEpoch);
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

    final data = samples.counts
        .toList()
        .bootstrap(10_000)
        .map((d) => d.sorted.median!)
        .sorted;

    return Confidence._(
      lower: Sample(data.percentile(0.025)!),
      upper: Sample(data.percentile(0.975)!),
    );
  }

  double get ciWidth => (upper.count - lower.count).toDouble();
}

class Result {
  const Result._({
    required this.start,
    required this.taps,
    required this.samples,
    required this.median,
    required this.maxAbsError,
    required this.rootMeanSquareError,
  });

  final DateTime start;

  final List<int> taps;
  final List<DistanceSample> samples;

  final Sample median;

  final double maxAbsError;
  final double rootMeanSquareError;

  Confidence get confidence => Confidence.from(samples.toList());
  Iterable<num> get residuals => taps.residuals(median);
  double get rmsePercent => rootMeanSquareError / median.count;
  double get maxAbsErrorPercent => maxAbsError / median.count;

  factory Result.from(Iterable<DateTime> times) {
    final start = times.firstOrNull;
    final taps = times.offsets.toList();

    if (taps.length < 2) {
      throw ArgumentError(
        'At least 2 data points are required (${taps.length} provided)',
        'times',
      );
    }

    final samples = taps.samples.toList();
    final median = samples.sorted.median!;

    final residuals = taps.residuals(median);

    return Result._(
      start: start!,
      taps: taps,
      samples: samples,
      median: samples.sorted.median!,
      maxAbsError: residuals.map((e) => e.abs()).max,
      // the first tap is always zero and will always have a residual of zero
      // for that reason, calculate RMSE using n - 1 elements to ignore first
      rootMeanSquareError: math.sqrt(
        residuals.map((e) => math.pow(e, 2)).sum / (taps.length - 1),
      ),
    );
  }

  @override
  String toString() {
    final confidence = this.confidence;

    return '''Result {
  start: $start
  taps: ${taps.formatted}

  samples:
${_formatSamples(samples)}

  median: $median

  residuals: ${residuals.formatted}
  maxAbsError: $maxAbsError (${maxAbsErrorPercent.percent})
  rootMeanSquareError: $rootMeanSquareError (${rmsePercent.percent})

  confidence:
    upper: ${confidence.upper}
    lower: ${confidence.lower}
    width: ${confidence.ciWidth}
}''';
  }
}

class Sample {
  final num count;

  const Sample(this.count);

  double get asBpm => 60_000 / count;

  @override
  String toString() {
    return '${count.toStringAsFixed(0)}ms (${asBpm.toStringAsFixed(0)} bpm)';
  }

  int compareTo(Sample other) {
    return count.compareTo(other.count);
  }

  @override
  bool operator ==(Object other) {
    if (other is! Sample) return false;
    return other.count == count;
  }

  @override
  int get hashCode => count.hashCode;
}

class DistanceSample extends Sample {
  final int distance;

  const DistanceSample(super.count, this.distance);
}

String _formatSamples(Iterable<DistanceSample> samples) {
  final Map<int, List<Sample>> map = .new();

  for (final sample in samples) {
    map[sample.distance] ??= [];
    map[sample.distance]!.add(sample);
  }

  return map.entries
      .map((e) => '    distance ${e.key}: ${e.value.formatted}')
      .join('\n');
}

// formatting extensions
extension on Iterable {
  String get formatted => '[${join(', ')}]';
}

extension on double {
  String get percent => '${(this * 100).toStringAsFixed(1)}%';
}
