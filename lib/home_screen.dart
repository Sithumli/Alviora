import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                  Color(0xFFFBE7F5), // soft pink top right
                  Color(0xFFE6F0FF), // middle tone
                  Color(0xFFD2EAFF), // blue at bottom
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Extra blue glow at the bottom
          Positioned(
            bottom: -100,
            left: -100,
            right: -100,
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomCenter,
                  radius: 1.2,
                  colors: [
                    Color(0xFFB2DBFF), // dense bluish bottom
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Foreground content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: Column(
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
                      )),
                  const SizedBox(height: 0.01),

                  // Icon grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildIconTile(Icons.check_box, "To-Do List"),
                      _buildIconTile(Icons.view_in_ar, "360 View"),
                      _buildIconTile(Icons.monitor_heart, "Status"),
                      _buildIconTile(Icons.notifications, "Alerts"),
                      _buildIconTile(Icons.check_box, "To-Do List"),
                      _buildIconTile(Icons.check_box, "To-Do List"),
                    ],
                  ),

                  const SizedBox(height: 1),
                  const Center(
                    child: Text(
                      "ALVIORA",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Calming Music & Robot Section
                  Row(
                    children: [
                      Expanded(child: _buildCard("Calming Music", Icons.music_note, "Open Now")),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: _cardBoxDecoration(),
                          child: Center(
                            child: Image.asset(
                              "assets/robot.png", // Replace with your actual image asset
                              height: 60,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Emergency card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: _cardBoxDecoration(),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Emergency",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 4),
                              Text(
                                "Let's open up to the thing that matters among the people",
                                style: TextStyle(fontSize: 13),
                              ),
                              SizedBox(height: 4),
                              Text("Dial Now",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
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
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconTile(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 32, color: Colors.blue),
        ),
        const SizedBox(height: 10),
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildCard(String title, IconData icon, String actionText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 5),
          Text(title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(actionText,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  BoxDecoration _cardBoxDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.8),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
