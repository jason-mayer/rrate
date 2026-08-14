// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tapper.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Result extends Result {
  @override
  final DateTime start;
  @override
  final int tapCount;
  @override
  final int sampleSize;
  @override
  final BuiltList<int> taps;
  @override
  final BuiltList<Sample> samples;
  @override
  final Sample min;
  @override
  final Sample q1;
  @override
  final Sample median;
  @override
  final Sample q3;
  @override
  final Sample max;
  @override
  final double medianAbsDeviation;
  @override
  final double robustCv;
  @override
  final Sample? confidence95lower;
  @override
  final Sample? confidence95upper;
  @override
  final double? ciWidth;
  @override
  final double? ciWidthPercent;
  @override
  final BuiltList<double> residuals;
  @override
  final double maxAbsError;
  @override
  final double maxAbsErrorPercent;
  @override
  final double rootMeanSquareError;
  @override
  final double rmsePercent;

  factory _$Result([void Function(ResultBuilder)? updates]) =>
      (ResultBuilder()..update(updates))._build();

  _$Result._({
    required this.start,
    required this.tapCount,
    required this.sampleSize,
    required this.taps,
    required this.samples,
    required this.min,
    required this.q1,
    required this.median,
    required this.q3,
    required this.max,
    required this.medianAbsDeviation,
    required this.robustCv,
    this.confidence95lower,
    this.confidence95upper,
    this.ciWidth,
    this.ciWidthPercent,
    required this.residuals,
    required this.maxAbsError,
    required this.maxAbsErrorPercent,
    required this.rootMeanSquareError,
    required this.rmsePercent,
  }) : super._();
  @override
  Result rebuild(void Function(ResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResultBuilder toBuilder() => ResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Result &&
        start == other.start &&
        tapCount == other.tapCount &&
        sampleSize == other.sampleSize &&
        taps == other.taps &&
        samples == other.samples &&
        min == other.min &&
        q1 == other.q1 &&
        median == other.median &&
        q3 == other.q3 &&
        max == other.max &&
        medianAbsDeviation == other.medianAbsDeviation &&
        robustCv == other.robustCv &&
        confidence95lower == other.confidence95lower &&
        confidence95upper == other.confidence95upper &&
        ciWidth == other.ciWidth &&
        ciWidthPercent == other.ciWidthPercent &&
        residuals == other.residuals &&
        maxAbsError == other.maxAbsError &&
        maxAbsErrorPercent == other.maxAbsErrorPercent &&
        rootMeanSquareError == other.rootMeanSquareError &&
        rmsePercent == other.rmsePercent;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, start.hashCode);
    _$hash = $jc(_$hash, tapCount.hashCode);
    _$hash = $jc(_$hash, sampleSize.hashCode);
    _$hash = $jc(_$hash, taps.hashCode);
    _$hash = $jc(_$hash, samples.hashCode);
    _$hash = $jc(_$hash, min.hashCode);
    _$hash = $jc(_$hash, q1.hashCode);
    _$hash = $jc(_$hash, median.hashCode);
    _$hash = $jc(_$hash, q3.hashCode);
    _$hash = $jc(_$hash, max.hashCode);
    _$hash = $jc(_$hash, medianAbsDeviation.hashCode);
    _$hash = $jc(_$hash, robustCv.hashCode);
    _$hash = $jc(_$hash, confidence95lower.hashCode);
    _$hash = $jc(_$hash, confidence95upper.hashCode);
    _$hash = $jc(_$hash, ciWidth.hashCode);
    _$hash = $jc(_$hash, ciWidthPercent.hashCode);
    _$hash = $jc(_$hash, residuals.hashCode);
    _$hash = $jc(_$hash, maxAbsError.hashCode);
    _$hash = $jc(_$hash, maxAbsErrorPercent.hashCode);
    _$hash = $jc(_$hash, rootMeanSquareError.hashCode);
    _$hash = $jc(_$hash, rmsePercent.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Result')
          ..add('start', start)
          ..add('tapCount', tapCount)
          ..add('sampleSize', sampleSize)
          ..add('taps', taps)
          ..add('samples', samples)
          ..add('min', min)
          ..add('q1', q1)
          ..add('median', median)
          ..add('q3', q3)
          ..add('max', max)
          ..add('medianAbsDeviation', medianAbsDeviation)
          ..add('robustCv', robustCv)
          ..add('confidence95lower', confidence95lower)
          ..add('confidence95upper', confidence95upper)
          ..add('ciWidth', ciWidth)
          ..add('ciWidthPercent', ciWidthPercent)
          ..add('residuals', residuals)
          ..add('maxAbsError', maxAbsError)
          ..add('maxAbsErrorPercent', maxAbsErrorPercent)
          ..add('rootMeanSquareError', rootMeanSquareError)
          ..add('rmsePercent', rmsePercent))
        .toString();
  }
}

