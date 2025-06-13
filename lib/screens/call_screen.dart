import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOff = !_isCameraOff;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800], // Dark gray background for the video area
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Left video feed
                Expanded(
                  child: Container(
                    color: Colors.black, // Placeholder for video feed
                    // You would typically integrate a video player here
                    child: Center(
                      child: Image.asset(
                        'assets/elderly_woman.png', // Replace with your image asset path
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Right video feed
                Expanded(
                  child: Container(
                    color: Colors.black, // Placeholder for video feed
                    // You would typically integrate a video player here
                    child: Center(
                      child: Image.asset(
                        'assets/young_couple.png', // Replace with your image asset path
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom control bar
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF5EA8FF), // Blue color from the image
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.all(10), // Margin around the bar
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.white, size: 40),
                  onPressed: () {
                    // Handle more options
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isMuted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: _toggleMute,
                ),
                IconButton(
                  icon: Icon(
                    _isCameraOff ? Icons.videocam_off : Icons.videocam,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: _toggleCamera,
                ),
                IconButton(
                  icon: const Icon(Icons.call_end, color: Colors.red, size: 40), // Red end call button
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous screen
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.group, color: Colors.white, size: 40),
                  onPressed: () {
                    // Handle participants
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
