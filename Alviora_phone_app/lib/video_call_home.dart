import 'package:flutter/material.dart';
import 'video_call.dart'; // This is your existing full video call UI

class VideoCallHome extends StatelessWidget {
  const VideoCallHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Missed Calls',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  MissedCallTile(name: 'Robot-alviora', time: 'Today, 3:42 PM'),
                  MissedCallTile(name: 'Robot-alviora', time: 'Yesterday, 7:10 PM'),
                  MissedCallTile(name: 'Robot-alviora', time: 'Monday, 5:05 AM'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VideoCallScreen()),
                  );
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.call, size: 32, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    const Text('Call', style: TextStyle(fontSize: 16)),
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

class MissedCallTile extends StatelessWidget {
  final String name;
  final String time;

  const MissedCallTile({super.key, required this.name, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.call_missed, color: Colors.red),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(time, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.info_outline, color: Colors.blue),
      ),
    );
  }
}
