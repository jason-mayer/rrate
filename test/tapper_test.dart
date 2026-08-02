import 'package:flutter_test/flutter_test.dart';
import 'package:rrate/tapper.dart';

void main() {
  group('Tapper', () {
    late int count;
    late Tapper tapper;

    setUp(() {
      count = 0;
      tapper = Tapper(
        clock: () {
          count++;
          return DateTime(2026, 1, 1, 0, 0, count, 0);
        },
      );
    });

    List<double> tap(int count) {
      final out = <double>[];
      for (final _ in Iterable.generate(count)) {
        tapper.tap();

        if (tapper.estimate == null) continue;

        out.add(tapper.estimate!.stability ?? 0);
      }

      return out;
    }

    test('starts with no taps or estimates', () {
      expect(tapper.taps, isEmpty);
      expect(tapper.estimates, isEmpty);
      expect(tapper.estimate, isNull);
    });

    test('first tap records tap but does not create estimate', () {
      tap(1);

      expect(tapper.taps.length, 1);
      expect(tapper.estimates, isEmpty);
      expect(tapper.estimate, isNull);
    });

    test('second tap creates first estimate', () {
      tap(2);

      expect(tapper.taps.length, 2);
      expect(tapper.estimates.length, 1);

      final estimate = tapper.estimate!;

      expect(estimate.index, 0);
      expect(estimate.duration.count, 1000);
      expect(estimate.runningAverage.count, 1000);
      expect(estimate.stability, isNull);
      expect(estimate.stability, isNull);
    });

    test('running average is calculated correctly', () {
      tapper.tap(); // t=0
      tapper.tap(); // +1000ms
      tapper.tap(); // +1000ms

      expect(tapper.estimates.length, 2);

      expect(tapper.estimates[0].runningAverage.count, 1000);

      expect(tapper.estimates[1].runningAverage.count, 1000);
    });

    test('estimate indexes increment', () {
      tapper.tap();
      tapper.tap();
      tapper.tap();

      expect(tapper.estimates.map((e) => e.index), [0, 1]);
    });

    test('stability is high for consistent taps', () {
      final curve = tap(10);
      final expected = [
        0.0,
        0.5,
        0.75,
        0.875,
        0.9375,
        0.96875,
        0.984375,
        0.9921875,
        0.99609375,
      ];

      final estimate = tapper.estimate!;

      expect(estimate.stability, closeTo(1, 0.005));
      expect(curve, equals(expected));
    });

    test('stability decreases for inconsistent taps', () {
      final times = [
        DateTime(2026, 1, 1, 0, 0, 0),
        DateTime(2026, 1, 1, 0, 0, 1),
        DateTime(2026, 1, 1, 0, 0, 5),
      ];

      tapper = Tapper(clock: () => times.removeAt(0));

      tap(3);

      final estimate = tapper.estimate!;
      expect(estimate.stability!, lessThan(1));
    });

    test('notifies listeners on tap', () {
      var notifications = 0;

      tapper.addListener(() {
        notifications++;
      });

      tapper.tap();
      tapper.tap();

      expect(notifications, 2);
    });

    test('taps list is immutable', () {
      tapper.tap();

      expect(() => tapper.taps.add(DateTime.now()), throwsUnsupportedError);
    });

    test('estimates list is immutable', () {
      tapper.tap();
      tapper.tap();

      expect(
        () => tapper.estimates.add(tapper.estimate!),
        throwsUnsupportedError,
      );
    });

    test('delays returns estimate strings', () {
      tapper.tap();
      tapper.tap();

      expect(tapper.delays.single, contains('1000ms'));
    });
  });
}
