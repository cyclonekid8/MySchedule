import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/schedule_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialize notifications
  await NotificationService().init();

  final provider = ScheduleProvider();
  await provider.load();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const MyScheduleApp(),
    ),
  );
}

class MyScheduleApp extends StatelessWidget {
  const MyScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySchedule',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
