import 'package:flutter/material.dart';
import 'package:alviora_app/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'intro_screen.dart';



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
      ),
      home:  const IntroScreen(),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Mood Detection'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Health Monitor'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('360° Camera View'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Emergency Alert'),
            ),
          ],
        ),
      ),
    );
  }
}
