import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome,", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Adam Smith", style: TextStyle(fontSize: 18)),
                ],
              ),
            ),

            // Scrollable horizontal top buttons
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _TopActionCard(title: 'To-Do List', subtitle: 'Customize Now', icon: Icons.checklist),
                  _TopActionCard(title: 'See task status', subtitle: 'Monitor Now', icon: Icons.insights),
                  _TopActionCard(title: 'Play & Schedule Music', subtitle: '', icon: Icons.music_note),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Temperature and Fall detection summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  _StatusCard(title: "Temperature", value: "85C", status: "Normal"),
                  const SizedBox(width: 12),
                  _StatusCard(title: "Fall Detection", value: "None"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Cough Detection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFB4B8F5),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Cough Detections", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Normal", style: TextStyle(fontSize: 14)),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Last cough: 2 mins ago"),
                        Text("4 coughs today"),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Conditional fall detection card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _FallStatusCard(isFallDetected: true),
            ),

            const SizedBox(height: 16),

            // Movement status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFB4B8F5),
                ),
                child: const Text("Movement status\nUnusual", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: ""),
        ],
      ),
    );
  }
}

class _TopActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _TopActionCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(fontSize: 12))
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final String? status;
  const _StatusCard({required this.title, required this.value, this.status});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (status != null)
              Text(status!, style: const TextStyle(color: Colors.grey, fontSize: 12))
          ],
        ),
      ),
    );
  }
}

class _FallStatusCard extends StatelessWidget {
  final bool isFallDetected;
  const _FallStatusCard({required this.isFallDetected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFallDetected ? Colors.red.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isFallDetected ? "Fall Detected" : "Monitoring for falls...",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          isFallDetected
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Location: Bedroom\nAction Required:"),
              Text("[ Call / Dismiss ]", style: TextStyle(color: Colors.red)),
            ],
          )
              : const Text("No detections", style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
