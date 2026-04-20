import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'services/auth_provider.dart';
import 'services/shortlist_provider.dart';
import 'screens/not_found_screen.dart';

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
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/admin':
              return MaterialPageRoute(builder: (_) => const LoginScreen(adminOnly: true));
            default:
              return MaterialPageRoute(builder: (_) => const NotFoundScreen());
          }
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
        ),
      ),
    );
  }
}
