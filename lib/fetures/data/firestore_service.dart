import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> createUserInFirestore(User user, {
  String? username,
  String? phone,
  String? gender,
  DateTime? birthday,
}) async {
  final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

  if (!(await userDoc.get()).exists) {
    await userDoc.set({
      'uid': user.uid,
      'email': user.email,
      'username': username ?? user.displayName ?? '',
      'phone': phone ?? user.phoneNumber ?? '',
      'gender': gender ?? '',
      'birthday': birthday?.toIso8601String() ?? '',
      'photoKey': 'defaultProfile',
      'settings': {
        'darkMode': false,
        'notifications': true,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