class ResultBuilder implements Builder<Result, ResultBuilder> {
  _$Result? _$v;

  DateTime? _start;
  DateTime? get start => _$this._start;
  set start(DateTime? start) => _$this._start = start;

  int? _tapCount;
  int? get tapCount => _$this._tapCount;
  set tapCount(int? tapCount) => _$this._tapCount = tapCount;

  int? _sampleSize;
  int? get sampleSize => _$this._sampleSize;
  set sampleSize(int? sampleSize) => _$this._sampleSize = sampleSize;

  ListBuilder<int>? _taps;
  ListBuilder<int> get taps => _$this._taps ??= ListBuilder<int>();
  set taps(ListBuilder<int>? taps) => _$this._taps = taps;

  ListBuilder<Sample>? _samples;
  ListBuilder<Sample> get samples => _$this._samples ??= ListBuilder<Sample>();
  set samples(ListBuilder<Sample>? samples) => _$this._samples = samples;

  Sample? _min;
  Sample? get min => _$this._min;
  set min(Sample? min) => _$this._min = min;

  Sample? _q1;
  Sample? get q1 => _$this._q1;
  set q1(Sample? q1) => _$this._q1 = q1;

  Sample? _median;
  Sample? get median => _$this._median;
  set median(Sample? median) => _$this._median = median;

  Sample? _q3;
  Sample? get q3 => _$this._q3;
  set q3(Sample? q3) => _$this._q3 = q3;

  Sample? _max;
  Sample? get max => _$this._max;
  set max(Sample? max) => _$this._max = max;

  double? _medianAbsDeviation;
  double? get medianAbsDeviation => _$this._medianAbsDeviation;
  set medianAbsDeviation(double? medianAbsDeviation) =>
      _$this._medianAbsDeviation = medianAbsDeviation;

  double? _robustCv;
  double? get robustCv => _$this._robustCv;
  set robustCv(double? robustCv) => _$this._robustCv = robustCv;

  Sample? _confidence95lower;
  Sample? get confidence95lower => _$this._confidence95lower;
  set confidence95lower(Sample? confidence95lower) =>
      _$this._confidence95lower = confidence95lower;

  Sample? _confidence95upper;
  Sample? get confidence95upper => _$this._confidence95upper;
  set confidence95upper(Sample? confidence95upper) =>
      _$this._confidence95upper = confidence95upper;

  double? _ciWidth;
  double? get ciWidth => _$this._ciWidth;
  set ciWidth(double? ciWidth) => _$this._ciWidth = ciWidth;

  double? _ciWidthPercent;
  double? get ciWidthPercent => _$this._ciWidthPercent;
  set ciWidthPercent(double? ciWidthPercent) =>
      _$this._ciWidthPercent = ciWidthPercent;

  ListBuilder<double>? _residuals;
  ListBuilder<double> get residuals =>
      _$this._residuals ??= ListBuilder<double>();
  set residuals(ListBuilder<double>? residuals) =>
      _$this._residuals = residuals;

  double? _maxAbsError;
  double? get maxAbsError => _$this._maxAbsError;
  set maxAbsError(double? maxAbsError) => _$this._maxAbsError = maxAbsError;

