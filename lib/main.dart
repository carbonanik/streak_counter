import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'streak_service.dart';

// Schedule daily updates
void scheduleDailyWidgetUpdate() {
  try {
    Workmanager().registerPeriodicTask(
      "widget_update",
      "widgetBackgroundUpdate",
      frequency: const Duration(hours: 24),
      initialDelay: _calculateDelayUntilMidnight(),
      existingWorkPolicy: ExistingPeriodicWorkPolicy
          .keep, // Prevent resetting the delay on every app start
      constraints: Constraints(networkType: NetworkType.notRequired),
    );

    // Register a one-off task for immediate testing (fires in 5 seconds)
    Workmanager().registerOneOffTask(
      "test_immediate",
      "widgetBackgroundUpdate", // Use the same task name
      initialDelay: const Duration(seconds: 5),
    );

    debugPrint("Background tasks registered/checked.");
  } catch (e) {
    debugPrint("Failed to schedule background tasks: $e");
  }
}

Duration _calculateDelayUntilMidnight() {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  return tomorrow.difference(now);
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Ensure plugin services are available in the background isolate
    WidgetsFlutterBinding.ensureInitialized();

    print("Workmanager callback called for task: $task");
    try {
      final service = StreakService();
      await service.initializationDone;
      await service.updateWidget();
      print("Workmanager task '$task' completed successfully.");
    } catch (e) {
      print("Workmanager task '$task' failed: $e");
    }
    return Future.value(true);
  });
}

void main() async {
  debugPrint("Starting main()");
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Workmanager
  debugPrint("Initializing Workmanager...");
  try {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    debugPrint("Workmanager initialized.");
  } catch (e) {
    debugPrint("Workmanager initialization failed: $e");
  }

  scheduleDailyWidgetUpdate();
  debugPrint("Running app...");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StreakService(),
      child: MaterialApp(
        title: 'Streak Counter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const StreakHomePage(),
      ),
    );
  }
}

class StreakHomePage extends StatelessWidget {
  const StreakHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<StreakService>(
        builder: (context, streakService, child) {
          if (streakService.isLoading) {
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
                      _showEditStreakDialog(context, streakService),
                  child: Text(
                    '${streakService.count}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 120,
                      fontWeight: FontWeight.w900,
                      color: streakService.canTickToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                                .colorScheme
                                .tertiary, // Change color if already ticked
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
                    onPressed: streakService.canTickToday
                        ? () => streakService.incrementStreak()
                        : null,
                    icon: Icon(
                      streakService.canTickToday
                          ? Icons.check
                          : Icons.check_circle,
                    ),
                    label: Text(
                      streakService.canTickToday
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
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditStreakDialog(
    BuildContext context,
    StreakService streakService,
  ) {
    final controller = TextEditingController(
      text: streakService.count.toString(),
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
                streakService.setManualStreak(newCount);
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
