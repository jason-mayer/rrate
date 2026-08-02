import 'dart:math' as math;

import 'package:built_value/built_value.dart';
import 'package:flutter/material.dart' hide Builder;
import 'package:rrate/number.dart';

part 'tapper.g.dart';

abstract class Estimate implements Built<Estimate, EstimateBuilder> {
  Estimate._();

  factory Estimate(void Function(EstimateBuilder builder) build) = _$Estimate;

  int get index;

  Sample get duration;
  Sample get runningAverage;

  double? get stability;
}

base class Tapper with ChangeNotifier {
  final int bpmVarianceThreshold;
  final double stabilityWeight;
  final DateTime Function() clock;

  Tapper({
    this.bpmVarianceThreshold = 40,
    this.stabilityWeight = 0.5,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  final List<DateTime> _taps = [];
  final List<Estimate> _estimates = [];

  List<DateTime> get taps => List.unmodifiable(_taps);
  List<Estimate> get estimates => List.unmodifiable(_estimates);

  Estimate? get estimate => _estimates.lastOrNull;

  void tap() {
    final now = clock();
    final last = _taps.lastOrNull;
    _taps.add(now);

    if (last != null) {
      _sample(Sample.from(now) - Sample.from(last));
    }

    notifyListeners();
  }

  double _stability = 0;
  Sample _sum = const Sample(0);
  Sample? _average;

  void _sample(Sample sample) {
    _sum += sample;

    final estimate = Estimate((builder) {
      builder
        ..index = _estimates.length
        ..duration = sample
        ..runningAverage = _sum / (_estimates.length + 1);

      if (_average == null) return;

      final thresholdBpm = builder.runningAverage!.asBpm / bpmVarianceThreshold,
          thresholdMs =
              math.pow(builder.runningAverage!.count, 2) /
              60_000 *
              thresholdBpm,
          deltaAverage = (builder.runningAverage! - _average!).count.abs(),
          stability = math.exp(
            -(deltaAverage / thresholdMs) * (deltaAverage / thresholdMs),
          );

      builder.stability =
          stabilityWeight * _stability + (1 - stabilityWeight) * stability;
    });

    _stability = estimate.stability ?? 0;
    _average = estimate.runningAverage;

    _estimates.add(estimate);
  }

  Iterable<String> get delays => _estimates.map((d) => d.toString());
}
