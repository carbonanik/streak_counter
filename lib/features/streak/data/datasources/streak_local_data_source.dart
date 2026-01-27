import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import '../../domain/models/streak.dart';

class StreakLocalDataSource {
  static const String _countKey = 'streak_count';
  static const String _lastDateKey = 'last_date';
  static const String _taskRegisteredKey = 'task_registered';
  static const String _titleKey = 'widget_title';
  static const String _androidWidgetName = 'StreakWidgetProvider';

  Future<Streak> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_countKey) ?? 0;
    final title = prefs.getString(_titleKey) ?? "STREAK";
    final dateString = prefs.getString(_lastDateKey);
    DateTime? lastDate;
    if (dateString != null) {
      lastDate = DateTime.tryParse(dateString);
    }
    return Streak(count: count, lastDate: lastDate, title: title);
  }

  Future<void> saveStreak(Streak streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, streak.count);
    await prefs.setString(_titleKey, streak.title);
    if (streak.lastDate != null) {
      await prefs.setString(_lastDateKey, streak.lastDate!.toIso8601String());
    }
  }

  Future<void> updateWidget(Streak streak) async {
    try {
      String state;
      if (streak.count == 0) {
        state = 'zero';
      } else if (streak.canTickToday) {
        state = 'active';
      } else {
        state = 'completed';
      }

      await HomeWidget.saveWidgetData<int>('streak_count', streak.count);
      await HomeWidget.saveWidgetData<String>('streak_state', state);
      await HomeWidget.saveWidgetData<String>('widget_title', streak.title);
      await HomeWidget.updateWidget(name: _androidWidgetName);
    } catch (e) {
      // Log error (should ideally use a logger)
    }
  }

  Future<bool> isTaskRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_taskRegisteredKey) ?? false;
  }

  Future<void> setTaskRegistered(bool registered) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_taskRegisteredKey, registered);
  }
}
