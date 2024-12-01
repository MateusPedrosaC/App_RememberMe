import 'services/notification_service.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_edit_task_screen.dart';
import 'screens/settings_screen.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

// Tornar a classe pública
class MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(
              isDarkMode: _isDarkMode,
              onToggleTheme: _toggleTheme,
            ),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => HomeScreen(
              isDarkMode: _isDarkMode,
              onToggleTheme: _toggleTheme,
            ),
        '/add_edit_task': (context) => AddEditTaskScreen(
              isDarkMode: _isDarkMode,
            ),
        '/settings': (context) => SettingsScreen(
              isDarkTheme: _isDarkMode,
              onThemeChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
      },
    );
  }
}
