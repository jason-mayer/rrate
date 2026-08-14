class Sample {
  final num count;

  const Sample(this.count);

  factory Sample.from(DateTime time) => Sample(time.millisecondsSinceEpoch);

  Sample operator +(Sample other) {
    return Sample(count + other.count);
  }

  Sample operator -(Sample other) {
    return Sample(count - other.count);
  }

  Sample operator *(num other) {
    return Sample(count * other);
  }

  Sample operator /(num other) {
    return Sample(count / other);
  }

  bool operator >(Sample other) {
    return count > other.count;
  }

  bool operator <(Sample other) {
    return count < other.count;
  }

  double get asBpm => 60_000 / count;

  @override
  String toString() {
    return '${count.toStringAsFixed(0)}ms (${asBpm.toStringAsFixed(1)} bpm)';
  }
}

class DistanceSample extends Sample {
  final int distance;

  const DistanceSample(super.count, this.distance);

  @override
  String toString() {
    return '${count.toStringAsFixed(0)}ms (${asBpm.toStringAsFixed(1)} bpm) '
        'dist=$distance';
  }
}
