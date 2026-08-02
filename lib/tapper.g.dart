// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tapper.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Estimate extends Estimate {
  @override
  final int index;
  @override
  final Sample duration;
  @override
  final Sample runningAverage;
  @override
  final double? stability;

  factory _$Estimate([void Function(EstimateBuilder)? updates]) =>
      (EstimateBuilder()..update(updates))._build();

  _$Estimate._({
    required this.index,
    required this.duration,
    required this.runningAverage,
    this.stability,
  }) : super._();
  @override
  Estimate rebuild(void Function(EstimateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EstimateBuilder toBuilder() => EstimateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Estimate &&
        index == other.index &&
        duration == other.duration &&
        runningAverage == other.runningAverage &&
        stability == other.stability;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, index.hashCode);
    _$hash = $jc(_$hash, duration.hashCode);
    _$hash = $jc(_$hash, runningAverage.hashCode);
    _$hash = $jc(_$hash, stability.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Estimate')
          ..add('index', index)
          ..add('duration', duration)
          ..add('runningAverage', runningAverage)
          ..add('stability', stability))
        .toString();
  }
}

class EstimateBuilder implements Builder<Estimate, EstimateBuilder> {
  _$Estimate? _$v;

  int? _index;
  int? get index => _$this._index;
  set index(int? index) => _$this._index = index;

  Sample? _duration;
  Sample? get duration => _$this._duration;
  set duration(Sample? duration) => _$this._duration = duration;

  Sample? _runningAverage;
  Sample? get runningAverage => _$this._runningAverage;
  set runningAverage(Sample? runningAverage) =>
      _$this._runningAverage = runningAverage;

  double? _stability;
  double? get stability => _$this._stability;
  set stability(double? stability) => _$this._stability = stability;

  EstimateBuilder();

  EstimateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _index = $v.index;
      _duration = $v.duration;
      _runningAverage = $v.runningAverage;
      _stability = $v.stability;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Estimate other) {
    _$v = other as _$Estimate;
  }

  @override
  void update(void Function(EstimateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Estimate build() => _build();

  _$Estimate _build() {
    final _$result =
        _$v ??
        _$Estimate._(
          index: BuiltValueNullFieldError.checkNotNull(
            index,
            r'Estimate',
            'index',
          ),
          duration: BuiltValueNullFieldError.checkNotNull(
            duration,
            r'Estimate',
            'duration',
          ),
          runningAverage: BuiltValueNullFieldError.checkNotNull(
            runningAverage,
            r'Estimate',
            'runningAverage',
          ),
          stability: stability,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
