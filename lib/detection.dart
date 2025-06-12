import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'settings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MaterialApp(home: DetectionAlertsPage()));
}

class DetectionAlertsPage extends StatefulWidget {
  const DetectionAlertsPage({super.key});

  @override
  State<DetectionAlertsPage> createState() => _DetectionAlertsPageState();
}

class _DetectionAlertsPageState extends State<DetectionAlertsPage> {
  int selectedIndex = 0;
  final List<String> tabTitles = ["Fall Detection", "Cough Detection", "Other Detections"];
  final DatabaseReference _alertsRef = FirebaseDatabase.instance.ref('alerts');
  final DatabaseReference _streamRef = FirebaseDatabase.instance.ref('stream_status');

  String _getTimeAgo(String timestamp) {
    try {
      final DateTime alertTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(alertTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} Min Ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} Hours Ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays} Days Ago';
      } else {
        return DateFormat('MMM d, y').format(alertTime);
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home_rounded, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        actions: [
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF688BFF), Color(0xFFA7B9FF)],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Detections Alerts",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Giving guidance on recent detections",
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: List.generate(
                tabTitles.length,
                    (index) => DetectionTab(
                  text: tabTitles[index],
                  selected: index == selectedIndex,
                  onTap: () => setState(() => selectedIndex = index),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (selectedIndex == 0) ...[
              StreamBuilder(
                stream: _alertsRef.orderByChild('type').equalTo('fall').onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                    return const Center(child: Text('No fall detections yet'));
                  }

                  final Map<dynamic, dynamic> alerts =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                  final List<MapEntry<dynamic, dynamic>> sortedAlerts =
                  alerts.entries.toList()
                    ..sort((a, b) => DateTime.parse(b.value['timestamp'])
                        .compareTo(DateTime.parse(a.value['timestamp'])));

                  return Column(
                    children: sortedAlerts.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final data = entry.value.value as Map<dynamic, dynamic>;
                      final timestamp = data['timestamp'] as String;

                      final bool isLatest = index == 0;

                      return Column(
                        children: [
                          DetectionCard(
                            title: "Fall Detected",
                            time: _getTimeAgo(timestamp),
                            urgency: isLatest,  // red color only for latest alert
                            action: data['status'] == 'active' ? "Pending" : "Resolved",
                            imageAsset: 'assets/fall.png',
                            isRecent: isLatest,  // only latest shows buttons
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ] else if (selectedIndex == 1) ...[
              StreamBuilder(
                stream: _streamRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                    return const Center(child: Text('No cough detections yet'));
                  }

                  final Map<dynamic, dynamic> data =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                  final int coughCount = data['cough_count'] ?? 0;
                  final String lastUpdate = (data['last_update'] ?? DateTime.now().toIso8601String()) as String;
                  final String status = data['status'] ?? 'inactive';

                  return Column(
                    children: [
                      DetectionCard(
                        title: "Cough Detected",
                        time: _getTimeAgo(lastUpdate),
                        urgency: coughCount >= 20,
                        action: status == 'active' ? "Active Monitoring" : "Resolved",
                        imageAsset: 'assets/cough.png',
                        isRecent: DateTime.now().difference(DateTime.parse(lastUpdate)).inHours < 24,
                      ),
                    ],
                  );
                },
              ),
            ] else if (selectedIndex == 2) ...[
              StreamBuilder(
                stream: _alertsRef.orderByChild('type').equalTo('other').onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                    return const Center(child: Text('No other detections yet'));
                  }

                  final Map<dynamic, dynamic> alerts =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                  final List<MapEntry<dynamic, dynamic>> sortedAlerts =
                  alerts.entries.toList()
                    ..sort((a, b) => DateTime.parse(b.value['timestamp'])
                        .compareTo(DateTime.parse(a.value['timestamp'])));

                  return Column(
                    children: sortedAlerts.map((entry) {
                      final data = entry.value as Map<dynamic, dynamic>;
                      final timestamp = data['timestamp'] as String;

                      return Column(
                        children: [
                          DetectionCard(
                            title: "Unusual Behavior",
                            time: _getTimeAgo(timestamp),
                            urgency: false,
                            action: data['status'] == 'active' ? "Pending" : "Resolved",
                            imageAsset: 'assets/cough.png',
                            isRecent: DateTime.now().difference(DateTime.parse(timestamp)).inHours < 24,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class DetectionTab extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const DetectionTab({
    super.key,
    required this.text,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.blue,
              fontWeight: FontWeight.w500,
            )),
        backgroundColor: selected ? Colors.blue : Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}

class DetectionCard extends StatelessWidget {
  final String title;
  final String time;
  final bool urgency;
  final String action;
  final String imageAsset;
  final bool isRecent;

  const DetectionCard({
    super.key,
    required this.title,
    required this.time,
    required this.urgency,
    required this.action,
    required this.imageAsset,
    required this.isRecent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: urgency ? Colors.red : Colors.black,
                    )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 6),
                Text("Action Required: $action"),
                if (isRecent)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text("Call 1990", style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text("Dismiss", style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.video_camera_front, size: 16),
                          label: const Text("360", style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Image.asset(imageAsset, width: 80, height: 80, fit: BoxFit.cover),
                const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.play_circle_fill, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
