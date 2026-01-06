import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';

class StreakService extends ChangeNotifier {
  static const String _countKey = 'streak_count';
  static const String _lastDateKey = 'last_date';

  static const String _androidWidgetName = 'StreakWidgetProvider';

  int _count = 0;
  DateTime? _lastDate;
  bool _isLoading = true;

  int get count => _count;
  bool get isLoading => _isLoading;

  final Completer<void> _loadCompleter = Completer<void>();
  Future<void> get initializationDone => _loadCompleter.future;

  StreakService() {
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    debugPrint("Loading streak...");
    try {
      final prefs = await SharedPreferences.getInstance();
      _count = prefs.getInt(_countKey) ?? 0;
      final dateString = prefs.getString(_lastDateKey);
      if (dateString != null) {
        _lastDate = DateTime.parse(dateString);
      }
      debugPrint("Streak data loaded: count=$_count, lastDate=$_lastDate");

      await _checkStreakValidity();
      debugPrint("Streak validity checked.");
    } catch (e) {
      debugPrint("Error loading streak: $e");
    } finally {
      _isLoading = false;
      if (!_loadCompleter.isCompleted) {
        _loadCompleter.complete();
      }
      notifyListeners();
      debugPrint("Streak loading complete.");
    }
  }

  Future<void> _checkStreakValidity() async {
    if (_lastDate == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(_lastDate!.year, _lastDate!.month, _lastDate!.day);

    final difference = today.difference(last).inDays;

    if (difference > 1) {
      // Missed a day, reset streak
      _count = 0;
      await _saveStreak();
      await updateWidget();
    }
  }

  bool get canTickToday {
    if (_lastDate == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(_lastDate!.year, _lastDate!.month, _lastDate!.day);
    return today.isAfter(last);
  }

  Future<void> incrementStreak() async {
    if (!canTickToday) return;

    _count++;
    _lastDate = DateTime.now();

    // Notify listeners immediately to update the app UI
    notifyListeners();

    await _saveStreak();
    await updateWidget();
  }

  Future<void> setManualStreak(int newCount) async {
    _count = newCount;
    // We don't change _lastDate here so the user can still tick today
    // if they haven't already, or vice-versa.

    notifyListeners();
    await _saveStreak();
    await updateWidget();
  }

  Future<void> _saveStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, _count);
    if (_lastDate != null) {
      await prefs.setString(_lastDateKey, _lastDate!.toIso8601String());
    }
  }

  Future<void> updateWidget() async {
    try {
      String state;
      if (_count == 0) {
        state = 'zero';
      } else if (canTickToday) {
        state = 'active';
      } else {
        state = 'completed';
      }

      await HomeWidget.saveWidgetData<int>('streak_count', _count);
      await HomeWidget.saveWidgetData<String>('streak_state', state);
      await HomeWidget.updateWidget(name: _androidWidgetName);
    } catch (e) {
      debugPrint("Error updating widget: $e");
    }
  }
}
