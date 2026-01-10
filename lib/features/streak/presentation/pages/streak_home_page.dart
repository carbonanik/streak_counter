import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import '../providers/streak_provider.dart';

class StreakHomePage extends StatelessWidget {
  const StreakHomePage({super.key});

  static const String widgetUpdateTask = 'streak_widget_daily_update_task';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<StreakProvider>(
        builder: (context, streakProvider, child) {
          if (streakProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CURRENT STREAK',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onLongPress: () =>
                      _showEditStreakDialog(context, streakProvider),
                  child: Text(
                    '${streakProvider.count}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 120,
                      fontWeight: FontWeight.w900,
                      color: streakProvider.canTickToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
                Text(
                  'DAYS',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: 200,
                  height: 60,
                  child: FilledButton.icon(
                    onPressed: streakProvider.canTickToday
                        ? () => streakProvider.incrementStreak()
                        : null,
                    icon: Icon(
                      streakProvider.canTickToday
                          ? Icons.check
                          : Icons.check_circle,
                    ),
                    label: Text(
                      streakProvider.canTickToday
                          ? "TICK TODAY"
                          : "DONE FOR TODAY",
                    ),
                    style: FilledButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (!streakProvider.isTaskRegistered)
                  TextButton.icon(
                    onPressed: () async {
                      final now = DateTime.now();
                      final nextMidnight = DateTime(
                        now.year,
                        now.month,
                        now.day + 1,
                      );
                      final initialDelay = nextMidnight.difference(now);
                      await Workmanager().registerPeriodicTask(
                        widgetUpdateTask,
                        widgetUpdateTask,
                        initialDelay: initialDelay,
                        frequency: const Duration(days: 1),
                        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
                      );
                      await streakProvider.setTaskRegistered(true);
                    },
                    icon: const Icon(Icons.timer),
                    label: const Text("12 AM UPDATE"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditStreakDialog(
    BuildContext context,
    StreakProvider streakProvider,
  ) {
    final controller = TextEditingController(
      text: streakProvider.count.toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Streak'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New Streak Count'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final newCount = int.tryParse(controller.text);
              if (newCount != null) {
                streakProvider.setManualStreak(newCount);
              }
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
