import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isObscure = true;

  String? emailError;
  String? passwordError;

  // ===== WARNA UTAMA =====
  static const Color primaryBlue = Color(0xFF0E2A47);
  static const Color secondaryBlue = Color(0xFF1F4E79);

  bool isEmailValid(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> login() async {
    setState(() {
      emailError = null;
      passwordError = null;
      isLoading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || !isEmailValid(email)) {
      setState(() {
        emailError = 'Email ora valid';
        isLoading = false;
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        passwordError = 'Password kudu diisi';
        isLoading = false;
      });
      return;
    }

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      setState(() => passwordError = e.message);
    } catch (_) {
      setState(() => passwordError = 'Login gagal');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryBlue,
              secondaryBlue,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond, size: 70, color: Colors.white),
                      const SizedBox(height: 12),
                      const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // EMAIL
                      _inputField(
                        controller: emailController,
                        icon: Icons.email,
                        hint: 'Email',
                        errorText: emailError,
                      ),

                      const SizedBox(height: 16),

                      // PASSWORD
                      _inputField(
                        controller: passwordController,
                        icon: Icons.lock,
                        hint: 'Password',
                        isPassword: true,
                        isObscure: isObscure,
                        errorText: passwordError,
                        suffix: IconButton(
                          icon: Icon(
                            isObscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setState(() => isObscure = !isObscure),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // BUTTON LOGIN
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Belum punya akun? ',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Daftar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== INPUT FIELD =====
  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? errorText,
    bool isPassword = false,
    bool isObscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? isObscure : false,
            decoration: InputDecoration(
              icon: Icon(icon, color: primaryBlue),
              hintText: hint,
              border: InputBorder.none,
              suffixIcon: suffix,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
