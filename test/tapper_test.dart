import 'package:flutter_test/flutter_test.dart';

import 'package:rrate/tapper.dart';

void main() {
  group('Tapper', () {
    test('rejects sampleSize less than 2', () {
      expect(
        () => Tapper(sampleSize: 1),
        throwsA(
          isA<ArgumentError>()
              .having((e) => e.name, 'name', 'sampleSize')
              .having((e) => e.invalidValue, 'invalidValue', 1),
        ),
      );

      expect(() => Tapper(sampleSize: 0), throwsArgumentError);
      expect(() => Tapper(sampleSize: -1), throwsArgumentError);
    });

    test('starts with no taps or estimate', () {
      final tapper = Tapper();

      expect(tapper.taps, isEmpty);
      expect(tapper.estimate, isNull);
      expect(tapper.completer.isCompleted, isFalse);
    });

    test('records taps using the supplied clock', () {
      var index = 0;
      final times = [
        DateTime(2026, 1, 1, 12, 0, 0),
        DateTime(2026, 1, 1, 12, 0, 0, 100),
      ];

      final tapper = Tapper(clock: () => times[index++]);

      tapper.tap();
      tapper.tap();

      expect(tapper.taps, times);
    });

    test('taps are unmodifiable', () {
      final tapper = Tapper(clock: () => DateTime(2026));

      tapper.tap();

      expect(() => tapper.taps.add(DateTime(2026)), throwsUnsupportedError);
    });

    test('does not produce an estimate after the first tap', () {
      final tapper = Tapper(clock: () => DateTime(2026));

      tapper.tap();

      expect(tapper.estimate, isNull);
      expect(tapper.completer.isCompleted, isFalse);
    });

    test('produces an estimate after the second tap', () {
      var time = DateTime(2026);

      final tapper = Tapper(
        clock: () {
          final result = time;
          time = time.add(const Duration(milliseconds: 100));
          return result;
        },
      );

      tapper.tap();
      tapper.tap();

      expect(tapper.estimate, isNotNull);
      expect(tapper.estimate!.count, 100);
      expect(tapper.completer.isCompleted, isFalse);
    });

    test('completes once sampleSize taps have acceptable error', () async {
      var time = DateTime(2026);

      final tapper = Tapper(
        sampleSize: 3,
        maxError: 0.01,
        clock: () {
          final result = time;
          time = time.add(const Duration(milliseconds: 100));
          return result;
        },
      );

      tapper.tap();
      expect(tapper.completer.isCompleted, isFalse);

      tapper.tap();
      expect(tapper.completer.isCompleted, isFalse);

      tapper.tap();

      expect(tapper.completer.isCompleted, isTrue);

      final result = await tapper.completer.future;

      expect(result.taps, [0, 100, 200]);
      expect(result.median.count, 100);
      expect(result.rmsePercent, 0);
    });

    test('does not complete when RMSE exceeds maxError', () {
      final times = [
        DateTime(2026),
        DateTime(2026).add(const Duration(milliseconds: 100)),
        DateTime(2026).add(const Duration(milliseconds: 250)),
      ];
      var index = 0;

      final tapper = Tapper(
        sampleSize: 3,
        maxError: 0.10,
        clock: () => times[index++],
      );

      tapper.tap();
      tapper.tap();
      tapper.tap();

      expect(tapper.completer.isCompleted, isFalse);
      expect(tapper.estimate!.count, 125);
    });

    test('can complete on a later tap after an inaccurate sample', () async {
      final intervals = [150, 100, 100, 100];

      var time = DateTime(2026);
      var index = 0;

      final tapper = Tapper(
        sampleSize: 3,
        maxError: 0.10,
        clock: () {
          final result = time;
          if (index < intervals.length) {
            time = time.add(Duration(milliseconds: intervals[index++]));
          }
          return result;
        },
      );

      tapper.tap();
      tapper.tap();
      tapper.tap();

      expect(tapper.completer.isCompleted, isFalse);

      tapper.tap();

      expect(tapper.completer.isCompleted, isTrue);

      final result = await tapper.completer.future;

      expect(result.taps.length, 3);
      expect(result.median.count, 100);
    });

    test('uses only the most recent sampleSize taps', () {
      final times = [
        DateTime(2026),
        DateTime(2026).add(const Duration(milliseconds: 150)),
        DateTime(2026).add(const Duration(milliseconds: 200)),
        DateTime(2026).add(const Duration(milliseconds: 350)),
      ];
      var index = 0;

      final tapper = Tapper(sampleSize: 3, clock: () => times[index++]);

      tapper.tap();
      tapper.tap();
      tapper.tap();

      // The first three taps are [0, 100, 200].
      expect(tapper.estimate!.count, 100);

      tapper.tap();

      // The sliding window is now [100, 200, 300].
      expect(tapper.estimate!.count, 100);
      expect(tapper.taps, times);
    });

    test('notifies listeners after every successful tap', () {
      final tapper = Tapper(clock: () => DateTime(2026));

      var notifications = 0;
      tapper.addListener(() => notifications++);

      tapper.tap();
      tapper.tap();
      tapper.tap();

      expect(notifications, 3);
    });

    test('throws when tapped after completion', () {
      var time = DateTime(2026);

      final tapper = Tapper(
        sampleSize: 2,
        maxError: 0.01,
        clock: () {
          final result = time;
          time = time.add(const Duration(milliseconds: 100));
          return result;
        },
      );

      tapper.tap();
      tapper.tap();

      expect(tapper.completer.isCompleted, isTrue);

      expect(
        tapper.tap,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            '`tap` was called after the tapper completed',
          ),
        ),
      );
    });
  });

  group('Result', () {
    test('requires at least two taps', () {
      expect(() => Result.from([DateTime(2026)]), throwsArgumentError);

      expect(() => Result.from(const <DateTime>[]), throwsArgumentError);
    });

    test('calculates offsets from the first tap', () {
      final result = Result.from([
        DateTime(2026),
        DateTime(2026).add(const Duration(milliseconds: 100)),
        DateTime(2026).add(const Duration(milliseconds: 250)),
      ]);

      expect(result.taps, [0, 100, 250]);
      expect(result.start, DateTime(2026));
    });

    test('calculates samples from pairwise tap distances', () {
      final result = Result.from([
        DateTime(2026),
        DateTime(2026).add(const Duration(milliseconds: 100)),
        DateTime(2026).add(const Duration(milliseconds: 200)),
      ]);

      expect(result.samples.map((s) => s.count), [100, 100, 100]);
    });

    test('calculates the median sample', () {
      final result = Result.from([
        DateTime(2026),
        DateTime(2026).add(const Duration(milliseconds: 100)),
        DateTime(2026).add(const Duration(milliseconds: 300)),
        DateTime(2026).add(const Duration(milliseconds: 600)),
      ]);

      // 100, 150, 200, 200, 250, 300
      // sorted: 100, 150, 200, 200, 250, 300
      // median = 200
      expect(result.median.count, 200);
    });

    test('calculates zero error for perfectly regular taps', () {
      final result = Result.from([
        DateTime(2026),
        DateTime(2026).add(const Duration(milliseconds: 100)),
        DateTime(2026).add(const Duration(milliseconds: 200)),
        DateTime(2026).add(const Duration(milliseconds: 300)),
      ]);

      expect(
        result.toString(),
        equalsIgnoringWhitespace('''
Result {
  start=2026-01-01 00:00:00.000,
  taps=[0, 100, 200, 300],
  samples=[100ms (600.0 bpm) dist=1, 100ms (600.0 bpm) dist=2, 100ms (600.0 bpm) dist=1, 100ms (600.0 bpm) dist=3, 100ms (600.0 bpm) dist=2, 100ms (600.0 bpm) dist=1],
  median=100ms (600.0 bpm),
  residuals=[0.0, 0.0, 0.0, 0.0],
  maxAbsError=0.0,
  maxAbsErrorPercent=0.0,
  rootMeanSquareError=0.0,
  rmsePercent=0.0,
}
'''),
      );
    });

    test('calculates residuals', () {
      final result = Result.from([
        DateTime(2026),
        DateTime(2026).add(const Duration(milliseconds: 100)),
        DateTime(2026).add(const Duration(milliseconds: 250)),
      ]);

      expect(result.median.count, 125);
      expect(result.residuals, [0, -25, 0]);
    });

    test('calculates maximum absolute error', () {
      final result = Result.from([
        DateTime(2026),
        DateTime(2026).add(const Duration(milliseconds: 100)),
        DateTime(2026).add(const Duration(milliseconds: 250)),
      ]);

      expect(result.maxAbsError, 25);
      expect(result.maxAbsErrorPercent, 0.2);
    });

    test('calculates RMSE while excluding the first zero residual', () {
      final result = Result.from([
        DateTime(2026),
        DateTime(2026).add(const Duration(milliseconds: 100)),
        DateTime(2026).add(const Duration(milliseconds: 250)),
      ]);

      expect(result.rootMeanSquareError, closeTo(17.6, 0.1));

      expect(result.rmsePercent, closeTo(0.14, 0.01));
    });

    test('preserves tap ordering', () {
      final start = DateTime(2026, 1, 1, 12);

      final result = Result.from([
        start,
        start.add(const Duration(milliseconds: 150)),
        start.add(const Duration(milliseconds: 300)),
      ]);

      expect(result.taps, [0, 150, 300]);
    });
  });

  group('Confidence', () {
    test('produces a confidence interval', () {
      final result = Result.from([
        DateTime(2026),
        DateTime(2026).add(const Duration(milliseconds: 100)),
        DateTime(2026).add(const Duration(milliseconds: 200)),
        DateTime(2026).add(const Duration(milliseconds: 300)),
      ]);

      final confidence = result.confidence;

      expect(confidence.lower.count, lessThanOrEqualTo(confidence.upper.count));
      expect(confidence.ciWidth, greaterThanOrEqualTo(0));
    });

    test('confidence interval contains the median for stable samples', () {
      final result = Result.from([
        DateTime(2026),
        DateTime(2026).add(const Duration(milliseconds: 100)),
        DateTime(2026).add(const Duration(milliseconds: 200)),
        DateTime(2026).add(const Duration(milliseconds: 300)),
        DateTime(2026).add(const Duration(milliseconds: 400)),
      ]);

      final confidence = result.confidence;

      expect(confidence.lower.count, lessThanOrEqualTo(result.median.count));
      expect(confidence.upper.count, greaterThanOrEqualTo(result.median.count));

      expect(
        confidence.ciWidth,
        closeTo(
          (confidence.upper - confidence.lower).count.toDouble(),
          0.000001,
        ),
      );
    });
  });
}
