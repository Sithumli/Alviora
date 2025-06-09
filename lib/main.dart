import 'package:flutter/material.dart';

void main() {
  runApp(const AlvioraApp());
}

class AlvioraApp extends StatelessWidget {
  const AlvioraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AlvioraHomePage(),
    );
  }
}

class AlvioraHomePage extends StatelessWidget {
  const AlvioraHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FF),
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            Container(
              width: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF5EA8FF),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.warning_amber, color: Colors.white, size: 30),
                  SizedBox(height: 30),
                  Icon(Icons.message, color: Colors.white, size: 30),
                  SizedBox(height: 30),
                  Icon(Icons.settings, color: Colors.white, size: 30),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Top Info Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '02:56',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5EA8FF),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text('Sunny', style: TextStyle(fontSize: 36)),
                                SizedBox(width: 18),
                                Icon(Icons.wb_sunny, color: Colors.orange, size: 50),
                                SizedBox(width: 8),
                                Text('28°C', style: TextStyle(color: Color(0xFF5EA8FF))),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text('ROOM TEMP', style: TextStyle(fontSize: 22)),
                            Text('25°C', style: TextStyle(color: Color(0xFF5EA8FF))),
                            SizedBox(height: 28),
                            Text('AIR QUALITY', style: TextStyle(fontSize: 22)),
                            Text('GOOD', style: TextStyle(color: Color(0xFF5EA8FF))),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ALVIORA',
                      style: TextStyle(
                        fontSize: 52,
                        letterSpacing: 6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 90),

                    // Bottom Card Buttons
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: const BoxDecoration(
                          color: Color(0xFF5EA8FF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Flexible(child: AppCard(icon: Icons.map, label: '')),
                            Flexible(child: AppCard(icon: Icons.list, label: 'Status')),
                            Flexible(child: AppCard(icon: Icons.monitor_heart, label: 'Status')),
                            Flexible(child: AppCard(icon: Icons.medical_services, label: 'Tele medicine\nHub')),
                            Flexible(child: AppCard(icon: Icons.emoji_emotions, label: 'Mood Booster\nMode')),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const AppCard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width removed to allow flexible sizing
      height: 200,  // fixed height for balanced aspect ratio
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF5EA8FF), size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 1.2),
          )
        ],
      ),
    );
  }
}
