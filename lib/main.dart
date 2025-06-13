import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/call_screen.dart';  // Updated import path
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebRTC Video Call',
      theme: ThemeData.dark(),
      home: const CallScreen(),  // Now properly imported
    );
  }
}