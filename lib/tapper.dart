import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide Builder;

import 'package:rrate/stats.dart';

base class Tapper with ChangeNotifier {
  final int sampleSize;
  final double maxError;
  final DateTime Function() clock;

  Tapper({
    this.sampleSize = 5,
    this.maxError = 0.10,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now {
    if (sampleSize < 2) {
      throw ArgumentError.value(sampleSize, 'sampleSize');
    }
  }
  final List<DateTime> _taps = [];
  List<DateTime> get taps => List.unmodifiable(_taps);

  final Completer<Result> completer = Completer();

  Sample? _estimate;

  Sample? get estimate => _estimate;

  void _tap() {
    if (completer.isCompleted) {
      throw StateError('`tap` was called after the tapper completed');
    }

    _taps.add(clock());

    if (_taps.length == 1) return;

    final result = Result.from(
      taps.skip(math.max(0, taps.length - sampleSize)),
    );

    _estimate = result.median;

    if (result.taps.length < sampleSize) return;
    if (result.rmsePercent > maxError) return;

    completer.complete(result);
  }

  void tap() {
    _tap();
    notifyListeners();
  }
}
