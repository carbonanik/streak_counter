import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/streak.dart';
import '../../domain/repositories/streak_repository.dart';

class StreakProvider extends ChangeNotifier {
  final StreakRepository _repository;

  Streak _streak = Streak(count: 0);
  bool _isLoading = true;
  bool _isTaskRegistered = false;

  StreakProvider(this._repository) {
    _loadData();
  }

  Streak get streak => _streak;
  int get count => _streak.count;
  bool get isLoading => _isLoading;
  bool get isTaskRegistered => _isTaskRegistered;
  bool get canTickToday => _streak.canTickToday;

  final Completer<void> _loadCompleter = Completer<void>();
  Future<void> get initializationDone => _loadCompleter.future;

  Future<void> _loadData() async {
    try {
      _streak = await _repository.getStreak();
      _isTaskRegistered = await _repository.isTaskRegistered();
      await _checkStreakValidity();
    } catch (e) {
      debugPrint("Error loading streak data: $e");
    } finally {
      _isLoading = false;
      if (!_loadCompleter.isCompleted) {
        _loadCompleter.complete();
      }
      notifyListeners();
    }
  }

  Future<void> _checkStreakValidity() async {
    if (_streak.lastDate == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      _streak.lastDate!.year,
      _streak.lastDate!.month,
      _streak.lastDate!.day,
    );

    final difference = today.difference(last).inDays;

    if (difference > 1) {
      _streak = _streak.copyWith(count: 0);
      await _repository.saveStreak(_streak);
      await _repository.updateWidget(_streak);
    }
  }

  Future<void> incrementStreak() async {
    if (!canTickToday) return;

    _streak = _streak.copyWith(
      count: _streak.count + 1,
      lastDate: DateTime.now(),
    );

    notifyListeners();
    await _repository.saveStreak(_streak);
    await _repository.updateWidget(_streak);
  }

  Future<void> setManualStreak(int newCount) async {
    _streak = _streak.copyWith(count: newCount);
    notifyListeners();
    await _repository.saveStreak(_streak);
    await _repository.updateWidget(_streak);
  }

  Future<void> setTaskRegistered(bool registered) async {
    _isTaskRegistered = registered;
    await _repository.setTaskRegistered(registered);
    notifyListeners();
  }

  Future<void> refreshWidget() async {
    await _repository.updateWidget(_streak);
  }
}
