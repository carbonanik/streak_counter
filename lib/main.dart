import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'core/constants.dart';
import 'features/streak/data/datasources/streak_local_data_source.dart';
import 'features/streak/data/repositories/streak_repository_impl.dart';
import 'features/streak/domain/repositories/streak_repository.dart';
import 'features/streak/presentation/pages/streak_home_page.dart';
import 'features/streak/presentation/providers/streak_provider.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("WorkManager executing task: $task");

    if (task == AppConstants.widgetUpdateTask) {
      final dataSource = StreakLocalDataSource();
      final streak = await dataSource.getStreak();
      await dataSource.updateWidget(streak);
    }

    return Future.value(true);
  });
}

Future<void> main() async {
  debugPrint("Starting main()");
  WidgetsFlutterBinding.ensureInitialized();

  await Workmanager().initialize(callbackDispatcher);

  // Initialize data source and repo for bootstrap check
  final dataSource = StreakLocalDataSource();
  final repository = StreakRepositoryImpl(localDataSource: dataSource);

  // Check if day changed since last update
  final prefs = await SharedPreferences.getInstance();
  final lastUpdateString = prefs.getString(AppConstants.lastAppStartCheckKey);
  final lastUpdate = lastUpdateString != null
      ? DateTime.tryParse(lastUpdateString)
      : null;
  final today = DateTime.now();

  if (lastUpdate == null || !_isSameDay(lastUpdate, today)) {
    final streak = await repository.getStreak();
    await repository.updateWidget(streak);
    await prefs.setString(
      AppConstants.lastAppStartCheckKey,
      today.toIso8601String(),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<StreakLocalDataSource>(create: (_) => dataSource),
        Provider<StreakRepository>(
          create: (context) => StreakRepositoryImpl(
            localDataSource: Provider.of<StreakLocalDataSource>(
              context,
              listen: false,
            ),
          ),
        ),
        ChangeNotifierProvider<StreakProvider>(
          create: (context) => StreakProvider(
            Provider.of<StreakRepository>(context, listen: false),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streak Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const StreakHomePage(),
    );
  }
}
