import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream للاستماع لتغييرات حالة المصادقة
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // الحصول على المستخدم الحالي
  static User? get currentUser => _auth.currentUser;

  // التحقق من تسجيل الدخول
  static bool get isLoggedIn => currentUser != null;

  // تسجيل الخروج
  static Future<void> signOut() async {
    await _auth.signOut();
    // مسح البيانات المحلية
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // التحقق من أن المستخدم جديد (أول مرة يستخدم التطبيق)
  static Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('has_seen_onboarding') ?? false);
  }

  // تعيين أن المستخدم شاهد الـ onboarding
  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  // التحقق من وجود بيانات المستخدم في Firestore
  static Future<bool> hasUserProfile() async {
    if (!isLoggedIn) return false;

    try {
      final doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // الحصول على بيانات المستخدم
  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isLoggedIn) return null;

    try {
      final doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // إنشاء ملف تعريف المستخدم
  static Future<void> createUserProfile({
    String? username,
    String? phone,
    String? gender,
    DateTime? birthday,
  }) async {
    if (!isLoggedIn) return;

    try {
      await _firestore.collection('users').doc(currentUser!.uid).set({
        'uid': currentUser!.uid,
        'email': currentUser!.email,
        'username': username ?? currentUser!.displayName ?? '',
        'phone': phone ?? currentUser!.phoneNumber ?? '',
        'gender': gender ?? '',
        'birthday': birthday?.toIso8601String() ?? '',
        'photoKey': 'defaultProfile',
        'settings': {
          'darkMode': false,
          'notifications': true,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // تحديث آخر تسجيل دخول
  static Future<void> updateLastLogin() async {
    if (!isLoggedIn) return;

    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // لا نريد إظهار خطأ إذا فشل تحديث آخر تسجيل دخول
    }
  }
}
