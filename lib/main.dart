import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'streak_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
                Text(
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
}
