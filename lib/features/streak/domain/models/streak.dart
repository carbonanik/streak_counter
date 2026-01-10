class Streak {
  final int count;
  final DateTime? lastDate;

  Streak({required this.count, this.lastDate});

  bool get canTickToday {
    if (lastDate == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(lastDate!.year, lastDate!.month, lastDate!.day);
    return today.isAfter(last);
  }

  Streak copyWith({int? count, DateTime? lastDate}) {
    return Streak(
      count: count ?? this.count,
      lastDate: lastDate ?? this.lastDate,
    );
  }
}
