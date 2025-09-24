import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showPassword = false;
  bool isLoading = false;
  bool agreeToTerms = false;

  Future<void> signUpUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to terms & conditions")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await userCredential.user?.updateDisplayName(nameController.text.trim());
      await userCredential.user?.reload();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed up successfully!')),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Sign up failed.';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFBE7F5),
                  Color(0xFFE6F0FF),
                  Color(0xFFA2CDFF),
                ],
                stops: [0.0, 0.5, 0.95],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 24),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Center(
                    child: Text(
                      'Sign up',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      filled: true,
                      fillColor: const Color(0x5966AAF7),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                    value != null && value.isNotEmpty ? null : 'Enter your full name',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'User ID (Email)',
                      filled: true,
                      fillColor: const Color(0x5966AAF7),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                    value != null && value.contains('@') ? null : 'Enter a valid email',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: const Color(0x5966AAF7),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => showPassword = !showPassword),
                      ),
                    ),
                    validator: (value) => value != null && value.length >= 6 ? null : 'Password must be at least 6 characters',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: agreeToTerms,
                        onChanged: (val) => setState(() => agreeToTerms = val ?? false),
                      ),
                      const Flexible(
                        child: Text(
                          'I agree to terms & conditions',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : signUpUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF368FF5),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sign Up', style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 