import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkTheme;
  final ValueChanged<bool> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkTheme,
    required this.onThemeChanged,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkTheme;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _isDarkTheme = widget.isDarkTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Tema escuro"),
            trailing: Switch(
              value: _isDarkTheme,
              onChanged: (value) {
                setState(() {
                  _isDarkTheme = value;
                });
                widget.onThemeChanged(value);
              },
            ),
          ),
          ListTile(
            title: const Text("Notificações"),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text("Sobre o app"),
            trailing: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Remember Me",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(Icons.lock),
                children: const [
                  Text(
                    "Este é um aplicativo para ajudar na organização de tarefas.",
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
