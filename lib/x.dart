import 'package:flutter/material.dart';
import 'screens/robot_face_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alviora Tablet',
      debugShowCheckedModeBanner: false,
      home: const RobotFaceScreen(),
    );
  }
}
