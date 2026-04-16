import 'package:flutter/material.dart';
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
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'GreenMatch',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.monochromeTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