  double? _maxAbsErrorPercent;
  double? get maxAbsErrorPercent => _$this._maxAbsErrorPercent;
  set maxAbsErrorPercent(double? maxAbsErrorPercent) =>
      _$this._maxAbsErrorPercent = maxAbsErrorPercent;

  double? _rootMeanSquareError;
  double? get rootMeanSquareError => _$this._rootMeanSquareError;
  set rootMeanSquareError(double? rootMeanSquareError) =>
      _$this._rootMeanSquareError = rootMeanSquareError;

  double? _rmsePercent;
  double? get rmsePercent => _$this._rmsePercent;
  set rmsePercent(double? rmsePercent) => _$this._rmsePercent = rmsePercent;

  ResultBuilder();

  ResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _start = $v.start;
      _tapCount = $v.tapCount;
      _sampleSize = $v.sampleSize;
      _taps = $v.taps.toBuilder();
      _samples = $v.samples.toBuilder();
      _min = $v.min;
      _q1 = $v.q1;
      _median = $v.median;
      _q3 = $v.q3;
      _max = $v.max;
      _medianAbsDeviation = $v.medianAbsDeviation;
      _robustCv = $v.robustCv;
      _confidence95lower = $v.confidence95lower;
      _confidence95upper = $v.confidence95upper;
      _ciWidth = $v.ciWidth;
      _ciWidthPercent = $v.ciWidthPercent;
      _residuals = $v.residuals.toBuilder();
      _maxAbsError = $v.maxAbsError;
      _maxAbsErrorPercent = $v.maxAbsErrorPercent;
      _rootMeanSquareError = $v.rootMeanSquareError;
      _rmsePercent = $v.rmsePercent;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Result other) {
    _$v = other as _$Result;
  }

  @override
  void update(void Function(ResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Result build() => _build();

  _$Result _build() {
    _$Result _$result;
    try {
      _$result =
          _$v ??
          _$Result._(
            start: BuiltValueNullFieldError.checkNotNull(
              start,
              r'Result',
              'start',
            ),
            tapCount: BuiltValueNullFieldError.checkNotNull(
              tapCount,
              r'Result',
              'tapCount',
            ),
            sampleSize: BuiltValueNullFieldError.checkNotNull(
              sampleSize,
              r'Result',
              'sampleSize',
            ),
            taps: taps.build(),
            samples: samples.build(),
            min: BuiltValueNullFieldError.checkNotNull(min, r'Result', 'min'),
            q1: BuiltValueNullFieldError.checkNotNull(q1, r'Result', 'q1'),
            median: BuiltValueNullFieldError.checkNotNull(
              median,
              r'Result',
              'median',
            ),
            q3: BuiltValueNullFieldError.checkNotNull(q3, r'Result', 'q3'),
            max: BuiltValueNullFieldError.checkNotNull(max, r'Result', 'max'),
            medianAbsDeviation: BuiltValueNullFieldError.checkNotNull(
              medianAbsDeviation,
              r'Result',
              'medianAbsDeviation',
            ),
            robustCv: BuiltValueNullFieldError.checkNotNull(
              robustCv,
              r'Result',
              'robustCv',
            ),
            confidence95lower: confidence95lower,
            confidence95upper: confidence95upper,
            ciWidth: ciWidth,
            ciWidthPercent: ciWidthPercent,
            residuals: residuals.build(),
            maxAbsError: BuiltValueNullFieldError.checkNotNull(
              maxAbsError,
              r'Result',
              'maxAbsError',
            ),
            maxAbsErrorPercent: BuiltValueNullFieldError.checkNotNull(
              maxAbsErrorPercent,
              r'Result',
              'maxAbsErrorPercent',
            ),
            rootMeanSquareError: BuiltValueNullFieldError.checkNotNull(
              rootMeanSquareError,
              r'Result',
              'rootMeanSquareError',
            ),
            rmsePercent: BuiltValueNullFieldError.checkNotNull(
              rmsePercent,
              r'Result',
              'rmsePercent',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taps';
        taps.build();
        _$failedField = 'samples';
        samples.build();

        _$failedField = 'residuals';
        residuals.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'Result',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
