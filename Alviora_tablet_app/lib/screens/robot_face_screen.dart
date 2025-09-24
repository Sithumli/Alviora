import 'package:flutter/material.dart';
import 'dart:math';
import 'home_screen.dart';

class RobotFaceScreen extends StatefulWidget {
  const RobotFaceScreen({super.key});

  @override
  State<RobotFaceScreen> createState() => _RobotFaceScreenState();
}

class _RobotFaceScreenState extends State<RobotFaceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AlvioraHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToHome,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: RobotPainter(_controller.value),
                size: const Size(400, 400),
              );
            },
          ),
        ),
      ),
    );
  }
}

class RobotPainter extends CustomPainter {
  final double animationValue;
  RobotPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final cyan = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.fill;

    final eyeOffsetX = sin(animationValue * 2 * pi) * 5;

    final eyeWidth = 300.0;
    final eyeHeight = 300.0;
    final eyeRadius = eyeWidth / 2;

    // Adjusted eye positions with fixed gap
    final leftEyeCenterX = size.width / 2 - 300 + eyeOffsetX;
    final rightEyeCenterX = size.width / 2 + 300 + eyeOffsetX;

    // Draw left eye
    final leftEyeRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: Offset(leftEyeCenterX, size.height * 0.35),
        width: eyeWidth,
        height: eyeHeight,
      ),
      topLeft: Radius.circular(eyeRadius),
      topRight: Radius.circular(eyeRadius),
      bottomLeft: Radius.circular(eyeRadius),
      bottomRight: Radius.circular(eyeRadius),
    );
    canvas.drawArc(leftEyeRect.outerRect, pi, pi, true, cyan);

    // Draw right eye
    final rightEyeRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: Offset(rightEyeCenterX, size.height * 0.35),
        width: eyeWidth,
        height: eyeHeight,
      ),
      topLeft: Radius.circular(eyeRadius),
      topRight: Radius.circular(eyeRadius),
      bottomLeft: Radius.circular(eyeRadius),
      bottomRight: Radius.circular(eyeRadius),
    );
    canvas.drawArc(rightEyeRect.outerRect, pi, pi, true, cyan);

    // Mouth
    final mouthWidth = eyeWidth / 1.5;
    final mouthHeight = eyeHeight / 1.5;

    final mouthRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.85),
      width: mouthWidth,
      height: mouthHeight,
    );

    canvas.drawArc(mouthRect, 0, pi, true, cyan);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
