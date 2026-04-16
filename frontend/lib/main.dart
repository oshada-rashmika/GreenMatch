import 'package:flutter/material.dart';
import 'screens/student_dashboard.dart';
import 'screens/supervisor_dashboard.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'services/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'GreenMatch',
        // Phase 3: Brand Cleanup - Hide Debug Banner
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Default to dark for the premium experience
        home: const StudentDashboardScreen(),
      ),
    );
  }
}
