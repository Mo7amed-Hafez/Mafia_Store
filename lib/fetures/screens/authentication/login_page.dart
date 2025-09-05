import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mafia_store/core/app_colore.dart';
import 'package:mafia_store/core/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  Color _obscureColor = AppColore.primaryColor;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(
      () => _isLoading = true,
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      try {
        final hasProfile = await AuthService.hasUserProfile();
        if (!hasProfile) {
          await AuthService.createUserProfile();
        } else {
          await AuthService.updateLastLogin();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("⚠️ Failed to sync profile: $e"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(
        () => _isLoading = false,
      );

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "❌ No user found for that email.";
          break;
        case 'wrong-password':
          message = "❌ Wrong password.";
          break;
        case 'invalid-credential':
          message = "❌ Invalid email or password.";
          break;
        case 'invalid-email':
          message = "❌ Invalid email format.";
          break;
        case 'user-disabled':
          message = "❌ This user has been disabled.";
          break;
        case 'too-many-requests':
          message = "❌ Too many attempts. Try again later.";
          break;
        default:
          message = "❌ ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      try {
        final hasProfile = await AuthService.hasUserProfile();
        if (!hasProfile) {
          await AuthService.createUserProfile();
        } else {
          await AuthService.updateLastLogin();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("⚠️ Failed to sync profile: $e"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("❌ Login failed with Google $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColore.lightColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag, size: 80, color: AppColore.primaryColor),
                const SizedBox(height: 20),

                const Text(
                  "Welcome Back 👋",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColore.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  "Login to your account",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 30),

                // Username
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon:
                        const Icon(Icons.email, color: AppColore.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter email";
                    }
                    if (!value.contains("@")) {
                      return "Invalid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock, color: AppColore.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                          _obscureColor =
                              _obscurePassword ? AppColore.primaryColor : Colors.red;
                        });
                      },
                    ),
                    suffixIconColor: _obscureColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 4 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Login Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: AppColore.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _login,
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 20),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(color: AppColore.primaryColor),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),
                Text(
                  "Or login with",
                  style: TextStyle(fontSize: 18, color: AppColore.oliveGreen),
                ),
                const SizedBox(height: 15),
                InkWell(
                  onTap: () {
                    _signInWithGoogle();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/google.png",
                          height: 30,
                          width: 30,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Login with Google",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
