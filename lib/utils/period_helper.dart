class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);
}

class PeriodHelper {
  static DateRange currentWeek([DateTime? now]) {
    final n = now ?? DateTime.now();
    final startOfWeek = n.subtract(Duration(days: n.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));
    return DateRange(start, end);
  }

  static DateRange currentMonth([DateTime? now]) {
    final n = now ?? DateTime.now();
    final start = DateTime(n.year, n.month, 1);
    final end = DateTime(n.year, n.month + 1, 1);
    return DateRange(start, end);
  }

  static DateRange currentYear([DateTime? now]) {
    final n = now ?? DateTime.now();
    final start = DateTime(n.year, 1, 1);
    final end = DateTime(n.year + 1, 1, 1);
    return DateRange(start, end);
  }
}
