import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'streak_service.dart';

Future<DateTime?> getLastUpdateDate() async {
  final prefs = await SharedPreferences.getInstance();
  final dateString = prefs.getString('last_app_start_check');
  if (dateString != null) {
    return DateTime.tryParse(dateString);
  }
  return null;
}

Future<void> saveLastUpdateDate(DateTime date) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_app_start_check', date.toIso8601String());
}

Future<void> updateWidget() async {
  // Use the service to reuse logic
  final service = StreakService();
  await service.initializationDone;
  await service.updateWidget();
}

bool isSameDay(DateTime? a, DateTime b) {
  if (a == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

void main() async {
  debugPrint("Starting main()");
  WidgetsFlutterBinding.ensureInitialized();

  // Check if day changed since last update
  final lastUpdate = await getLastUpdateDate();
  final today = DateTime.now();

  if (lastUpdate == null || !isSameDay(lastUpdate, today)) {
    await updateWidget();
    await saveLastUpdateDate(today);
  }

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
