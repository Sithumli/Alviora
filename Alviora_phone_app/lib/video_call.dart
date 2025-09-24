import 'package:flutter/material.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Video Call", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Remote Stream Placeholder
          Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: const Text(
              "Robot Camera View",
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
          ),

          // Local Preview (bottom-right)
          Positioned(
            bottom: 100,
            right: 16,
            child: Container(
              height: 120,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text("You", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          // Call Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _callControlButton(Icons.mic, Colors.blue.shade800),
                _callControlButton(Icons.videocam, Colors.blue.shade800),
                _callControlButton(Icons.call_end, Colors.red),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _callControlButton(IconData icon, Color color) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
