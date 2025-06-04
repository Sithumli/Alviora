import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PositiveChatPage extends StatefulWidget {
  const PositiveChatPage({super.key});

  @override
  State<PositiveChatPage> createState() => _PositiveChatPageState();
}

class _PositiveChatPageState extends State<PositiveChatPage> {
  final TextEditingController _thoughtController = TextEditingController();

  final List<String> staticAffirmations = const [
    "You're doing better than you think.",
    "This moment will pass. You're strong enough.",
    "It's okay to feel low sometimes — it makes the highs worth it.",
    "Your effort counts, even when no one sees it.",
    "You have survived 100% of your worst days.",
    "You are enough. Right now. Just as you are.",
  ];

  Future<void> saveToFirebase(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('positive_thoughts').add({
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _thoughtController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your note has been saved ❤️")),
      );
      setState(() {}); // trigger refresh to show new message
    } catch (e) {
      print("Error saving to Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Positive Chat',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Text(
                "Welcome to your safe space.\nHere are some affirmations to lift your mood:",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔁 Stream all user-added affirmations from Firebase
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('positive_thoughts')
                    .orderBy('timestamp', descending: false)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final firebaseThoughts = snapshot.data?.docs
                      .map((doc) => doc['text'] as String)
                      .toList() ??
                      [];

                  final allThoughts = [...staticAffirmations, ...firebaseThoughts];

                  return ListView.separated(
                    itemCount: allThoughts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Text(
                          "💬 ${allThoughts[index]}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _thoughtController,
              decoration: InputDecoration(
                hintText: "Write down your thoughts here...",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => saveToFirebase(_thoughtController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                "Save",
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
