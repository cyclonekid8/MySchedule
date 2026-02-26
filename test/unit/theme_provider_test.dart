import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschedule/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    late ThemeProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = ThemeProvider();
      await provider.init();
    });

    test('defaults to system theme mode', () {
      expect(provider.themeMode, ThemeMode.system);
    });

    test('toggleTheme switches to light mode', () async {
      await provider.toggleTheme(true);
      expect(provider.themeMode, ThemeMode.light);
    });

    test('toggleTheme switches back to dark mode', () async {
      await provider.toggleTheme(true);
      await provider.toggleTheme(false);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('theme preference persists after reinit', () async {
      await provider.toggleTheme(true);
      final provider2 = ThemeProvider();
      await provider2.init();
      expect(provider2.themeMode, ThemeMode.light);
    });
  });
}
