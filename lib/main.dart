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

  await NotificationService().init();

  final scheduleProvider = ScheduleProvider();
  await scheduleProvider.load();

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  final purchaseService = PurchaseService();
  await purchaseService.init();

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
        scaffoldBackgroundColor: const Color(0xFF0F0F13),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          surface: Color(0xFF18181F),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
