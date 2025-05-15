import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
        child: SafeArea(
          child: Stack(
            children: [
              // Welcome to the
              const Positioned(
                top: 213,
                left: 24,
                right: 24,
                child: Text(
                  'Welcome to the',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                    color: Colors.black87,
                  ),
                ),
              ),

              // ALVIORA with colored V and A
              const Positioned(
                top: 265,
                left: 24,
                right: 24,
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: 'TiltNeon',
                      fontSize: 48,
                      letterSpacing: 1.5,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(text: 'AL'),
                      TextSpan(
                        text: 'V',
                        style: TextStyle(color: Color(0xFF368FF5)),
                      ),
                      TextSpan(text: 'IOR'),
                      TextSpan(
                        text: 'A',
                        style: TextStyle(color: Color(0xFF368FF5)),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // By Team Ctrl Z
              const Positioned(
                top: 319,
                left: 24,
                right: 24,
                child: Text(
                  'by Team Ctrl Z',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ),

              // Subtitle
              const Positioned(
                top: 418,
                left: 24,
                right: 24,
                child: Text(
                  'Your mindful mental health AI companion\nfor everyone, anywhere 🌿',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Get Started Button
              Positioned(
                top: 520,
                left: (MediaQuery.of(context).size.width - 181) / 2,
                child: SizedBox(
                  width: 181,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A6CE4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
