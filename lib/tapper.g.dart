// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tapper.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Result extends Result {
  @override
  final DateTime start;
  @override
  final BuiltList<int> taps;
  @override
  final BuiltList<Sample> samples;
  @override
  final Sample median;
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
    required this.taps,
    required this.samples,
    required this.median,
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
        taps == other.taps &&
        samples == other.samples &&
        median == other.median &&
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
    _$hash = $jc(_$hash, taps.hashCode);
    _$hash = $jc(_$hash, samples.hashCode);
    _$hash = $jc(_$hash, median.hashCode);
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
          ..add('taps', taps)
          ..add('samples', samples)
          ..add('median', median)
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

  ListBuilder<int>? _taps;
  ListBuilder<int> get taps => _$this._taps ??= ListBuilder<int>();
  set taps(ListBuilder<int>? taps) => _$this._taps = taps;

  ListBuilder<Sample>? _samples;
  ListBuilder<Sample> get samples => _$this._samples ??= ListBuilder<Sample>();
  set samples(ListBuilder<Sample>? samples) => _$this._samples = samples;

  Sample? _median;
  Sample? get median => _$this._median;
  set median(Sample? median) => _$this._median = median;

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
      _taps = $v.taps.toBuilder();
      _samples = $v.samples.toBuilder();
      _median = $v.median;
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
            taps: taps.build(),
            samples: samples.build(),
            median: BuiltValueNullFieldError.checkNotNull(
              median,
              r'Result',
              'median',
            ),
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
