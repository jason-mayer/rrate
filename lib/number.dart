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

  double get asBpm => 60_000 / count;

  @override
  String toString() {
    return '${count.toStringAsFixed(0)}ms (${asBpm.toStringAsFixed(1)} bpm)';
  }
}
