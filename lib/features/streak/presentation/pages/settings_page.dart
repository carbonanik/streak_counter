import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/streak_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<StreakProvider>();
    _titleController = TextEditingController(text: provider.streak.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<StreakProvider>(
        builder: (context, streakProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionHeader(context, "WIDGET SETTINGS"),
              const SizedBox(height: 10),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Widget Title',
                  hintText: 'Enter title (e.g. VISUAL, GYM)',
                  border: OutlineInputBorder(),
                  helperText:
                      'This will be displayed on your home screen widget.',
                ),
                onChanged: (value) {
                  // Optional: Debounce or save on button press.
                  // For now, let's add a save button or save on submit.
                },
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    streakProvider.updateWidgetTitle(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Widget title updated!')),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty) {
                      streakProvider.updateWidgetTitle(
                        _titleController.text.trim().toUpperCase(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Widget title updated!')),
                      );
                    }
                  },
                  child: const Text("UPDATE TITLE"),
                ),
              ),
              const SizedBox(height: 40),
              _buildSectionHeader(context, "DATA"),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Edit Streak Count'),
                subtitle: const Text('Manually adjust your current streak'),
                trailing: const Icon(Icons.lock, color: Colors.grey),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'This feature is available in the Pro version.',
                      ),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
