import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_attendance_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..mountLocalStorage(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Absensi',
      theme: ThemeData(fontFamily: 'Poppins'),
      initialRoute: '/',
      routes: {
        '/': (context) => AnimatedLoginScreen(),
        '/otp': (context) => OTPScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/addAttendance': (context) => AddAttendanceScreen(),
      },
    );
  }
}
