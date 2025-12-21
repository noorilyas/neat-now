import 'package:flutter/material.dart';
import 'package:neat_now/screens/splash_screen.dart';
import 'package:neat_now/screens/login_screen.dart';
import 'package:neat_now/views/user/user_dashboard_view.dart';
import '../../design/user/user_design_system.dart';
import 'package:neat_now/screens/employee_dashboard.dart';
import 'package:neat_now/screens/camera_screen.dart';

void main() {
  runApp(const NeatNowApp());
}

class NeatNowApp extends StatelessWidget {
  const NeatNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeatNow - Waste Management',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
      //  '/user_dashboard': (context) => const UserDashboard(onLogout: () ),
        '/employee_dashboard': (context) => const EmployeeDashboard(),
        '/camera': (context) => const CameraScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}