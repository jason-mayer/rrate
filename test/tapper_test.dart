import 'package:flutter_test/flutter_test.dart';
import 'package:rrate/stats.dart';

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
        minDuration: 200,
        rmseThreshold: 0.01,
        maxAbsErrorThreshold: 0.01,
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

    test('does not complete when RMSE exceeds threshold', () {
      final times = [
        DateTime(2026),
        DateTime(2026).add(const Duration(milliseconds: 100)),
        DateTime(2026).add(const Duration(milliseconds: 250)),
      ];
      var index = 0;

      final tapper = Tapper(
        sampleSize: 3,
        minDuration: 0,
        rmseThreshold: 0.10,
        maxAbsErrorThreshold: 1.0,
        clock: () => times[index++],
      );

      tapper.tap();
      tapper.tap();
      tapper.tap();

      expect(tapper.completer.isCompleted, isFalse);
      expect(tapper.estimate!.count, 125);
    });

    test('does not complete when maximum absolute error exceeds threshold', () {
      final times = [
        DateTime(2026),
        DateTime(2026).add(const Duration(milliseconds: 100)),
        DateTime(2026).add(const Duration(milliseconds: 250)),
      ];
      var index = 0;

      final tapper = Tapper(
        sampleSize: 3,
        minDuration: 0,
        rmseThreshold: 1.0,
        maxAbsErrorThreshold: 0.10,
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
        minDuration: 0,
        rmseThreshold: 0.10,
        maxAbsErrorThreshold: 0.10,
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

      // The first three taps are [0, 150, 200].
      expect(tapper.taps.offsets, equals([0, 150, 200]));

      tapper.tap();

      // The sliding window is now [0, 50, 200].
      expect(tapper.taps.offsets, equals([0, 50, 200]));
      // expect(tapper.taps, times);
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
        minDuration: 100,
        rmseThreshold: 0.01,
        maxAbsErrorThreshold: 0.01,
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
}
