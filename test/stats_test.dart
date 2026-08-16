import 'package:flutter_test/flutter_test.dart';
import 'package:rrate/stats.dart';

void testSorted<T>({
  required List<T> Function(Iterable<T>) sort,
  required Iterable<T> Function(Iterable<int>) map,
}) {
  group('sorted', () {
    test('sorts values in ascending order', () {
      expect(sort(map([5, 1, 4, 2, 3])), equals(map([1, 2, 3, 4, 5]).toList()));
    });

    test('does not modify the original iterable when it is a list', () {
      final values = map([3, 1, 2]).toList();

      final sorted = sort(values);

      expect(values, equals(map([3, 1, 2]).toList()));
      expect(sorted, equals(map([1, 2, 3]).toList()));
    });

    test('works with duplicates', () {
      expect(sort(map([3, 1, 3, 2, 1])), equals(map([1, 1, 2, 3, 3]).toList()));
    });

    test('works with negative values', () {
      expect(
        sort(map([2, -5, 0, -1, 3])),
        equals(map([-5, -1, 0, 2, 3]).toList()),
      );
    });
  });
}

void testMedian<T>({
  required T Function(num number) map,
  required T? Function(List<T> list) median,
}) {
  List<T> list(Iterable<num> nums) => nums.map((e) => map(e)).toList();

  group('median', () {
    test('returns null for an empty list', () {
      expect(median(<T>[]), isNull);
    });

    test('returns the only value for a single-element list', () {
      expect(median(list([42])), equals(map(42)));
    });

    test('returns the middle value for an odd-length list', () {
      expect(median(list([1, 2, 3, 4, 5])), equals(map(3)));
    });

    test('returns the average of the two middle values for an even list', () {
      expect(median(list([1, 2, 3, 4])), equals(map(2.5)));
    });

    test('does not sort the input', () {
      final values = list([5, 1, 3]);

      expect(median(values), equals(map(1)));
      expect(values, equals(list([5, 1, 3])));
    });

    test('works with doubles', () {
      expect(median(list([1.5, 2.5, 10.0])), equals(map(2.5)));
    });

    test('works with negative values', () {
      expect(median(list([-5, -3, -1])), equals(map(-3)));
      expect(median(list([-5, -4, -1, 2])), equals(map(-2.5)));
    });
  });
}

