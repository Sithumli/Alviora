import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'intro_screen.dart';
import 'welcome_screen.dart';
import 'sign_in_screen.dart'; // Assuming you have this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alviora',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white, // Base background
      ),
      home: const IntroScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/home': (context) => const AlvioraHomePage(),
      },
    );
  }
}

class AlvioraHomePage extends StatelessWidget {
  const AlvioraHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alviora Home'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFF90C3FD)],
              stops: [0.0, 0.93],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Color(0xFF90C3FD),
              Color(0xFF90C3FD),
            ],
            stops: [0.0, 0.74, 0.92, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildFeatureButton('Mood Detection', Icons.mood),
              const SizedBox(height: 16),
              _buildFeatureButton('Health Monitor', Icons.monitor_heart),
              const SizedBox(height: 16),
              _buildFeatureButton('360° Camera View', Icons.camera),
              const SizedBox(height: 16),
              _buildFeatureButton('Emergency Alert', Icons.warning),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(String text, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.8),
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black12),
        ),
      ),
      onPressed: () {},
    );
  }
}