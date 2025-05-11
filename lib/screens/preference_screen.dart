// lib/screens/preferences_screen.dart
import 'package:bricorasy/theme/theme_provider.dart'; // Adjust import path if needed
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Préférences'),
        // You can style the AppBar based on the current theme
        // backgroundColor: Theme.of(context).colorScheme.surface, (Material 3 style)
        // elevation: Theme.of(context).appBarTheme.elevation ?? 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          SwitchListTile(
            title: const Text('Mode Sombre'),
            subtitle: Text(themeProvider.isDarkMode ? 'Activé' : 'Désactivé'),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              themeProvider.toggleTheme(value);
            },
            // Use icons that make sense for the theme
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: Theme.of(context).colorScheme.primary, // Or any color you prefer
            ),
            activeColor: Theme.of(context).colorScheme.primary, // Color of the switch when on
          ),
          // You can add more preferences here in the future
          // For example:
          // ListTile(
          //   leading: Icon(Icons.language),
          //   title: Text('Langue'),
          //   trailing: Icon(Icons.arrow_forward_ios, size: 18),
          //   onTap: () {
          //     // Navigate to language selection screen
          //   },
          // ),
        ],
      ),
    );
  }
}