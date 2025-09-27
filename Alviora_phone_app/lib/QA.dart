import 'package:flutter/material.dart';

class QAPage extends StatelessWidget {
  const QAPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Q & A", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CategoryHeader(title: "General"),
          QAItem(
            question: "What is Alviora?",
            answer: "Alviora is an AI-powered eldercare assistant that helps monitor safety, detect emergencies like falls, and assist caregivers.",
          ),
          QAItem(
            question: "Who is this for?",
            answer: "Alviora is designed for elderly individuals living independently and the caregivers who support them.",
          ),
          QAItem(
            question: "Is this a real product?",
            answer: "Currently it's a functional prototype built for CodeSprint X. Fall and cough detections are simulated for demonstration.",
          ),

          CategoryHeader(title: "Detection System"),
          QAItem(
            question: "How does fall detection work?",
            answer: "We use camera input and AI logic (on-device or server) to detect sudden falls. For now, we simulate detections via Firebase.",
          ),
          QAItem(
            question: "What happens when a fall is detected?",
            answer: "A real-time alert appears in the app with details and emergency actions like calling or viewing a 360 feed.",
          ),

          CategoryHeader(title: "Technical"),
          QAItem(
            question: "What technologies are used?",
            answer: "Flutter for the UI, Firebase for backend & live updates, and Python/OpenCV for detection logic (simulated in this version).",
          ),
          QAItem(
            question: "Is real hardware used?",
            answer: "Not yet. But we have placeholders to integrate Raspberry Pi cameras and sensors for real-time detection.",
          ),

          CategoryHeader(title: "Security & Privacy"),
          QAItem(
            question: "Is my data secure?",
            answer: "Yes, all data is securely handled in Firebase. We don’t collect personal images or audio in this demo.",
          ),
          QAItem(
            question: "Are images or videos recorded?",
            answer: "No actual footage is stored or captured. We only show simulated visuals for the prototype.",
          ),

          CategoryHeader(title: "Future Plans"),
          QAItem(
            question: "Will this support emotion or voice?",
            answer: "Yes. We plan to add voice control and emotion recognition using AI to improve elder engagement.",
          ),
          QAItem(
            question: "What detections are coming?",
            answer: "Coughing, abnormal movement, inactivity, breathing issues — all powered by future AI models.",
          ),

          SizedBox(height: 24),
          Center(
            child: Text(
              "Alviora – CodeSprint X 2025",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class QAItem extends StatelessWidget {
  final String question;
  final String answer;

  const QAItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Text(answer, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}

class CategoryHeader extends StatelessWidget {
  final String title;

  const CategoryHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }
}
