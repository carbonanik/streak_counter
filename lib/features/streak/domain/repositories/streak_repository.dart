import '../models/streak.dart';

abstract class StreakRepository {
  Future<Streak> getStreak();
  Future<void> saveStreak(Streak streak);
  Future<void> updateWidget(Streak streak);
  Future<bool> isTaskRegistered();
  Future<void> setTaskRegistered(bool registered);
}
