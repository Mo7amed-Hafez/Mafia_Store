import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mafia_store/core/auth_service.dart';
import 'package:mafia_store/fetures/screens/splach/splach_page.dart';
import 'package:mafia_store/fetures/screens/splach/onboarding_screens.dart';
import 'package:mafia_store/fetures/screens/authentication/login_page.dart';
import 'package:mafia_store/fetures/screens/home/home_page.dart';

class AppStateManager extends StatefulWidget {
  const AppStateManager({super.key});

  @override
  State<AppStateManager> createState() => _AppStateManagerState();
}

class _AppStateManagerState extends State<AppStateManager> {
  bool _isLoading = true;
  String _initialRoute = '/splash';

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    try {
      // انتظار قليل للتأكد من تهيئة Firebase
      await Future.delayed(const Duration(milliseconds: 500));

      // التحقق من حالة المصادقة
      final user = AuthService.currentUser;
      final isFirstTime = await AuthService.isFirstTimeUser();

      if (user != null) {
        // المستخدم مسجل الدخول
        final hasProfile = await AuthService.hasUserProfile();

        if (hasProfile) {
          // المستخدم مسجل قبل كدا ، انتقل للصفحة الرئيسية
          _initialRoute = '/home';
          // تحديث آخر تسجيل دخول
          await AuthService.updateLastLogin();
        } else {
          // المستخدم مسجل الدخول لكن طلع فا يسجل تاني
          _initialRoute = '/login'; 
        }
      } else {
        // المستخدم غير مسجل الدخول
        if (isFirstTime) {
          // أول مرة يستخدم التطبيق، انتقل لي onboarding
          _initialRoute = '/onboarding';
        } else {
          // المستخدم شاهد الـ onboarding من قبل، انتقل لتسجيل الدخول
          _initialRoute = '/login';
        }
      }
    } catch (e) {
      // في حالة حدوث خطأ، انتقل للـ splash
      _initialRoute = '/splash';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MaterialApp(
      title: 'Mafia Store',
      debugShowCheckedModeBanner: false,
      initialRoute: _initialRoute,
      routes: {
        '/splash': (context) => SplashScreen(),
        '/onboarding': (context) => OnboardingPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
      onGenerateRoute: (settings) {
        // معالجة المسارات الديناميكية
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (_) => SplashScreen());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => OnboardingPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginPage());
          case '/home':
            return MaterialPageRoute(builder: (_) => HomePage());
          default:
            return MaterialPageRoute(builder: (_) => SplashScreen());
        }
      },
    );
  }
}

// Widget للتحقق من حالة المصادقة في الوقت الفعلي
class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          // المستخدم غير مسجل الدخول
          return const LoginPage();
        } else {
          // المستخدم مسجل الدخول
          return child;
        }
      },
    );
  }
}
