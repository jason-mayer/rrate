import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide Builder;

import 'package:rrate/stats.dart';

base class Tapper with ChangeNotifier {
  /// Sample size.
  ///
  /// The tapper will analyze the most recent `sampleSize` taps. Any
  /// earlier taps will be discarded. The tapper will keep collecting data
  /// until at least `sampleSize` taps have been collected.
  ///
  /// Default: 5
  final int sampleSize;

  /// Minimum sampling duration, in milliseconds.
  ///
  /// The tapper will not complete until data has been collected for at
  /// least `minDuration` milliseconds.
  ///
  /// Default: 10_000 (10 seconds)
  final int minDuration;

  /// Maximum allowed normalized root mean square error (NRMSE)
  ///
  /// The tapper will keep collecting data until the NRMSE (RMSE / median)
  /// is equal to or below this threshold.
  ///
  /// Default: 0.075 (7.5%)
  final double rmseThreshold;

  /// Maximum allowed normalized maximum absolute error (NMAE)
  ///
  /// The tapper will keep collecting data until the NMAE (MAE / median)
  /// is equal to or below this threshold.
  ///
  /// Default: 0.1 (10%)
  final double maxAbsErrorThreshold;

  final DateTime Function() clock;

  Tapper({
    this.sampleSize = 5,
    this.minDuration = 10_000,
    this.rmseThreshold = 0.075,
    this.maxAbsErrorThreshold = 0.1,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now {
    if (sampleSize < 2) {
      throw ArgumentError.value(sampleSize, 'sampleSize');
    }
  }
  final List<DateTime> _taps = [];

  Iterable<DateTime> get taps =>
      _taps.skip(math.max(0, _taps.length - sampleSize));

  final Completer<Result> completer = Completer();

  Sample? _estimate;

  Sample? get estimate => _estimate;

  void _tap() {
    if (completer.isCompleted) {
      throw StateError('`tap` was called after the tapper completed');
    }

    _taps.add(clock());

    if (_taps.length == 1) return;

    final result = Result.from(taps);

    _estimate = result.median;

    if (result.taps.length < sampleSize) return;

    final duration =
        _taps.last.millisecondsSinceEpoch - _taps.first.millisecondsSinceEpoch;

    if (duration < minDuration) return;
    if (result.rmsePercent > rmseThreshold) return;
    if (result.maxAbsErrorPercent > maxAbsErrorThreshold) return;

    completer.complete(result);
  }

  void tap() {
    _tap();
    notifyListeners();
  }
}
