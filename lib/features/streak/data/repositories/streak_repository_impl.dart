import '../../domain/models/streak.dart';
import '../../domain/repositories/streak_repository.dart';
import '../datasources/streak_local_data_source.dart';

class StreakRepositoryImpl implements StreakRepository {
  final StreakLocalDataSource localDataSource;

  StreakRepositoryImpl({required this.localDataSource});

  @override
  Future<Streak> getStreak() => localDataSource.getStreak();

  @override
  Future<void> saveStreak(Streak streak) => localDataSource.saveStreak(streak);

  @override
  Future<void> updateWidget(Streak streak) =>
      localDataSource.updateWidget(streak);

  @override
  Future<bool> isTaskRegistered() => localDataSource.isTaskRegistered();

  @override
  Future<void> setTaskRegistered(bool registered) =>
      localDataSource.setTaskRegistered(registered);
}
