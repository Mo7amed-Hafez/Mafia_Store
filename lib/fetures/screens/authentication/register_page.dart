import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mafia_store/core/app_colore.dart';
import 'package:mafia_store/fetures/data/firestore_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfPassword = true;
  String? _selectedGender;
  DateTime? _selectedDate;
  Color _obscureColor = AppColore.primaryColor;
  Color _obscureColor2 = AppColore.primaryColor;

  // DateTime
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim());
      await credential.user?.updateDisplayName(_usernameController.text.trim());

      //  هنا تسجل في Firestore
      await createUserInFirestore(
        credential.user!,
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _selectedGender,
        birthday: _selectedDate,
      );

      if (mounted) {
        _showDialog('Success', 'Account created successfully!');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (mounted) {
        String message = _getErrorMessage(e.code);
        _showDialog('Error', message);
        setState(
          () => _isLoading = false,
        );
      }
      setState(
        () => _isLoading = false,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An Account with same email exists.';
      case "username-already-in-use":
        return 'An Account with same username exists.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'weaak-password':
        return 'Password is too weak, please choose a stronger one.';
      case 'operation-not-allowed':
        return 'Registeration is not allowed, please try again!';
      default:
        return 'An error occured, please try again.';
    }
  }

  void _showDialog(String title, String message) {
    Color dialogColor = title == 'Success' ? Colors.green : Colors.red;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: dialogColor),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (title == 'Success') {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
              children: [
                const Icon(Icons.person_add, size: 80, color: AppColore.primaryColor),
                const SizedBox(height: 20),

                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColore.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  "Register to get started",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 30),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    focusColor: Colors.blue,
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person, color: AppColore.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter username" : null,
                ),
                const SizedBox(height: 20),

                // Email
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

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone",
                    prefixIcon: const Icon(Icons.phone, color:AppColore.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter phone" : null,
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock, color:AppColore.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
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
                      return "Enter password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 4 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: AppColore.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {

                          _obscureConfPassword = !_obscureConfPassword;
                          _obscureColor2 =
                              _obscureConfPassword ? AppColore.primaryColor : Colors.red;
                        });
                      },
                    ),
                    suffixIconColor: _obscureColor2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Confirm your password";
                    }
                    if (value != _passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Gender
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: [
                    DropdownMenuItem(
                      value: 'male',
                      child: Row(
                        children: [
                          Icon(Icons.male, color: Colors.blue),
                          SizedBox(
                            width: 10,
                          ),
                          const Text('Male'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Row(
                        children: [
                          Icon(Icons.female, color: Colors.pink),
                          SizedBox(
                            width: 10,
                          ),
                          const Text('Female'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Gender",
                    prefixIcon:
                        const Icon(Icons.person_outlined, color: AppColore.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 15),
                FormField<DateTime>(
                  validator: (_) {
                    if (_selectedDate == null) {
                      return 'Please select your birthday';
                    }
                    return null;
                  },
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? 'Select Birthday'
                                    : "Birthday: ${_selectedDate.toString().split(' ')[0]}",
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await _pickDate(context);
                                state.validate();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColore.secondaryColor,
                                  elevation: 5),
                              child: Text("Select Birthday",
                                  style: TextStyle(color: AppColore.darkColor)),
                            ),
                          ],
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              state.errorText!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 30),

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
                        onPressed: _register,
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(color: AppColore.primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
