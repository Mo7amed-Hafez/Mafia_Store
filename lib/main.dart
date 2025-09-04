import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mafia_store/core/app_state.dart';
import 'package:mafia_store/fetures/screens/authentication/login_page.dart';
import 'package:mafia_store/fetures/screens/authentication/register_page.dart';
import 'package:mafia_store/fetures/screens/home/home_page.dart';
import 'package:mafia_store/fetures/screens/info/profile_page.dart';
import 'package:mafia_store/fetures/screens/info/settings_page.dart';
import 'package:mafia_store/fetures/screens/onboarding_screens.dart';
import 'package:mafia_store/fetures/screens/productes/cart_page.dart';
import 'package:mafia_store/fetures/screens/productes/productes_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // تهيئة Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Flutter Overboard Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepOrange,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/home',
          routes: {
            '/onboarding': (context) => OnboardingPage(),
            '/home': (context) => HomePage(),
            '/register': (context) => RegisterPage(),
            '/login': (context) => LoginPage(),
            '/profile': (context) => ProfilePage(),
            '/settings': (context) => SettingsPage(),
            '/cart': (context) => CartPage(),
            '/productes': (context) => ProductesPage(),
          },
        );
      },
    );
  }
}
