import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'QA.dart';
import 'mood_booster.dart';
import 'ScheduleScreen.dart';
import '360_view.dart';
import 'alerts_screen.dart';
import 'detection.dart';
import 'home_clean.dart';
import 'status.dart';
import 'settings.dart';
import 'emergency.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Gradient background
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

          // Foreground content without scrolling
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Welcome,",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Adam Smith",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.menu, color: Colors.black),
                        onSelected: (value) {
                          if (value == 'settings') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'settings',
                            child: Text('Settings'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    "How are you feeling today ?",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 14,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grid buttons wrapped in fixed height container
                  SizedBox(
                    height: 240,
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      padding: EdgeInsets.zero,
                      children: [
                        _buildButton(Icons.check_box, "To-Do List", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ScheduleScreen()),
                          );
                        }),
                        _buildButton(Icons.view_in_ar, "360 View", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LiveViewScreen()),
                          );
                        }),
                        _buildButton(Icons.monitor_heart, "Status", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => StatusScreen()),
                          );
                        }),
                        _buildButton(Icons.notifications, "Alerts", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AlertsScreen()),
                          );
                        }),
                        _buildButton(Icons.cleaning_services, "Home Clean", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomeMaintenanceStatus()),
                          );
                        }),
                        _buildButton(Icons.visibility, "Detection", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DetectionAlertsPage()),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ALVIORA Text
                  const Center(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 32,
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

                  const SizedBox(height: 20),

                  // Mood Booster + Robot Row
                  SizedBox(
                    height: 150,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildCard("Mood Booster", Icons.music_note, "Open Now", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MoodBoosterScreen()),
                            );
                          }),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: SizedBox(
                                height: 100,
                                child: Image.asset("assets/robot2.gif"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 11),

                  // Q & A + Emergency Row
                  SizedBox(
                    height: 150,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildCard("Q & A", Icons.question_answer, "Open Now", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const QAPage()),
                            );
                          }),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: _buildCard("Emergency", Icons.phone, "Dial Now", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EmergencyPage()),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // My Schedule button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ScheduleScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "My Schedule",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 75,
            height: 70,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF368FF5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget _buildCard(String title, IconData icon, String actionText, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Icon(icon, color: Colors.blue, size: 42),
              const SizedBox(height: 10),
              Text(
                actionText,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
