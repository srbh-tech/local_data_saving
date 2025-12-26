import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

import 'hive/hive_page.dart';
import 'hive/todo_model.dart';
import 'shared_pref/preferences_service.dart';
import 'shared_pref/settings_page.dart';
import 'sqflite/sqflite_page.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapter
  Hive.registerAdapter(TodoModelAdapter());

  // Open Hive Box
  await Hive.openBox<TodoModel>('todos');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PreferencesService>(create: (_) => PreferencesService()),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(
            Provider.of<PreferencesService>(context, listen: false),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Local Data Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.outfitTextTheme(),
              scaffoldBackgroundColor: const Color(0xFFF5F7FA),
              cardColor: Colors.white,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
              ),
              textTheme: GoogleFonts.outfitTextTheme(
                ThemeData.dark().textTheme,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
            ),
            themeMode: themeProvider.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [SharedPrefsTab(), HiveTab(), SqfliteTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Data Storage'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Shared Prefs',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Hive (NoSQL)',
          ),
          NavigationDestination(
            icon: Icon(Icons.storage_outlined),
            selectedIcon: Icon(Icons.storage),
            label: 'Sqflite (SQL)',
          ),
        ],
      ),
    );
  }
}

// Wrapper widgets to provide clean structure
class SharedPrefsTab extends StatelessWidget {
  const SharedPrefsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: SettingsPage());
  }
}

class HiveTab extends StatelessWidget {
  const HiveTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: HivePage());
  }
}

class SqfliteTab extends StatelessWidget {
  const SqfliteTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: SqflitePage());
  }
}
