import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  try { await NotificationService().init(); } catch (e) { debugPrint('$e'); }

  final purchaseService = PurchaseService();
  try { await purchaseService.init(); } catch (e) { debugPrint('$e'); }

  final scheduleProvider = ScheduleProvider();
  try { await scheduleProvider.load(); } catch (e) { debugPrint('$e'); }

  final themeProvider = ThemeProvider();
  try { await themeProvider.init(); } catch (e) { debugPrint('$e'); }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: scheduleProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: purchaseService),
      ],
      child: const MyScheduleApp(),
    ),
  );
}

class MyScheduleApp extends StatelessWidget {
  const MyScheduleApp({super.key});

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
      home: const HomeScreen(),
    );
  }
}
