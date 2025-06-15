import 'package:flutter/material.dart';

class ToDoListPage extends StatelessWidget {
  final List<Map<String, dynamic>> tasks = [
    {
      "icon": Icons.check_circle_outline,
      "title": "Morning Medication",
      "status": "2/3 completed",
      "time": "9:00 AM",
      "details": ["Take blood pressure pill", "Take vitamin D", "Take iron supplement"]
    },
    {
      "icon": Icons.opacity,
      "title": "Hydration Check",
      "status": "4/8 glasses",
      "time": "9:30 AM",
      "details": ["Drink a glass of water", "Track in app", "Avoid caffeine"]
    },
    {
      "icon": Icons.spa,
      "title": "Meditation Session",
      "status": "Not yet started",
      "time": "10:00 AM",
      "details": ["15 minutes guided", "Breathing exercise", "Play favorite music"]
    },
    {
      "icon": Icons.video_call,
      "title": "Video Call with Family",
      "status": "Scheduled for 4:00 PM",
      "time": "4:00 PM",
      "details": ["Test camera & mic", "Prepare topics", "Join 5 mins early"]
    },
    {
      "icon": Icons.medical_services,
      "title": "Evening Medication",
      "status": "Not yet started",
      "time": "7:30 PM",
      "details": ["Take cholesterol pill", "Take melatonin", "Update health log"]
    },
    {
      "icon": Icons.nights_stay,
      "title": "Sleep Monitoring",
      "status": "Starts at 9:00 PM",
      "time": "9:00 PM",
      "details": ["Turn on sleep tracker", "Adjust room lights", "Set alarm"]
    },
  ];

  Widget buildTaskCard({
    required IconData icon,
    required String title,
    required String status,
    required String time,
    required List<String> details,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline icon
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: Icon(icon, size: 32, color: Colors.blueAccent),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 70,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),

        // Task card
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.blueAccent, width: 1.5),
            ),
            elevation: 4,
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  status,
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ),
              children: details
                  .map((detail) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                title: Row(
                  children: [
                    Icon(Icons.brightness_1, size: 10, color: Colors.black54),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        detail,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Back Button
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios, size: 20),
                    label: Text(
                      "Go Back",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Header
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "To ",
                        style: TextStyle(color: Colors.blue, fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "Do\n",
                        style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: "L I S T",
                        style: TextStyle(letterSpacing: 8, color: Colors.blueAccent, fontSize: 18),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),

              // All Tasks
              Column(
                children: List.generate(tasks.length, (index) {
                  final task = tasks[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 26),
                    child: buildTaskCard(
                      icon: task["icon"],
                      title: task["title"],
                      status: task["status"],
                      time: task["time"],
                      details: List<String>.from(task["details"]),
                      isLast: index == tasks.length - 1,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
