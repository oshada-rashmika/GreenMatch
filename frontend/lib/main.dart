import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'services/auth_provider.dart';
import 'services/shortlist_provider.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShortlistProvider()),
      ],
      child: MaterialApp(
        title: 'GreenMatch',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.monochromeTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/admin': (context) => const LoginScreen(adminOnly: true),
        },
      ),
    );
  }
}
