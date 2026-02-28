import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/schedule_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  debugPrint('🚀 App starting...');
  try {
    debugPrint('🔔 Initializing notifications...');
    await NotificationService().init().timeout(
      const Duration(seconds: 5),
      onTimeout: () => debugPrint('⚠️ Notification init timed out'),
    );
    debugPrint('✅ Notifications initialized');
  } catch (e) { debugPrint('❌ Notification error: $e'); }
  final purchaseService = PurchaseService();
  debugPrint('💰 Initializing purchase service...');
  try { await purchaseService.init(); } catch (e) { debugPrint('❌ Purchase error: $e'); }
  debugPrint('✅ Purchase service initialized');
  final scheduleProvider = ScheduleProvider();
  debugPrint('📅 Loading schedule...');
  try { await scheduleProvider.load(); } catch (e) { debugPrint('❌ Schedule error: $e'); }
  debugPrint('✅ Schedule loaded');
  final themeProvider = ThemeProvider();
  debugPrint('🎨 Initializing theme...');
  try { await themeProvider.init(); } catch (e) { debugPrint('❌ Theme error: $e'); }
  debugPrint('✅ Theme initialized');

  // Check if onboarding is complete
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  debugPrint('🏁 Running app...');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: scheduleProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: purchaseService),
      ],
      child: MyScheduleApp(showOnboarding: !onboardingComplete),
    ),
  );
}

class MyScheduleApp extends StatelessWidget {
  final bool showOnboarding;
  const MyScheduleApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'MySchedule',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6C63FF),
          surface: Color(0xFFF5F5F5),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7B73FF),
          surface: Color(0xFF16161E),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(color: Color(0xFFE0E0FF), fontWeight: FontWeight.w400),
          bodySmall: TextStyle(color: Color(0xFFBBBBCC)),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
