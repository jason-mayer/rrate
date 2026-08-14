import 'dart:async';
import 'dart:math' as math;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/material.dart' hide Builder;
import 'package:rrate/number.dart';

part 'tapper.g.dart';

base class Tapper with ChangeNotifier {
  final int sampleSize;
  final double maxError;
  final DateTime Function() clock;

  Tapper({
    this.sampleSize = 5,
    this.maxError = 0.10,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  final List<DateTime> _taps = [];
  List<DateTime> get taps => List.unmodifiable(_taps);

  final Completer<Result> completer = Completer();

  Sample? _estimate;

  Sample? get estimate => _estimate;

  void _tap() {
    _taps.add(clock());

    if (_taps.length == 1) return;

    final result = Result.from(
      taps.skip(math.max(0, taps.length - sampleSize)),
    );

    _estimate = result.median;

    if (result.tapCount < sampleSize) return;
    if (result.rmsePercent > maxError) return;

    completer.complete(result);
  }

  void tap() {
    _tap();
    notifyListeners();
  }
}

abstract class Result implements Built<Result, ResultBuilder> {
  Result._();

  factory Result._build(void Function(ResultBuilder builder) build) = _$Result;

  DateTime get start;

  int get tapCount;
  int get sampleSize;

  BuiltList<int> get taps;
  BuiltList<Sample> get samples;

  Sample get min;
  Sample get q1;
  Sample get median;
  Sample get q3;
  Sample get max;

  double get medianAbsDeviation;
  double get robustCv;

  Sample? get confidence95lower;
  Sample? get confidence95upper;
  double? get ciWidth;
  double? get ciWidthPercent;

  BuiltList<double> get residuals;
  double get maxAbsError;
  double get maxAbsErrorPercent;

  double get rootMeanSquareError;
  double get rmsePercent;

  static final random = math.Random();

  factory Result.from(Iterable<DateTime> taps) => Result._build((builder) {
    final offsets = taps.map((tap) {
      builder.start ??= tap;
      final offset =
          tap.millisecondsSinceEpoch - builder.start!.millisecondsSinceEpoch;
      return offset;
    }).toList();

    builder.taps.addAll(offsets);
    final tapCount = offsets.length;
    builder.tapCount = tapCount;

    final samples = offsets.samples.toList();
    builder.samples.addAll(samples);

    final durations = samples.map((s) => s.count).sorted;

    builder.sampleSize = durations.length;
    builder.tapCount = tapCount;

    builder.min = Sample(durations.first);
    builder.q1 = Sample(durations.q1 ?? durations.median!);
    builder.median = Sample(durations.median!);
    builder.q3 = Sample(durations.q3 ?? durations.median!);
    builder.max = Sample(durations.last);

    builder.medianAbsDeviation = durations
        .absDeviationFrom(builder.median!.count)
        .sorted
        .median!;

    builder.robustCv = builder.medianAbsDeviation! / builder.median!.count;

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

    if (durations.length > 1) {
      final list = List.generate(10000, (_) {
        final taps = List.generate(samples.length, (index) {
          return samples[random.nextInt(samples.length)];
        });

        return taps.map((s) => s.count).sorted.median!;
      });

      list.sort((a, b) => a.compareTo(b));
      builder.confidence95lower = Sample(list.percentile(0.025)!);
      builder.confidence95upper = Sample(list.percentile(0.975)!);
      builder.ciWidth =
          (builder.confidence95upper! - builder.confidence95lower!).count
              .toDouble();

      builder.ciWidthPercent = builder.ciWidth! / builder.median!.count;
    }
  });
}

extension on List<num> {
  double? get median {
    if (isEmpty) return null;

    final index = length ~/ 2;

    if (length % 2 == 0) {
      return (this[index] + this[index - 1]) / 2;
    }

    return this[index].toDouble();
  }

  double? get q1 => take(length ~/ 2).toList().median;
  double? get q3 => skip(length ~/ 2 + length % 2).toList().median;

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

extension<N extends num> on Iterable<N> {
  N get max => reduce((a, b) => a > b ? a : b);
  N get sum => reduce((a, b) => a + b as N);

  List<N> get sorted => toList()..sort((a, b) => a.compareTo(b));

  Iterable<N> absDeviationFrom(N n) => map((s) => (s - n).abs() as N);

  // double? get correlation {
  //   int n = 0;
  //   int sumX = 0;
  //   num sumY = 0;
  //   num sumXY = 0;
  //   num sumX2 = 0;
  //   num sumY2 = 0;

  //   for (final (index, y) in indexed) {
  //     n++;
  //     final x = index;
  //     sumX += x;
  //     sumY += y;
  //     sumXY += x * y;
  //     sumX2 += math.pow(x, 2);
  //     sumY2 += math.pow(y, 2);
  //   }

  //   if (n == 0) return null;

  //   final top = (n * sumXY) - (sumX * sumY);
  //   final bottom = math.sqrt(
  //     ((n * sumX2) - math.pow(sumX, 2)) * ((n * sumY2) - math.pow(sumY, 2)),
  //   );

  //   return top / bottom;
  // }

  // double? get determination {
  //   final r = correlation;
  //   if (r == null) return null;
  //   return math.pow(r, 2).toDouble();
  // }

  // double? get adjustedR2 {
  //   int n = 0;
  //   final r2 = map((i) {
  //     n++;
  //     return i;
  //   }).determination;

  //   if (r2 == null) return null;
  //   if (n <= 2) return null;

  //   return 1 - ((1 - r2) * 500);
  // }

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
