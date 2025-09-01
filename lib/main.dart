import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mafia_store/fetures/screens/authentication/login_page.dart';
import 'package:mafia_store/fetures/screens/authentication/register_page.dart';
import 'package:mafia_store/fetures/screens/home_page.dart';
import 'package:mafia_store/fetures/screens/onboarding_screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // تهيئة Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Overboard Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: '/register',
      routes: {
        '/onboarding': (context) => OnboardingPage(),
        '/home': (context) => HomePage(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
