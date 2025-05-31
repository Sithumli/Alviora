import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.home_outlined, color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.menu, color: Colors.black),
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
              DetectionCard(
                time: "10 Min Ago",
                urgency: true,
                action: "Pending",
                imageAsset: 'assets/fall.png',
                isRecent: true,
              ),
              const SizedBox(height: 12),
              DetectionCard(
                time: "12 Days Ago",
                urgency: false,
                action: "[ Call / View 360 ]",
                imageAsset: 'assets/fall.png',
                isRecent: false,
              ),
              const SizedBox(height: 12),
              DetectionCard(
                time: "Last Month",
                urgency: false,
                action: "[ Call / View 360 ]",
                imageAsset: 'assets/fall.png',
                isRecent: false,
              ),
            ] else if (selectedIndex == 1) ...[
              const Text("Cough detections page here..."),
            ] else if (selectedIndex == 2) ...[
              const Text("Other detections page here..."),
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

  const DetectionTab({super.key, required this.text, this.selected = false, required this.onTap});

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
  final String time;
  final bool urgency;
  final String action;
  final String imageAsset;
  final bool isRecent;

  const DetectionCard({
    super.key,
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
                Text("Fall Detected",
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
