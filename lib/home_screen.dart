import 'package:flutter/material.dart';
import 'ScheduleScreen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // Foreground content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome,",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const Text("Adam Smith",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 8),
                  const Text("How are you feeling today ?",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 14,
                        height: 1.0,
                      )),

                  const SizedBox(height: 20),

                  // Icon buttons
                  SizedBox(
                    height: 240,
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      padding: EdgeInsets.zero,
                      children: [
                        _buildButton(context, Icons.check_box, "To-Do List", const ScheduleScreen()),
                        _buildButton(context, Icons.view_in_ar, "360 View", const View360Page()),
                        _buildButton(context, Icons.monitor_heart, "Status", const StatusPage()),
                        _buildButton(context, Icons.notifications, "Alerts", const AlertsPage()),
                        _buildButton(context, Icons.cleaning_services, "Home Clean", const HomeCleanPage()),
                        _buildButton(context, Icons.visibility, "Detection", const DetectionPage()),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: Center(
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
                  ),

                  const SizedBox(height: 20),

                  // First row with Mood Booster and Robot
                  SizedBox(
                    height: 150,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildCard(context, "Mood Booster", Icons.music_note, "Open Now", const MoodBoosterPage()),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Image.asset("assets/robot2.gif"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 11),

                  // Second row with Q&A and Emergency
                  SizedBox(
                    height: 150,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildCard(context, "Q & A", Icons.question_answer, "Open Now", const QAPage()),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: _buildCard(context, "Emergency", Icons.phone, "Dial Now", const EmergencyPage()),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Bottom button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "My Schedule",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  static Widget _buildButton(BuildContext context, IconData icon, String label, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
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
          Text(label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  static Widget _buildCard(BuildContext context, String title, IconData icon, String actionText, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 5),
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(actionText,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// Dummy placeholder pages
class ToDoPage extends StatelessWidget {
  const ToDoPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('To-Do List')));
}

class View360Page extends StatelessWidget {
  const View360Page({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('360 View')));
}

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Status')));
}

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Alerts')));
}

class HomeCleanPage extends StatelessWidget {
  const HomeCleanPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Home Clean')));
}

class DetectionPage extends StatelessWidget {
  const DetectionPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Detection')));
}

class MoodBoosterPage extends StatelessWidget {
  const MoodBoosterPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Mood Booster')));
}

class QAPage extends StatelessWidget {
  const QAPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Q & A')));
}

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Emergency')));
}
