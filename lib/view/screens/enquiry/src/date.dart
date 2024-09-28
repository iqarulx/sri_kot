extension DateTimeComparison on DateTime {
  bool isAtLeast(DateTime other) {
    return isAfter(other) || isAtSameMomentAs(other);
  }

  bool isAtMost(DateTime other) {
    return isBefore(other) || isAtSameMomentAs(other);
  }
}
