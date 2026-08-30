import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/core/provider/shared_preferences_provider.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  final String _key = 'theme_mode';

  @override
  ThemeMode build() {
    _loadSavedTheme();
    return ThemeMode.system;
  }

  Future<void> _loadSavedTheme() async {
    final preferences = ref.watch(sharedPreferencesProvider);
    final saved = preferences.getString(_key);
    if (saved == 'light') {
      state = ThemeMode.light;
    } else if (saved == 'dark') {
      state = ThemeMode.dark;
    }
  }

  Future<void> toggleTheme() async {
    ThemeMode newTheme;
    switch (state) {
      case ThemeMode.system:
        newTheme = ThemeMode.light;
        break;
      case ThemeMode.light:
        newTheme = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newTheme = ThemeMode.system;
        break;
    }
    state = newTheme;
    final preferences = ref.watch(sharedPreferencesProvider);
    await preferences.setString(
      _key,
      newTheme == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
