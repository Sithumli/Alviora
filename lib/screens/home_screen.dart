import 'package:flutter/material.dart';
import 'dart:async';
import 'call_screen.dart';
import 'connect_with_family.dart'; // Ensure this exists or comment out for now
import 'package:alviora_tab/widgets/weather_widget.dart';
import 'to_do_list.dart';
import 'status.dart';
import 'telemedicine_hub.dart';
import 'mood_booster.dart';
import 'emergency.dart';
import 'package:alviora_tab/messages.dart';
import 'package:alviora_tab/settings.dart';
import 'package:alviora_tab/widgets/environment_stats_widget.dart';


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

class AlvioraHomePage extends StatefulWidget {
  const AlvioraHomePage({super.key});

  @override
  State<AlvioraHomePage> createState() => _AlvioraHomePageState();
}

class _AlvioraHomePageState extends State<AlvioraHomePage> {
  String _timeString = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _getTime() {
    setState(() {
      _timeString = _formatDateTime(DateTime.now());
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FF),
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar - UPDATED WITH NAVIGATION
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
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmergencyScreen()),
                      );
                    },
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 90),
                  ),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MessagesScreen()),
                      );
                    },
                    child: const Icon(Icons.message_rounded, color: Colors.white, size: 70),
                  ),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                    child: const Icon(Icons.settings_rounded, color: Colors.white, size: 70),
                  ),
                ],
              ),
            ),

            // Main content - FIXED EXPANDED SECTION
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Column(
                  children: [
                    // Top Info Bar
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _timeString,
                          style: const TextStyle(
                            fontSize: 96,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5EA8FF),
                          ),
                        ),
                        const SizedBox(width: 200),
                        const WeatherWidget(),
                        const SizedBox(width: 300),
                        const EnvironmentStatsWidget(),
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