void main() {
  group('ListNumStats', () {
    testMedian(map: (number) => number, median: (list) => list.median);

    group('percentile', () {
      test('returns null for an empty list', () {
        expect(<num>[].percentile(0.5), isNull);
      });

      test('returns first value at the 0th percentile', () {
        expect([10, 20, 30].percentile(0), 10);
      });

      test('returns last value at the 100th percentile', () {
        expect([10, 20, 30].percentile(1), 30);
      });

      test('returns the middle value at the 50th percentile', () {
        expect([10, 20, 30].percentile(0.5), 20);
      });

      test('linearly interpolates between values', () {
        expect([0, 10].percentile(0.25), 2.5);
        expect([0, 10].percentile(0.75), 7.5);
      });

      test('interpolates correctly with more than two values', () {
        // Position = .25 * (4 - 1) = .75
        // 10 + .75 * (20 - 10) = 17.5
        expect([10, 20, 30, 40].percentile(0.25), 17.5);
      });

      test('works with a single value', () {
        expect([42].percentile(0), 42);
        expect([42].percentile(0.5), 42);
        expect([42].percentile(1), 42);
      });
    });
  });

  group('ListStats', () {
    group('resampled', () {
      test('has the same length as the source list', () {
        final source = [1, 2, 3, 4, 5];

        expect(source.resampled.length, source.length);
      });

      test('only contains values from the source list', () {
        final source = [1, 2, 3, 4, 5];

        expect(source.resampled.every(source.contains), isTrue);
      });

      test('can contain duplicate values', () {
        // A resample is sampling with replacement.
        final source = [1, 2];

        final samples = List.generate(100, (_) => source.resampled.toList());

        expect(samples.any((sample) => sample[0] == sample[1]), isTrue);
      });

      test('resampling does not modify the source list', () {
        final source = [1, 2, 3];
        final original = [...source];

        source.resampled.toList();

        expect(source, original);
      });
    });

    group('bootstrap', () {
      test('returns the requested number of iterations', () {
        final source = [1, 2, 3];

        expect(source.bootstrap(0), isEmpty);
        expect(source.bootstrap(1), hasLength(1));
        expect(source.bootstrap(100), hasLength(100));
      });

      test('each iteration has the same size as the source', () {
        final source = [1, 2, 3, 4];

        for (final sample in source.bootstrap(100)) {
          expect(sample, hasLength(source.length));
        }
      });

      test('each iteration contains only source values', () {
        final source = [1, 2, 3, 4];

        for (final sample in source.bootstrap(100)) {
          expect(sample.every(source.contains), isTrue);
        }
      });

      test('sampling is with replacement', () {
        final source = [1, 2];

        final bootstrap = source.bootstrap(1000);

        expect(
          bootstrap.any((sample) => sample.every((value) => value == 1)),
          isTrue,
        );

        expect(
          bootstrap.any((sample) => sample.every((value) => value == 2)),
          isTrue,
        );
      });

      test('is lazy', () {
        final source = [1, 2, 3];

        final bootstrap = source.bootstrap(100);

        // Nothing needs to be generated until iterated.
        expect(bootstrap, isA<Iterable<Iterable<int>>>());

        final first = bootstrap.first;

        expect(first, hasLength(3));
      });
    });
  });

  group('IterableStats', () {
    group('max', () {
      test('returns the maximum value', () {
        expect([1, 5, 3, 2, 4].max, 5);
      });

      test('works with negative values', () {
        expect([-10, -3, -7].max, -3);
      });

      test('works with a single value', () {
        expect([42].max, 42);
      });

      test('throws for an empty iterable', () {
        expect(() => <int>[].max, throwsStateError);
      });
    });

    group('sum', () {
      test('returns the sum', () {
        expect([1, 2, 3, 4].sum, 10);
      });

      test('returns zero for values that sum to zero', () {
        expect([-5, 2, 3].sum, 0);
      });

      test('works with a single value', () {
        expect([42].sum, 42);
      });

      test('throws for an empty iterable', () {
        expect(() => <int>[].sum, throwsStateError);
      });

      test('preserves the numeric type', () {
        final result = [1.0, 2.0, 3.0].sum;

        expect(result, isA<double>());
        expect(result, 6.0);
      });
    });

    testSorted(sort: (i) => i.sorted, map: (n) => n);

    group('samples', () {
      test('returns no samples for an empty iterable', () {
        expect(<int>[].samples, isEmpty);
      });

      test('returns no samples for a single value', () {
        expect([100].samples, isEmpty);
      });

      test('generates pairwise distance samples', () {
        final samples = [0, 100, 200].samples.toList();

        expect(samples, hasLength(3));

        expect(samples.map((s) => s.count), [100, 100, 100]);

        expect(samples.map((s) => s.distance), [1, 2, 1]);
      });

      test('calculates rates using the distance between observations', () {
        final samples = [0, 100, 300].samples.toList();

        expect(samples, hasLength(3));

        // 100 - 0 over 1 = 100
        expect(samples[0].count, 100);
        expect(samples[0].distance, 1);

        // 300 - 0 over 2 = 150
        expect(samples[1].count, 150);
        expect(samples[1].distance, 2);

        // 300 - 100 over 1 = 200
        expect(samples[2].count, 200);
        expect(samples[2].distance, 1);
      });

      test('generates samples in pair order', () {
        final samples = [0, 10, 30, 60].samples.toList();

        expect(samples.map((s) => s.count), [10, 15, 20, 20, 25, 30]);

        expect(samples.map((s) => s.distance), [1, 2, 1, 3, 2, 1]);
      });

      test('works with negative values', () {
        final samples = [-10, 0, 10].samples.toList();

        expect(samples.map((s) => s.count), [10, 10, 10]);
      });

      test('works with doubles', () {
        final samples = [0.0, 1.5, 4.5].samples.toList();

        expect(samples.map((s) => s.count), [1.5, 2.25, 3.0]);
      });
    });
  });

  group('SampleIterable', () {
    test('returns correct counts', () {
      final samples = [const Sample(1), const Sample(2), const Sample(3)];
      final counts = [1, 2, 3];

      expect(samples.counts.toList(), equals(counts));
    });

    testMedian(map: (number) => Sample(number), median: (list) => list.median);
    testSorted(
      sort: (list) => list.sorted,
      map: (e) => e.map((s) => Sample(s)),
    );
  });

  group('Confidence', () {
    test('rejects an empty sample list', () {
      expect(
        () => Confidence.from([]),
        throwsA(isA<ArgumentError>().having((e) => e.name, 'name', 'samples')),
      );
    });

    test('produces bounds for a single sample value', () {
      final samples = [const Sample(100)];

      final confidence = Confidence.from(samples);

      expect(confidence.lower.count, 100);
      expect(confidence.upper.count, 100);
      expect(confidence.ciWidth, 0);
    });

    test('produces bounds containing the median for stable data', () {
      final samples = [
        const Sample(100),
        const Sample(100),
        const Sample(100),
        const Sample(100),
        const Sample(100),
      ];

      final confidence = Confidence.from(samples);

      expect(confidence.lower.count, 100);
      expect(confidence.upper.count, 100);
      expect(confidence.ciWidth, 0);
    });

    test('confidence interval has non-negative width', () {
      final samples = [
        const Sample(80),
        const Sample(90),
        const Sample(100),
        const Sample(110),
        const Sample(120),
      ];

      final confidence = Confidence.from(samples);

      expect(confidence.lower.count, lessThanOrEqualTo(confidence.upper.count));
      expect(confidence.ciWidth, greaterThanOrEqualTo(0));
    });

    test('confidence bounds come from the observed range', () {
      final samples = [
        const Sample(10),
        const Sample(20),
        const Sample(30),
        const Sample(40),
        const Sample(50),
      ];

      final confidence = Confidence.from(samples);

      expect(confidence.lower.count, inInclusiveRange(10, 50));
      expect(confidence.upper.count, inInclusiveRange(10, 50));
    });

    test('ciWidth equals upper minus lower', () {
      final samples = [
        const Sample(10),
        const Sample(20),
        const Sample(30),
        const Sample(40),
        const Sample(50),
      ];

      final confidence = Confidence.from(samples);

      expect(
        confidence.ciWidth,
        (confidence.upper.count - confidence.lower.count).toDouble(),
      );
    });

    test('bootstrap confidence interval is reproducibly bounded', () {
      final samples = [
        const Sample(100),
        const Sample(101),
        const Sample(102),
        const Sample(103),
        const Sample(104),
        const Sample(105),
      ];

      // Because Confidence.from uses random resampling, don't assert
      // exact percentile values.
      final confidence = Confidence.from(samples);

      expect(confidence.lower.count, greaterThanOrEqualTo(100));
      expect(confidence.upper.count, lessThanOrEqualTo(105));
      expect(confidence.lower.count, lessThanOrEqualTo(confidence.upper.count));
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
  start: 2026-01-01 00:00:00.000
  taps: [0, 100, 200, 300]

  samples:
    distance 1: [100ms (600 bpm), 100ms (600 bpm), 100ms (600 bpm)]
    distance 2: [100ms (600 bpm), 100ms (600 bpm)]
    distance 3: [100ms (600 bpm)]

  median: 100ms (600 bpm)

  residuals: [0.0, 0.0, 0.0, 0.0]
  maxAbsError: 0.0 (0.0%)
  rootMeanSquareError: 0.0 (0.0%)

  confidence:
    upper: 100ms (600 bpm)
    lower: 100ms (600 bpm)
    width: 0.0
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

    group('Confidence', () {
      test('produces a confidence interval', () {
        final result = Result.from([
          DateTime(2026),
          DateTime(2026).add(const Duration(milliseconds: 100)),
          DateTime(2026).add(const Duration(milliseconds: 200)),
          DateTime(2026).add(const Duration(milliseconds: 300)),
        ]);

        final confidence = result.confidence;

        expect(
          confidence.lower.count,
          lessThanOrEqualTo(confidence.upper.count),
        );
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
        expect(
          confidence.upper.count,
          greaterThanOrEqualTo(result.median.count),
        );
      });
    });
  });
}
