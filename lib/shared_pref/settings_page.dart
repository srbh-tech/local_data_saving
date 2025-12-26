import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'preferences_service.dart';
import '../theme_provider.dart';
import '../widgets/custom_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _usernameController = TextEditingController();
  late PreferencesService _prefsService;

  @override
  void initState() {
    super.initState();
    _prefsService = Provider.of<PreferencesService>(context, listen: false);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final username = await _prefsService.getUsername();
    setState(() {
      _usernameController.text = username ?? '';
    });
  }

  Future<void> _saveUsername() async {
    await _prefsService.saveUsername(_usernameController.text);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Username saved!')));
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.toggleTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the theme provider to update the switch state
    final isDarkMode =
        context.watch<ThemeProvider>().themeMode == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shared Preferences Demo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Used for storing simple key-value pairs like settings or flags.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          CustomCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Persist theme preference'),
                  value: isDarkMode,
                  onChanged: _toggleDarkMode,
                ),
                const Divider(),
                ListTile(
                  title: const Text('Username'),
                  subtitle: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter username',
                      border: InputBorder.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _saveUsername,
                    tooltip: 'Save Username',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
