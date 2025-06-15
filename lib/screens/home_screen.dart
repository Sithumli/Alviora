import 'package:flutter/material.dart';
import 'call_screen.dart';
import 'connect_with_family.dart'; // Ensure this exists or comment out for now
import 'package:alviora_tab/widgets/weather_widget.dart';
import 'to_do_list.dart';
import 'status.dart';
import 'telemedicine_hub.dart';
import 'mood_booster.dart';

void main() {
  runApp(const AlvioraApp());
}

class AlvioraApp extends StatelessWidget {
  const AlvioraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alviora Tablet Interface',
      theme: ThemeData(fontFamily: 'Arial'),
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
              width: 140,
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
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 90),
                  SizedBox(height: 50),
                  Icon(Icons.message_rounded, color: Colors.white, size: 70),
                  SizedBox(height: 50),
                  Icon(Icons.settings_rounded, color: Colors.white, size: 70),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Column(
                  children: [
                    // Top Info Bar
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          '02:56',
                          style: TextStyle(
                            fontSize: 96,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5EA8FF),
                          ),
                        ),
                        SizedBox(width: 200),
                        WeatherWidget(),
                        SizedBox(width: 300),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('ROOM TEMP', style: TextStyle(fontSize: 16)),
                            Text('25°C', style: TextStyle(fontSize: 32,color: Color(0xFF5EA8FF))),
                            SizedBox(height: 20),
                            Text('AIR QUALITY', style: TextStyle(fontSize: 16)),
                            Text('GOOD', style: TextStyle(fontSize: 32,color: Color(0xFF5EA8FF))),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Center title
                    const Center(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 64,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
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
                      ),
                    ),

                    const Spacer(),

                    // Bottom Card Buttons
                    SizedBox(
                      height: 280,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: const BoxDecoration(
                          color: Color(0xFF5EA8FF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ConnectWithFamilyScreen()),
                                  );
                                },
                                child: const AppCard(
                                  icon: Icons.map_rounded,
                                  label: 'Connect\nwith Family',
                                ),
                              ),
                            ),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ToDoListPage()),
                                  );
                                },
                                child: const AppCard(
                                  icon: Icons.list_alt_rounded,
                                  label: 'Todo List',
                                ),
                              ),
                            ),

                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => StatusPage()),
                                  );
                                },
                                child: const AppCard(
                                  icon: Icons.list_alt_rounded,
                                  label: 'Status',
                                ),
                              ),
                            ),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => TelemedicineHub()),
                                  );
                                },
                                child: const AppCard(
                                  icon: Icons.list_alt_rounded,
                                  label: 'Telemedicine Hub',
                                ),
                              ),
                            ),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MoodBoosterScreen()),
                                  );
                                },
                                child: const AppCard(
                                  icon: Icons.list_alt_rounded,
                                  label: 'Mood booster ',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
      height: 200,
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black12)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Color(0xFF5EA8FF), size: 50), // Bigger icon size
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.3),
          )
        ],
      ),
    );
  }
}
