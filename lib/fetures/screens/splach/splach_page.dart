import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mafia_store/core/app_assets.dart';
import 'package:mafia_store/core/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double opacity1 = 1.0;
  double opacity2 = 0.0;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          opacity1 = .5;
          opacity2 = 1.0;
        });
      }
    });

    // تحديد المسار المناسب بناء على حالة المصادقة
    Timer(const Duration(seconds: 4), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    try {
      // التحقق من حالة تسجيل الدخول
      final user = AuthService.currentUser;
      final isFirstTime = await AuthService.isFirstTimeUser();

      if (user != null) {
        // المستخدم مسجل الدخول
        final hasProfile = await AuthService.hasUserProfile();

        if (hasProfile) {
          // المستخدم مسجل، انتقل للصفحة الرئيسية
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          // المستخدم مسجل الدخول لكن طلع
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      } else {
        // المستخدم غير مسجل الدخول
        if (isFirstTime) {
          // أول مرة يستخدم التطبيق، انتقل للـ onboarding
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/onboarding');
          }
        } else {
          // المستخدم شاهد الـ onboarding من قبل، انتقل لتسجيل الدخول
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      }
    } catch (e) {
      // في حالة حدوث خطأ، انتقل للـ onboarding
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الصورة الأولى
            AnimatedOpacity(
              opacity: opacity1,
              duration: const Duration(seconds: 2),
              child: SizedBox(
                height: 100,
                width: 100,
                child: Image.asset(
                  AppAssets.splash1,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 2),

            // الصورة الثانية
            AnimatedOpacity(
              opacity: opacity2,
              duration: const Duration(seconds: 2),
              child: SizedBox(
                height: 80,
                width: 300,
                child: Image.asset(
                  AppAssets.splash2,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
