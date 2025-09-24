import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SwitchListTile(
          title: const Text('Dark Mode'),
          value: themeNotifier.isDarkMode,
          onChanged: (bool value) {
            themeNotifier.toggleTheme(value);
          },
          activeColor: const Color(0xFF688BFF),
        ),
      ),
    );
  }
}
