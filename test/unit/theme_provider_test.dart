import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschedule/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ThemeProvider', () {
    late ThemeProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = ThemeProvider();
      await provider.init();
    });

    test('defaults to dark mode', () {
      expect(provider.isDark, true);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('toggle switches to light mode', () async {
      await provider.toggle();
      expect(provider.isDark, false);
      expect(provider.themeMode, ThemeMode.light);
    });

    test('toggle switches back to dark mode', () async {
      await provider.toggle();
      await provider.toggle();
      expect(provider.isDark, true);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('theme preference persists after reinit', () async {
      await provider.toggle(); // switch to light
      final provider2 = ThemeProvider();
      await provider2.init();
      expect(provider2.isDark, false);
      expect(provider2.themeMode, ThemeMode.light);
    });
  });
}
